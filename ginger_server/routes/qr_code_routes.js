/*
=======================================================================================================================================
API Route: QR Code Routes
=======================================================================================================================================
Purpose: Handle QR code generation, validation, and management for loyalty system
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const qrCodeService = require('../services/qr_code_service');
const { authenticateToken, requireStaff, requireOwnershipOrStaff } = require('../middleware/auth_middleware');

/*
=======================================================================================================================================
API Route: /qr-codes/user/:userId
=======================================================================================================================================
Method: GET
Purpose: Get QR code for a specific user
=======================================================================================================================================
*/
router.get('/user/:userId', authenticateToken, requireOwnershipOrStaff('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    
    const qrCode = await qrCodeService.getUserQRCode(parseInt(userId));

    if (!qrCode) {
      return res.status(404).json({
        return_code: 'NOT_FOUND',
        message: 'QR code not found for this user'
      });
    }

    res.json({
      return_code: 'SUCCESS',
      qr_code: {
        id: qrCode.id,
        user_id: qrCode.user_id,
        qr_code_data: qrCode.qr_code_data
      }
    });
  } catch (error) {
    console.error('Get QR code error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /qr-codes
=======================================================================================================================================
Method: POST
Purpose: Create new QR code for a user
=======================================================================================================================================
*/
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { user_id, qr_code_data } = req.body;

    // Validate input
    if (!user_id || !qr_code_data) {
      return res.status(400).json({
        return_code: 'MISSING_REQUIRED_FIELDS',
        message: 'user_id and qr_code_data are required'
      });
    }

    // Check if user can create QR code for this user
    if (req.user.id !== user_id && !req.user.staff) {
      return res.status(403).json({
        return_code: 'ACCESS_DENIED',
        message: 'You can only create QR codes for yourself'
      });
    }

    const qrCode = await qrCodeService.createQRCode(user_id, qr_code_data);

    res.status(201).json({
      return_code: 'SUCCESS',
      message: 'QR code created successfully',
      qr_code: {
        id: qrCode.id,
        user_id: qrCode.user_id,
        qr_code_data: qrCode.qr_code_data
      }
    });
  } catch (error) {
    console.error('Create QR code error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /qr-codes/validate
=======================================================================================================================================
Method: POST
Purpose: Validate a scanned QR code (staff only)
=======================================================================================================================================
*/
router.post('/validate', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { qr_code_data } = req.body;

    if (!qr_code_data) {
      return res.status(400).json({
        return_code: 'MISSING_REQUIRED_FIELDS',
        message: 'qr_code_data is required'
      });
    }

    const validationResult = await qrCodeService.validateQRCode(qr_code_data);

    if (!validationResult) {
      return res.status(404).json({
        return_code: 'NOT_FOUND',
        message: 'QR code not found or invalid'
      });
    }

    res.json({
      return_code: 'SUCCESS',
      message: 'QR code validated successfully',
      user_id: validationResult.user_id,
      user_name: validationResult.user_name,
      qr_code_data: validationResult.qr_code_data
    });
  } catch (error) {
    console.error('Validate QR code error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
