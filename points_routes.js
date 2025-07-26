const express = require('express');
const router = express.Router();
const pointsService = require('../services/points_service');
const { authenticateToken, requireStaff } = require('../middleware/auth_middleware');

// Debug logging middleware
router.use((req, res, next) => {
  console.log(`[POINTS API] ${req.method} ${req.path}`, {
    body: req.body,
    params: req.params,
    user: req.user ? { id: req.user.id, staff: req.user.staff } : 'none'
  });
  next();
});

// GET /points/user/:userId - Get loyalty points for a user
router.get('/user/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`[POINTS] Getting points for user ${userId}`);
    
    // Verify user can access these points (either their own or staff)
    if (req.user.id != userId && !req.user.staff) {
      console.log(`[POINTS] Access denied - user ${req.user.id} trying to access ${userId}`);
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Access denied'
      });
    }

    const points = await pointsService.getUserPoints(parseInt(userId));
    console.log(`[POINTS] Retrieved points for user ${userId}:`, points);

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
    console.error('[POINTS] Get user points error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

// POST /points/add - Add points to a user
router.post('/add', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { user_id, staff_user_id, points_amount, description } = req.body;
    console.log(`[POINTS] Adding ${points_amount} points to user ${user_id} by staff ${staff_user_id}`);

    // Validate input
    if (!user_id || !staff_user_id || !points_amount) {
      console.log('[POINTS] Missing required fields');
      return res.status(400).json({
        return_code: 'ERROR',
        message: 'user_id, staff_user_id, and points_amount are required'
      });
    }

    // Verify the staff_user_id matches the authenticated user
    if (req.user.id != staff_user_id) {
      console.log(`[POINTS] Staff ID mismatch - auth: ${req.user.id}, provided: ${staff_user_id}`);
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Staff user ID mismatch'
      });
    }

    const result = await pointsService.addPointsToUser(
      user_id, 
      staff_user_id, 
      points_amount, 
      description || 'QR code scan'
    );

    console.log(`[POINTS] Successfully added points. New total: ${result.new_total}`);

    res.json({
      return_code: 'SUCCESS',
      message: 'Points added successfully',
      new_total: result.new_total
    });
  } catch (error) {
    console.error('[POINTS] Add points error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

// POST /points/can-scan - Check if QR code can be scanned (prevent duplicates)
router.post('/can-scan', authenticateToken, requireStaff, async (req, res) => {
  try {
    const { qr_code_data, staff_user_id } = req.body;
    console.log(`[POINTS] Checking if QR code can be scanned: ${qr_code_data} by staff ${staff_user_id}`);

    if (!qr_code_data || !staff_user_id) {
      console.log('[POINTS] Missing required fields for can-scan');
      return res.status(400).json({
        return_code: 'ERROR',
        message: 'qr_code_data and staff_user_id are required'
      });
    }

    // Verify the staff_user_id matches the authenticated user
    if (req.user.id != staff_user_id) {
      console.log(`[POINTS] Staff ID mismatch in can-scan - auth: ${req.user.id}, provided: ${staff_user_id}`);
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Staff user ID mismatch'
      });
    }

    const result = await pointsService.canScanQRCode(qr_code_data, staff_user_id);
    console.log(`[POINTS] Can scan result:`, result);

    res.json({
      return_code: 'SUCCESS',
      can_scan: result.can_scan,
      message: result.message
    });
  } catch (error) {
    console.error('[POINTS] Can scan check error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

// GET /points/transactions/:userId - Get point transaction history
router.get('/transactions/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`[POINTS] Getting transactions for user ${userId}`);
    
    // Verify user can access these transactions (either their own or staff)
    if (req.user.id != userId && !req.user.staff) {
      console.log(`[POINTS] Access denied for transactions - user ${req.user.id} trying to access ${userId}`);
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Access denied'
      });
    }

    const transactions = await pointsService.getPointTransactions(parseInt(userId));
    console.log(`[POINTS] Retrieved ${transactions.length} transactions for user ${userId}`);

    res.json({
      return_code: 'SUCCESS',
      transactions: transactions
    });
  } catch (error) {
    console.error('[POINTS] Get transactions error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;

