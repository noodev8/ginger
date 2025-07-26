require('dotenv').config();
const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testQRSystem() {
  try {
    console.log('🧪 Testing QR System\n');

    // Step 1: Login as staff
    console.log('1. Logging in as staff...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'staff@test.com',
      password: 'password123'
    });

    if (loginResponse.data.return_code !== 'SUCCESS') {
      console.log('❌ Login failed:', loginResponse.data);
      return;
    }

    const staffUser = loginResponse.data.user;
    const token = staffUser.auth_token;
    console.log(`✅ Logged in as: ${staffUser.email} (Staff: ${staffUser.staff})`);

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };

    // Step 2: Get a customer's QR code
    console.log('\n2. Getting customer QR code...');
    const customerId = 8; // Test with user ID 8
    
    const qrResponse = await axios.get(`${BASE_URL}/qr/user/${customerId}`, { headers });
    
    if (qrResponse.data.return_code !== 'SUCCESS') {
      console.log('❌ Failed to get QR code:', qrResponse.data);
      return;
    }

    const qrCode = qrResponse.data.qr_code;
    console.log(`✅ QR Code for customer ${customerId}:`, qrCode);

    // Step 3: Validate the QR code
    console.log('\n3. Validating QR code...');
    const validateResponse = await axios.post(`${BASE_URL}/qr/validate`, {
      qr_code_data: qrCode.qr_code_data
    }, { headers });

    if (validateResponse.data.return_code !== 'SUCCESS') {
      console.log('❌ QR validation failed:', validateResponse.data);
      return;
    }

    console.log('✅ QR code validated:', validateResponse.data.user);

    // Step 4: Scan the QR code (add points)
    console.log('\n4. Scanning QR code to add points...');
    const scanResponse = await axios.post(`${BASE_URL}/qr/scan`, {
      qr_code_data: qrCode.qr_code_data
    }, { headers });

    if (scanResponse.data.return_code === 'SUCCESS') {
      console.log('✅ QR scan successful!');
      console.log(`   Customer: ${scanResponse.data.user_name}`);
      console.log(`   Message: ${scanResponse.data.message}`);
      console.log(`   New total: ${scanResponse.data.new_total} points`);
    } else {
      console.log('❌ QR scan failed:', scanResponse.data);
    }

    // Step 5: Try scanning again (should fail due to cooldown)
    console.log('\n5. Testing cooldown (scanning again immediately)...');
    try {
      const scanResponse2 = await axios.post(`${BASE_URL}/qr/scan`, {
        qr_code_data: qrCode.qr_code_data
      }, { headers });

      if (scanResponse2.data.return_code === 'SCAN_FAILED') {
        console.log('✅ Cooldown working correctly:', scanResponse2.data.message);
      } else {
        console.log('⚠️ Unexpected result:', scanResponse2.data);
      }
    } catch (error) {
      if (error.response?.status === 400 && error.response?.data?.return_code === 'SCAN_FAILED') {
        console.log('✅ Cooldown working correctly:', error.response.data.message);
      } else {
        console.log('❌ Unexpected error:', error.response?.data || error.message);
      }
    }

    console.log('\n🎉 QR System test completed!');

  } catch (error) {
    console.error('❌ Test error:', {
      status: error.response?.status,
      statusText: error.response?.statusText,
      data: error.response?.data,
      message: error.message
    });
  }
}

testQRSystem();
