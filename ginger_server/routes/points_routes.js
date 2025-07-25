/*
=======================================================================================================================================
API Route: Points Routes
=======================================================================================================================================
Purpose: Handle loyalty points management including adding points, getting balances, and transaction history
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const pointsService = require('../services/points_service');
const { authenticateToken, requireStaff, requireOwnershipOrStaff } = require('../middleware/auth_middleware');

/*
=======================================================================================================================================
API Route: /points/user/:userId
=======================================================================================================================================
Method: GET
Purpose: Get loyalty points for a specific user
=======================================================================================================================================
*/
router.get('/user/:userId', authenticateToken, requireOwnershipOrStaff('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    
    const points = await pointsService.getUserPoints(parseInt(userId));

    res.json({
      return_code: 'SUCCESS',
      points: {
        id: points.id,
        user_id: points.user_id,
        current_points: points.current_points,
        last_updated: points.last_updated
      }
    });
  } catch (error) {
    console.error('Get user points error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /points/add
=======================================================================================================================================
Method: POST
Purpose: Add points to a user (staff only)
=======================================================================================================================================
*/
router.post('/add', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { user_id, staff_user_id, points_amount, description } = req.body;

    // Validate input
    if (!user_id || !staff_user_id || !points_amount) {
      return res.status(400).json({
        return_code: 'MISSING_REQUIRED_FIELDS',
        message: 'user_id, staff_user_id, and points_amount are required'
      });
    }

    // Verify the staff_user_id matches the authenticated user
    if (req.user.id !== staff_user_id) {
      return res.status(403).json({
        return_code: 'ACCESS_DENIED',
        message: 'Staff user ID mismatch'
      });
    }

    // Validate points amount
    if (points_amount <= 0 || !Number.isInteger(points_amount)) {
      return res.status(400).json({
        return_code: 'INVALID_INPUT',
        message: 'Points amount must be a positive integer'
      });
    }

    const result = await pointsService.addPointsToUser(
      user_id, 
      staff_user_id, 
      points_amount, 
      description || 'QR code scan'
    );

    res.json({
      return_code: 'SUCCESS',
      message: 'Points added successfully',
      new_total: result.new_total
    });
  } catch (error) {
    console.error('Add points error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /points/transactions/:userId
=======================================================================================================================================
Method: GET
Purpose: Get point transaction history for a user
=======================================================================================================================================
*/
router.get('/transactions/:userId', authenticateToken, requireOwnershipOrStaff('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    
    const transactions = await pointsService.getPointTransactions(parseInt(userId), limit);

    res.json({
      return_code: 'SUCCESS',
      transactions: transactions
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /points/can-scan
=======================================================================================================================================
Method: POST
Purpose: Check if QR code can be scanned (prevent duplicates) - staff only
=======================================================================================================================================
*/
router.post('/can-scan', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { qr_code_data, staff_user_id } = req.body;

    if (!qr_code_data || !staff_user_id) {
      return res.status(400).json({
        return_code: 'MISSING_REQUIRED_FIELDS',
        message: 'qr_code_data and staff_user_id are required'
      });
    }

    // Verify the staff_user_id matches the authenticated user
    if (req.user.id !== staff_user_id) {
      return res.status(403).json({
        return_code: 'ACCESS_DENIED',
        message: 'Staff user ID mismatch'
      });
    }

    const result = await pointsService.canScanQRCode(qr_code_data, staff_user_id);

    res.json({
      return_code: 'SUCCESS',
      can_scan: result.can_scan,
      message: result.message
    });
  } catch (error) {
    console.error('Can scan check error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
