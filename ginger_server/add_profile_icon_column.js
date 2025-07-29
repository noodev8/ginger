const database = require('./services/database');

async function addProfileIconColumn() {
  try {
    console.log('🔧 Adding profile_icon_id column to app_user table...');
    
    // Check if column already exists
    const columnCheck = await database.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'app_user' AND column_name = 'profile_icon_id'
    `);
    
    if (columnCheck.rows.length > 0) {
      console.log('✅ profile_icon_id column already exists');
      return;
    }
    
    // Add the column
    await database.query(`
      ALTER TABLE app_user 
      ADD COLUMN profile_icon_id VARCHAR(50) DEFAULT 'coffee_cup'
    `);
    
    console.log('✅ Added profile_icon_id column to app_user table');
    
    // Update existing users with default profile icon
    const updateResult = await database.query(`
      UPDATE app_user 
      SET profile_icon_id = 'coffee_cup' 
      WHERE profile_icon_id IS NULL
    `);
    
    console.log(`✅ Updated ${updateResult.rowCount} users with default profile icon`);
    
    // Show current table structure
    const tableInfo = await database.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns 
      WHERE table_name = 'app_user'
      ORDER BY ordinal_position
    `);
    
    console.log('\n📋 Current app_user table structure:');
    tableInfo.rows.forEach(col => {
      console.log(`   ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable}, default: ${col.column_default})`);
    });
    
  } catch (error) {
    console.error('❌ Error adding profile_icon_id column:', error);
  } finally {
    process.exit(0);
  }
}

addProfileIconColumn();
