const express = require('express');
const router = express.Router();
const { authenticateToken, requireStaffAdmin } = require('../middleware/auth_middleware');
const adminService = require('../services/admin_service');

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

module.exports = router;
