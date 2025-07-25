/*
=======================================================================================================================================
Test Script: Add Points API Endpoint
=======================================================================================================================================
Purpose: Test the /points/add API endpoint directly to debug issues
=======================================================================================================================================
*/

const http = require('http');

// Configuration - update these values based on your setup
const API_BASE_URL = 'http://localhost:3000';
const TEST_CUSTOMER_ID = 1; // Update with actual customer ID
const TEST_STAFF_ID = 2;    // Update with actual staff ID
const TEST_AUTH_TOKEN = 'your_jwt_token_here'; // Update with actual JWT token

async function testAddPointsAPI() {
  console.log('===== TESTING ADD POINTS API ENDPOINT =====');
  
  const postData = JSON.stringify({
    user_id: TEST_CUSTOMER_ID,
    staff_user_id: TEST_STAFF_ID,
    points_amount: 1,
    description: 'Test API call'
  });
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/points/add',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      'Authorization': `Bearer ${TEST_AUTH_TOKEN}`
    }
  };
  
  console.log('Request options:', options);
  console.log('Request body:', postData);
  
  const req = http.request(options, (res) => {
    console.log(`\nResponse status: ${res.statusCode}`);
    console.log('Response headers:', res.headers);
    
    let responseBody = '';
    
    res.on('data', (chunk) => {
      responseBody += chunk;
    });
    
    res.on('end', () => {
      console.log('\nResponse body:', responseBody);
      
      try {
        const parsedResponse = JSON.parse(responseBody);
        console.log('Parsed response:', parsedResponse);
        
        if (parsedResponse.return_code === 'SUCCESS') {
          console.log('✅ API call successful!');
          console.log(`New total points: ${parsedResponse.new_total}`);
          console.log(`Customer: ${parsedResponse.customer_name}`);
          console.log(`Staff: ${parsedResponse.staff_name}`);
        } else {
          console.log('❌ API call failed:', parsedResponse.message);
        }
      } catch (parseError) {
        console.log('❌ Failed to parse response as JSON:', parseError.message);
      }
      
      console.log('\n===== API TEST COMPLETED =====');
    });
  });
  
  req.on('error', (error) => {
    console.error('❌ Request error:', error.message);
    console.log('\n===== API TEST FAILED =====');
  });
  
  req.on('timeout', () => {
    console.error('❌ Request timeout');
    req.destroy();
    console.log('\n===== API TEST TIMED OUT =====');
  });
  
  // Set timeout
  req.setTimeout(10000); // 10 seconds
  
  // Send the request
  req.write(postData);
  req.end();
}

console.log('To use this test script:');
console.log('1. Update TEST_CUSTOMER_ID, TEST_STAFF_ID, and TEST_AUTH_TOKEN variables');
console.log('2. Make sure your server is running on localhost:3000');
console.log('3. Run: node test_api_add_points.js');
console.log('');

// Uncomment the line below to run the test (after updating the variables above)
// testAddPointsAPI();
