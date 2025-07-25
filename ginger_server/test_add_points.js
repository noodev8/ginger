/*
=======================================================================================================================================
Test Script: Add Points Functionality
=======================================================================================================================================
Purpose: Test the add points functionality to debug issues with QR code scanning
=======================================================================================================================================
*/

// Load environment variables first
require('dotenv').config();

const database = require('./services/database');
const pointsService = require('./services/points_service');

async function testAddPoints() {
  console.log('===== TESTING ADD POINTS FUNCTIONALITY =====');
  
  try {
    // Test database connection first
    console.log('\n1. Testing database connection...');
    const testQuery = await database.query('SELECT NOW() as current_time');
    console.log('✅ Database connection successful:', testQuery.rows[0]);
    
    // Check if users exist
    console.log('\n2. Checking users in database...');
    const users = await database.query('SELECT id, email, display_name, staff FROM app_user ORDER BY id');
    console.log(`Found ${users.rows.length} users:`);
    users.rows.forEach(user => {
      console.log(`  - ID: ${user.id}, Email: ${user.email}, Name: ${user.display_name}, Staff: ${user.staff}`);
    });
    
    if (users.rows.length < 2) {
      console.log('❌ Need at least 2 users (1 customer, 1 staff) to test');
      return;
    }
    
    // Find a customer and staff user
    const customer = users.rows.find(u => !u.staff);
    const staff = users.rows.find(u => u.staff);
    
    if (!customer) {
      console.log('❌ No customer user found (staff = false)');
      return;
    }
    
    if (!staff) {
      console.log('❌ No staff user found (staff = true)');
      return;
    }
    
    console.log(`\n3. Using customer: ${customer.email} (ID: ${customer.id})`);
    console.log(`   Using staff: ${staff.email} (ID: ${staff.id})`);
    
    // Check current points
    console.log('\n4. Checking current loyalty points...');
    const currentPoints = await database.query('SELECT * FROM loyalty_points WHERE user_id = $1', [customer.id]);
    console.log(`Current points for customer ${customer.id}:`, currentPoints.rows);
    
    // Test adding points
    console.log('\n5. Testing add points functionality...');
    const result = await pointsService.addPointsToUser(
      customer.id,
      staff.id,
      1,
      'Test QR code scan'
    );
    
    console.log('✅ Add points result:', result);
    
    // Verify points were added
    console.log('\n6. Verifying points were added...');
    const newPoints = await database.query('SELECT * FROM loyalty_points WHERE user_id = $1', [customer.id]);
    console.log(`New points for customer ${customer.id}:`, newPoints.rows);
    
    // Check transaction was recorded
    console.log('\n7. Checking transaction was recorded...');
    const transactions = await database.query(
      'SELECT * FROM point_transactions WHERE user_id = $1 ORDER BY transaction_date DESC LIMIT 1',
      [customer.id]
    );
    console.log(`Latest transaction for customer ${customer.id}:`, transactions.rows);
    
    console.log('\n✅ ALL TESTS PASSED!');
    
  } catch (error) {
    console.error('\n❌ TEST FAILED:');
    console.error('Error:', error.message);
    console.error('Stack:', error.stack);
  } finally {
    // Close database connection
    await database.close();
    console.log('\n===== TEST COMPLETED =====');
    process.exit(0);
  }
}

// Run the test
testAddPoints();
