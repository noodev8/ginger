require('dotenv').config();
const database = require('./services/database');
const bcrypt = require('bcrypt');

async function setupTestData() {
  try {
    console.log('🔧 Setting up test data...');
    
    // Check existing users
    const existingUsers = await database.query('SELECT id, email, staff FROM app_user ORDER BY id');
    console.log(`Found ${existingUsers.rows.length} existing users`);
    
    if (existingUsers.rows.length === 0) {
      console.log('Creating test users...');
      
      // Create test users
      const password = await bcrypt.hash('password123', 10);
      
      // Customer users
      await database.query(
        'INSERT INTO app_user (email, password_hash, display_name, staff) VALUES ($1, $2, $3, $4)',
        ['customer1@test.com', password, 'Customer 1', false]
      );
      
      await database.query(
        'INSERT INTO app_user (email, password_hash, display_name, staff) VALUES ($1, $2, $3, $4)',
        ['customer2@test.com', password, 'Customer 2', false]
      );
      
      // Staff user
      await database.query(
        'INSERT INTO app_user (email, password_hash, display_name, staff) VALUES ($1, $2, $3, $4)',
        ['staff@test.com', password, 'Test Staff', true]
      );
      
      console.log('✅ Created test users');
    }
    
    // Get all users
    const users = await database.query('SELECT id, email, staff FROM app_user ORDER BY id');
    console.log('\n📋 All users:');
    users.rows.forEach(user => {
      console.log(`   ${user.id}: ${user.email} (staff: ${user.staff})`);
    });
    
    // Create loyalty points for non-staff users
    for (const user of users.rows) {
      if (!user.staff) {
        const pointsExist = await database.query('SELECT id FROM loyalty_points WHERE user_id = $1', [user.id]);
        if (pointsExist.rows.length === 0) {
          await database.query('INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, 0)', [user.id]);
          console.log(`   ✅ Created loyalty points for user ${user.id}`);
        }
      }
    }
    
    // Create simple QR codes for non-staff users
    await database.query('DELETE FROM user_qr_codes');
    console.log('\n🔧 Creating QR codes...');
    
    for (const user of users.rows) {
      if (!user.staff) {
        await database.query(
          'INSERT INTO user_qr_codes (user_id, qr_code_data) VALUES ($1, $2)',
          [user.id, user.id.toString()]
        );
        console.log(`   ✅ Created QR code for user ${user.id}: "${user.id}"`);
      }
    }
    
    // Verify QR codes
    const qrCodes = await database.query('SELECT uqr.*, au.email FROM user_qr_codes uqr JOIN app_user au ON uqr.user_id = au.id');
    console.log('\n📋 QR codes:');
    qrCodes.rows.forEach(row => {
      console.log(`   User ${row.user_id} (${row.email}): "${row.qr_code_data}"`);
    });
    
    console.log('\n🎉 Test data setup complete!');
    console.log('\nLogin credentials:');
    console.log('  Staff: staff@test.com / password123');
    console.log('  Customer 1: customer1@test.com / password123');
    console.log('  Customer 2: customer2@test.com / password123');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

setupTestData();
