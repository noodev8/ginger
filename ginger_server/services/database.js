const { Pool } = require('pg');

class Database {
  constructor() {
    this.pool = new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      min: parseInt(process.env.DB_POOL_MIN) || 2,
      max: parseInt(process.env.DB_POOL_MAX) || 10,
      idleTimeoutMillis: parseInt(process.env.DB_POOL_IDLE_TIMEOUT) || 30000,
      connectionTimeoutMillis: parseInt(process.env.DB_POOL_CONNECTION_TIMEOUT) || 2000,
    });

    // Test connection on startup
    this.testConnection();
  }

  async testConnection() {
    try {
      console.log('🔌 Testing database connection...');
      console.log(`   Host: ${process.env.DB_HOST}:${process.env.DB_PORT}`);
      console.log(`   Database: ${process.env.DB_NAME}`);
      console.log(`   User: ${process.env.DB_USER}`);

      const client = await this.pool.connect();
      const result = await client.query('SELECT NOW() as current_time');
      console.log('✅ Database connected successfully');
      console.log(`   Server time: ${result.rows[0].current_time}`);
      client.release();
    } catch (err) {
      console.error('❌ Database connection failed:');
      console.error(`   Error: ${err.message}`);
      console.error(`   Code: ${err.code}`);
      console.error(`   Host: ${process.env.DB_HOST}:${process.env.DB_PORT}`);
      console.error(`   Database: ${process.env.DB_NAME}`);
      console.error(`   User: ${process.env.DB_USER}`);

      // Don't exit in development, just log the error
      if (process.env.NODE_ENV === 'production') {
        process.exit(1);
      } else {
        console.log('⚠️  Continuing in development mode without database...');
      }
    }
  }

  async query(text, params, retries = 1) {
    const start = Date.now();

    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        const res = await this.pool.query(text, params);
        const duration = Date.now() - start;

        if (process.env.NODE_ENV === 'development') {
          console.log('📊 Query executed:', { text, duration: `${duration}ms`, rows: res.rowCount });
        }

        return res;
      } catch (err) {
        const isLastAttempt = attempt === retries;

        // Retry on connection errors, but not on data/constraint errors
        const shouldRetry = !isLastAttempt && (
          err.code === 'ECONNRESET' ||
          err.code === 'ENOTFOUND' ||
          err.code === 'ECONNREFUSED' ||
          err.message.includes('connection')
        );

        if (shouldRetry) {
          console.log(`⚠️ Database query failed (attempt ${attempt + 1}/${retries + 1}), retrying...`);
          await new Promise(resolve => setTimeout(resolve, 100 * (attempt + 1))); // Exponential backoff
          continue;
        }

        console.error('❌ Database query error:', err.message);
        throw err;
      }
    }
  }

  async getClient() {
    return await this.pool.connect();
  }

  async close() {
    await this.pool.end();
    console.log('🔌 Database connection pool closed');
  }
}

// Create singleton instance
const database = new Database();

module.exports = database;
