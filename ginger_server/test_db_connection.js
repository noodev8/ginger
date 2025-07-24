const { Pool } = require('pg');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

async function testConnection() {
  console.log('🔍 Testing database connection...');
  console.log('Configuration:');
  console.log(`  Host: ${process.env.DB_HOST}`);
  console.log(`  Port: ${process.env.DB_PORT}`);
  console.log(`  Database: ${process.env.DB_NAME}`);
  console.log(`  User: ${process.env.DB_USER}`);
  console.log(`  Password: ${process.env.DB_PASSWORD ? '***' : 'NOT SET'}`);
  console.log('');

  const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    // Try with SSL first, then without
    ssl: {
      rejectUnauthorized: false
    }
  });

  try {
    console.log('🔌 Attempting connection with SSL...');
    const client = await pool.connect();
    
    console.log('✅ Connected successfully!');
    
    // Test a simple query
    const result = await client.query('SELECT NOW() as current_time, version() as pg_version');
    console.log(`📅 Server time: ${result.rows[0].current_time}`);
    console.log(`🐘 PostgreSQL version: ${result.rows[0].pg_version}`);
    
    // Test if our tables exist
    const tablesResult = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('app_user', 'loyalty_points', 'point_transactions')
    `);
    
    console.log('📋 Found tables:', tablesResult.rows.map(row => row.table_name));
    
    client.release();
    console.log('✅ Database connection test successful!');
    
  } catch (error) {
    console.error('❌ Connection failed:');
    console.error(`   Error: ${error.message}`);
    console.error(`   Code: ${error.code}`);
    
    if (error.code === 'ENOTFOUND') {
      console.error('   → Host not found. Check the DB_HOST value.');
    } else if (error.code === 'ECONNREFUSED') {
      console.error('   → Connection refused. Check if PostgreSQL is running and accessible.');
    } else if (error.code === '28P01') {
      console.error('   → Authentication failed. Check DB_USER and DB_PASSWORD.');
    } else if (error.code === '3D000') {
      console.error('   → Database does not exist. Check DB_NAME.');
    }
    
    // Try without SSL
    console.log('\n🔄 Trying connection without SSL...');
    
    const poolNoSSL = new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      ssl: false
    });
    
    try {
      const client = await poolNoSSL.connect();
      console.log('✅ Connected successfully without SSL!');
      client.release();
      console.log('💡 Suggestion: Update database.js to use ssl: false');
    } catch (noSSLError) {
      console.error('❌ Connection without SSL also failed:');
      console.error(`   Error: ${noSSLError.message}`);
    }
    
    await poolNoSSL.end();
  }
  
  await pool.end();
  process.exit(0);
}

testConnection();
