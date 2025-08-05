require('dotenv').config();
const fs = require('fs');
const path = require('path');
const database = require('./services/database');

async function runMigration(migrationFile) {
  try {
    console.log(`🚀 Running migration: ${migrationFile}`);
    
    // Read the migration file
    const migrationPath = path.join(__dirname, 'migrations', migrationFile);
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
    
    console.log('📝 Migration content:');
    console.log(migrationSQL);
    console.log('\n🔄 Executing migration...');
    
    // Execute the migration
    await database.query(migrationSQL);
    
    console.log('✅ Migration completed successfully!');
    
    // Verify the user_tokens table was created
    const result = await database.query(`
      SELECT table_name, column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'user_tokens' 
      ORDER BY ordinal_position
    `);
    
    if (result.rows.length > 0) {
      console.log('\n📋 user_tokens table structure:');
      result.rows.forEach(row => {
        console.log(`   ${row.column_name}: ${row.data_type}`);
      });
    }
    
    // Check if any tokens were migrated
    const tokenCount = await database.query('SELECT COUNT(*) as count FROM user_tokens');
    console.log(`\n📊 Migrated tokens: ${tokenCount.rows[0].count}`);
    
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    throw error;
  } finally {
    process.exit(0);
  }
}

// Get migration file from command line argument or use default
const migrationFile = process.argv[2] || '004_create_user_tokens_table.sql';
runMigration(migrationFile);
