const express = require('express');
const router = express.Router();
const { authenticateToken, requireStaffAdmin } = require('../middleware/auth_middleware');
const adminService = require('../services/admin_service');
const rewardService = require('../services/reward_service');

/*
=======================================================================================================================================
API Route: /admin/staff
=======================================================================================================================================
Method: GET
Purpose: Get all staff members (admin only)
=======================================================================================================================================
*/
router.get('/staff', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    console.log('[AdminRoutes] Getting all staff members');
    
    const staff = await adminService.getAllStaff();
    
    res.json({
      return_code: 'SUCCESS',
      message: 'Staff members retrieved successfully',
      staff: staff
    });
  } catch (error) {
    console.error('[AdminRoutes] Error getting staff members:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /admin/analytics
=======================================================================================================================================
Method: GET
Purpose: Get customer analytics and statistics (admin only)
=======================================================================================================================================
*/
router.get('/analytics', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    console.log('[AdminRoutes] Getting customer analytics');
    
    const analytics = await adminService.getCustomerAnalytics();
    
    res.json({
      return_code: 'SUCCESS',
      message: 'Analytics retrieved successfully',
      analytics: analytics
    });
  } catch (error) {
    console.error('[AdminRoutes] Error getting analytics:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /admin/transactions
=======================================================================================================================================
Method: GET
Purpose: Get recent point transactions (admin only)
=======================================================================================================================================
*/
router.get('/transactions', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    console.log('[AdminRoutes] Getting recent transactions');
    
    const limit = parseInt(req.query.limit) || 20;
    const transactions = await adminService.getRecentTransactions(limit);
    
    res.json({
      return_code: 'SUCCESS',
      message: 'Transactions retrieved successfully',
      transactions: transactions
    });
  } catch (error) {
    console.error('[AdminRoutes] Error getting transactions:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /admin/dashboard
=======================================================================================================================================
Method: GET
Purpose: Get all dashboard data in one request (admin only)
=======================================================================================================================================
*/
router.get('/dashboard', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    console.log('[AdminRoutes] Getting dashboard data');
    
    const [staff, analytics, transactions] = await Promise.all([
      adminService.getAllStaff(),
      adminService.getCustomerAnalytics(),
      adminService.getRecentTransactions(10)
    ]);
    
    res.json({
      return_code: 'SUCCESS',
      message: 'Dashboard data retrieved successfully',
      dashboard: {
        staff: staff,
        analytics: analytics,
        recent_transactions: transactions
      }
    });
  } catch (error) {
    console.error('[AdminRoutes] Error getting dashboard data:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /admin/rewards
=======================================================================================================================================
Method: GET
Purpose: Get all rewards (including inactive ones) for admin management
=======================================================================================================================================
*/
router.get('/rewards', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    console.log('[AdminRoutes] Getting all rewards for management');

    const rewards = await rewardService.getAllRewards();

    res.json({
      return_code: 'SUCCESS',
      message: 'Rewards retrieved successfully',
      rewards: rewards
    });
  } catch (error) {
    console.error('[AdminRoutes] Error getting rewards:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /admin/rewards
=======================================================================================================================================
Method: POST
Purpose: Create a new reward
=======================================================================================================================================
*/
router.post('/rewards', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    const { name, description, points_required } = req.body;

    if (!name || !points_required || points_required < 1) {
      return res.status(400).json({
        return_code: 'INVALID_DATA',
        message: 'Name and valid points_required are required'
      });
    }

    console.log(`[AdminRoutes] Creating new reward: ${name} (${points_required} points)`);

    const reward = await rewardService.createReward(name, description, parseInt(points_required));

    res.json({
      return_code: 'SUCCESS',
      message: 'Reward created successfully',
      reward: reward
    });
  } catch (error) {
    console.error('[AdminRoutes] Error creating reward:', error);

    // Return specific error messages for validation errors
    if (error.message.includes('required') || error.message.includes('must be')) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: error.message
      });
    }

    if (error.message.includes('already exists')) {
      return res.status(409).json({
        return_code: 'DUPLICATE_ERROR',
        message: error.message
      });
    }

    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to create reward. Please try again.'
    });
  }
});

/*
=======================================================================================================================================
API Route: /admin/rewards/:id
=======================================================================================================================================
Method: PUT
Purpose: Update an existing reward
=======================================================================================================================================
*/
router.put('/rewards/:id', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, points_required, is_active } = req.body;

    if (!name || !points_required || points_required < 1) {
      return res.status(400).json({
        return_code: 'INVALID_DATA',
        message: 'Name and valid points_required are required'
      });
    }

    console.log(`[AdminRoutes] Updating reward ID: ${id}`);

    const reward = await rewardService.updateReward(
      parseInt(id),
      name,
      description,
      parseInt(points_required),
      is_active !== false
    );

    if (!reward) {
      return res.status(404).json({
        return_code: 'NOT_FOUND',
        message: 'Reward not found'
      });
    }

    res.json({
      return_code: 'SUCCESS',
      message: 'Reward updated successfully',
      reward: reward
    });
  } catch (error) {
    console.error('[AdminRoutes] Error updating reward:', error);

    // Return specific error messages for validation errors
    if (error.message.includes('required') || error.message.includes('must be') || error.message.includes('Invalid')) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: error.message
      });
    }

    if (error.message.includes('already exists')) {
      return res.status(409).json({
        return_code: 'DUPLICATE_ERROR',
        message: error.message
      });
    }

    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to update reward. Please try again.'
    });
  }
});

/*
=======================================================================================================================================
API Route: /admin/rewards/:id
=======================================================================================================================================
Method: DELETE
Purpose: Delete (deactivate) a reward
=======================================================================================================================================
*/
router.delete('/rewards/:id', authenticateToken, requireStaffAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    console.log(`[AdminRoutes] Deleting reward ID: ${id}`);

    const reward = await rewardService.deleteReward(parseInt(id));

    if (!reward) {
      return res.status(404).json({
        return_code: 'NOT_FOUND',
        message: 'Reward not found'
      });
    }

    res.json({
      return_code: 'SUCCESS',
      message: 'Reward deleted successfully',
      reward: reward
    });
  } catch (error) {
    console.error('[AdminRoutes] Error deleting reward:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
