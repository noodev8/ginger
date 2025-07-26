require('dotenv').config();
const database = require('./services/database');

async function fixQRCodes() {
  try {
    console.log('🔧 Fixing QR codes to simple format...');
    
    // Delete all existing QR codes
    await database.query('DELETE FROM user_qr_codes');
    console.log('✅ Deleted all existing QR codes');
    
    // Create simple QR codes for all users (QR data = user ID)
    const users = await database.query('SELECT id FROM app_user WHERE staff = false');
    console.log(`📝 Creating simple QR codes for ${users.rows.length} users...`);
    
    for (const user of users.rows) {
      await database.query(
        'INSERT INTO user_qr_codes (user_id, qr_code_data) VALUES ($1, $2)',
        [user.id, user.id.toString()]
      );
      console.log(`   ✅ Created QR code for user ${user.id}: "${user.id}"`);
    }
    
    // Verify
    const result = await database.query('SELECT uqr.*, au.email FROM user_qr_codes uqr JOIN app_user au ON uqr.user_id = au.id');
    console.log('\n📋 Final QR codes:');
    result.rows.forEach(row => {
      console.log(`   User ${row.user_id} (${row.email}): "${row.qr_code_data}"`);
    });
    
    console.log('\n🎉 QR codes fixed successfully!');
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

fixQRCodes();
