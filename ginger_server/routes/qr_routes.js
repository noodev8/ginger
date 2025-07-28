const express = require('express');
const router = express.Router();
const qrService = require('../services/qr_service');
const { authenticateToken, requireStaff } = require('../middleware/auth_middleware');

/*
=======================================================================================================================================
API Route: /qr/user/:userId
=======================================================================================================================================
Method: GET
Purpose: Get QR code for a specific user
=======================================================================================================================================
*/
router.get('/user/:userId', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    
    if (isNaN(userId) || userId <= 0) {
      return res.status(400).json({
        return_code: 'INVALID_USER_ID',
        message: 'Invalid user ID'
      });
    }
    
    // Users can only get their own QR code, staff can get any user's QR code
    if (!req.user.staff && req.user.id !== userId) {
      return res.status(403).json({
        return_code: 'ACCESS_DENIED',
        message: 'You can only access your own QR code'
      });
    }
    
    const qrCode = await qrService.getUserQRCode(userId);
    
    res.json({
      return_code: 'SUCCESS',
      message: 'QR code retrieved successfully',
      qr_code: qrCode
    });
  } catch (error) {
    console.error('Get QR code error:', error);
    
    if (error.message === 'User not found') {
      return res.status(404).json({
        return_code: 'USER_NOT_FOUND',
        message: 'User not found'
      });
    }
    
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /qr/validate
=======================================================================================================================================
Method: POST
Purpose: Validate a scanned QR code - staff only
=======================================================================================================================================
*/
router.post('/validate', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { qr_code_data } = req.body;
    
    if (!qr_code_data) {
      return res.status(400).json({
        return_code: 'MISSING_QR_CODE',
        message: 'QR code data is required'
      });
    }
    
    const validation = await qrService.validateQRCode(qr_code_data);
    
    if (!validation) {
      return res.status(404).json({
        return_code: 'INVALID_QR_CODE',
        message: 'Invalid QR code or user not found'
      });
    }
    
    res.json({
      return_code: 'SUCCESS',
      message: 'QR code is valid',
      user: validation
    });
  } catch (error) {
    console.error('Validate QR code error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /qr/scan
=======================================================================================================================================
Method: POST
Purpose: Scan QR code and add points - staff only
=======================================================================================================================================
*/
router.post('/scan', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { qr_code_data } = req.body;
    const staffUserId = req.user.id;
    
    if (!qr_code_data) {
      return res.status(400).json({
        return_code: 'MISSING_QR_CODE',
        message: 'QR code data is required'
      });
    }
    
    const result = await qrService.scanQRCode(qr_code_data, staffUserId);
    
    if (result.success) {
      const response = {
        return_code: 'SUCCESS',
        message: result.message,
        user_name: result.user_name,
        new_total: result.new_total
      };

      // Add reward eligibility information if present
      if (result.reward_eligible !== undefined) {
        response.reward_eligible = result.reward_eligible;
        response.user_id = result.user_id;
        response.current_points = result.current_points;
      }

      res.json(response);
    } else {
      res.status(400).json({
        return_code: 'SCAN_FAILED',
        message: result.message
      });
    }
  } catch (error) {
    console.error('Scan QR code error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /qr/redeem-reward
=======================================================================================================================================
Method: POST
Purpose: Redeem reward (deduct 10 points, add 1 point for current scan) - staff only
=======================================================================================================================================
*/
router.post('/redeem-reward', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { user_id } = req.body;
    const staffUserId = req.user.id;

    if (!user_id) {
      return res.status(400).json({
        return_code: 'MISSING_USER_ID',
        message: 'user_id is required'
      });
    }

    const result = await qrService.redeemReward(user_id, staffUserId);

    if (result.success) {
      res.json({
        return_code: 'SUCCESS',
        message: result.message,
        new_total: result.new_total
      });
    } else {
      res.status(400).json({
        return_code: 'REDEEM_FAILED',
        message: result.message
      });
    }
  } catch (error) {
    console.error('Redeem reward error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
