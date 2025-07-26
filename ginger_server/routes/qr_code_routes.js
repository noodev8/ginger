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

// Debug logging middleware
router.use((req, res, next) => {
  console.log(`[QR_CODE API] ${req.method} ${req.path}`, {
    body: req.body,
    params: req.params,
    user: req.user ? { id: req.user.id, staff: req.user.staff } : 'none'
  });
  next();
});

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
    console.log(`[QR_CODE] Getting QR code for user ${userId}`);
    
    const qrCode = await qrCodeService.getUserQRCode(parseInt(userId));

    if (!qrCode) {
      console.log(`[QR_CODE] No QR code found for user ${userId}`);
      return res.status(404).json({
        return_code: 'ERROR',
        message: 'QR code not found for this user'
      });
    }

    console.log(`[QR_CODE] Found QR code for user ${userId}:`, qrCode.qr_code_data);
    res.json({
      return_code: 'SUCCESS',
      qr_code: {
        id: qrCode.id,
        user_id: qrCode.user_id,
        qr_code_data: qrCode.qr_code_data
      }
    });
  } catch (error) {
    console.error('[QR_CODE] Get QR code error:', error);
    res.status(500).json({
      return_code: 'ERROR',
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
    console.log(`[QR_CODE] Creating QR code for user ${user_id}: ${qr_code_data}`);

    // Validate input
    if (!user_id || !qr_code_data) {
      console.log('[QR_CODE] Missing required fields for QR code creation');
      return res.status(400).json({
        return_code: 'ERROR',
        message: 'user_id and qr_code_data are required'
      });
    }

    // Check if user can create QR code for this user
    if (req.user.id !== user_id && !req.user.staff) {
      console.log(`[QR_CODE] Access denied - user ${req.user.id} trying to create QR for ${user_id}`);
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'You can only create QR codes for yourself'
      });
    }

    const qrCode = await qrCodeService.createQRCode(user_id, qr_code_data);
    console.log(`[QR_CODE] Successfully created/retrieved QR code:`, qrCode);

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
    console.error('[QR_CODE] Create QR code error:', error);
    res.status(500).json({
      return_code: 'ERROR',
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
    console.log(`[QR_CODE] Validating QR code: ${qr_code_data}`);

    if (!qr_code_data) {
      console.log('[QR_CODE] Missing qr_code_data in request');
      return res.status(400).json({
        return_code: 'ERROR',
        message: 'qr_code_data is required'
      });
    }

    const validationResult = await qrCodeService.validateQRCode(qr_code_data);
    console.log('[QR_CODE] Validation result:', validationResult);

    if (!validationResult) {
      console.log('[QR_CODE] QR code not found in database');
      return res.status(404).json({
        return_code: 'ERROR',
        message: 'QR code not found or invalid'
      });
    }

    console.log(`[QR_CODE] Successfully validated QR code for user ${validationResult.user_id}`);
    res.json({
      return_code: 'SUCCESS',
      message: 'QR code validated successfully',
      user_id: validationResult.user_id,
      user_name: validationResult.user_name,
      qr_code_data: validationResult.qr_code_data
    });
  } catch (error) {
    console.error('[QR_CODE] Validate QR code error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
