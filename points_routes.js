const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Database connection (use your existing connection)
const pool = new Pool({
  // Your database configuration here
  // Don't hardcode credentials - use environment variables
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

// Middleware to verify JWT token (use your existing auth middleware)
const authenticateToken = (req, res, next) => {
  // Your existing JWT verification logic here
  // This should set req.user with the authenticated user info
  next();
};

// GET /points/user/:userId - Get loyalty points for a user
router.get('/user/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Verify user can access these points (either their own or staff)
    if (req.user.id != userId && !req.user.staff) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Access denied'
      });
    }

    // Get or create loyalty points record
    let result = await pool.query(
      'SELECT * FROM loyalty_points WHERE user_id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      // Create new loyalty points record with 0 points
      result = await pool.query(
        'INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, 0) RETURNING *',
        [userId]
      );
    }

    const points = result.rows[0];

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
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

// POST /points/add - Add points to a user
router.post('/add', authenticateToken, async (req, res) => {
  try {
    const { user_id, staff_user_id, points_amount, description } = req.body;

    // Only staff can add points
    if (!req.user.staff) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Only staff can add points'
      });
    }

    // Verify the staff_user_id matches the authenticated user
    if (req.user.id != staff_user_id) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Staff user ID mismatch'
      });
    }

    // Start transaction
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');

      // Get or create loyalty points record
      let pointsResult = await client.query(
        'SELECT * FROM loyalty_points WHERE user_id = $1',
        [user_id]
      );

      let currentPoints = 0;
      if (pointsResult.rows.length === 0) {
        // Create new record
        await client.query(
          'INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, $2)',
          [user_id, points_amount]
        );
        currentPoints = points_amount;
      } else {
        // Update existing record
        currentPoints = pointsResult.rows[0].current_points + points_amount;
        await client.query(
          'UPDATE loyalty_points SET current_points = $1, last_updated = NOW() WHERE user_id = $2',
          [currentPoints, user_id]
        );
      }

      // Record the transaction
      await client.query(
        'INSERT INTO point_transactions (user_id, scanned_by, points_amount, description) VALUES ($1, $2, $3, $4)',
        [user_id, staff_user_id, points_amount, description || 'QR code scan']
      );

      await client.query('COMMIT');

      res.json({
        return_code: 'SUCCESS',
        message: 'Points added successfully',
        new_total: currentPoints
      });
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Add points error:', error);
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
    
    // Verify user can access these transactions (either their own or staff)
    if (req.user.id != userId && !req.user.staff) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Access denied'
      });
    }

    const result = await pool.query(
      `SELECT pt.*, au.display_name as staff_name, au.email as staff_email 
       FROM point_transactions pt 
       LEFT JOIN app_user au ON pt.scanned_by = au.id 
       WHERE pt.user_id = $1 
       ORDER BY pt.transaction_date DESC 
       LIMIT 50`,
      [userId]
    );

    const transactions = result.rows.map(row => ({
      id: row.id,
      user_id: row.user_id,
      scanned_by: row.scanned_by,
      staff_name: row.staff_name || row.staff_email,
      points_amount: row.points_amount,
      description: row.description,
      transaction_date: row.transaction_date
    }));

    res.json({
      return_code: 'SUCCESS',
      transactions: transactions
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

// POST /points/can-scan - Check if QR code can be scanned (prevent duplicates)
router.post('/can-scan', authenticateToken, async (req, res) => {
  try {
    const { qr_code_data, staff_user_id } = req.body;

    // Only staff can check scan eligibility
    if (!req.user.staff) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Only staff can check scan eligibility'
      });
    }

    // Extract user ID from QR code
    const userIdMatch = qr_code_data.match(/^(\d+)_\d{5}$/);
    if (!userIdMatch) {
      return res.json({
        return_code: 'ERROR',
        message: 'Invalid QR code format',
        can_scan: false
      });
    }

    const userId = parseInt(userIdMatch[1]);

    // Check for recent scans (within last 30 seconds)
    const recentScanResult = await pool.query(
      `SELECT * FROM point_transactions 
       WHERE user_id = $1 AND scanned_by = $2 
       AND transaction_date > NOW() - INTERVAL '30 seconds'
       ORDER BY transaction_date DESC LIMIT 1`,
      [userId, staff_user_id]
    );

    const canScan = recentScanResult.rows.length === 0;

    res.json({
      return_code: 'SUCCESS',
      can_scan: canScan,
      message: canScan ? 'QR code can be scanned' : 'QR code scanned too recently'
    });
  } catch (error) {
    console.error('Can scan check error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
