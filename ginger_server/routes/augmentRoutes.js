/*
=======================================================================================================================================
API Route: Augment Routes
=======================================================================================================================================
Purpose: Handle Augment API integration endpoints
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const augmentController = require('../controllers/augmentController');

// Existing endpoints (keeping original format for backward compatibility)
router.post('/analyze', augmentController.analyzeInput);
router.get('/health', augmentController.healthCheck);
router.get('/info', augmentController.getServiceInfo);

/*
=======================================================================================================================================
API Route: /augment/test
=======================================================================================================================================
Method: POST
Purpose: Test endpoint for Augment API integration
=======================================================================================================================================
Request Payload:
{
  "message": "test message"                // string, optional
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Augment API test successful",
  "data": {
    "timestamp": "2024-01-01T00:00:00Z",  // string, current timestamp
    "status": "active"                     // string, service status
  }
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"SERVER_ERROR"
=======================================================================================================================================
*/
router.post('/test', augmentController.test);

module.exports = router;
