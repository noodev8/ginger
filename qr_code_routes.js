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

// GET /qr-codes/user/:userId - Get QR code for a user
router.get('/user/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Verify user can access this QR code (either their own or staff)
    if (req.user.id != userId && !req.user.staff) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Access denied'
      });
    }

    const result = await pool.query(
      'SELECT * FROM user_qr_codes WHERE user_id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        return_code: 'ERROR',
        message: 'QR code not found'
      });
    }

    res.json({
      return_code: 'SUCCESS',
      qr_code: {
        id: result.rows[0].id,
        user_id: result.rows[0].user_id,
        qr_code_data: result.rows[0].qr_code_data
      }
    });
  } catch (error) {
    console.error('Get QR code error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

// POST /qr-codes - Create new QR code
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { user_id, qr_code_data } = req.body;

    // Verify user can create QR code for this user
    if (req.user.id != user_id && !req.user.staff) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Access denied'
      });
    }

    // Check if QR code already exists
    const existingResult = await pool.query(
      'SELECT * FROM user_qr_codes WHERE user_id = $1',
      [user_id]
    );

    if (existingResult.rows.length > 0) {
      return res.json({
        return_code: 'SUCCESS',
        qr_code: {
          id: existingResult.rows[0].id,
          user_id: existingResult.rows[0].user_id,
          qr_code_data: existingResult.rows[0].qr_code_data
        }
      });
    }

    // Create new QR code
    const result = await pool.query(
      'INSERT INTO user_qr_codes (user_id, qr_code_data) VALUES ($1, $2) RETURNING *',
      [user_id, qr_code_data]
    );

    res.status(201).json({
      return_code: 'SUCCESS',
      qr_code: {
        id: result.rows[0].id,
        user_id: result.rows[0].user_id,
        qr_code_data: result.rows[0].qr_code_data
      }
    });
  } catch (error) {
    console.error('Create QR code error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

// POST /qr-codes/validate - Validate a scanned QR code
router.post('/validate', authenticateToken, async (req, res) => {
  try {
    const { qr_code_data } = req.body;

    // Only staff can validate QR codes
    if (!req.user.staff) {
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Only staff can validate QR codes'
      });
    }

    // Find QR code in database
    const qrResult = await pool.query(
      'SELECT uqr.*, au.display_name, au.email FROM user_qr_codes uqr JOIN app_user au ON uqr.user_id = au.id WHERE uqr.qr_code_data = $1',
      [qr_code_data]
    );

    if (qrResult.rows.length === 0) {
      return res.status(404).json({
        return_code: 'ERROR',
        message: 'QR code not found'
      });
    }

    const qrCode = qrResult.rows[0];
    
    res.json({
      return_code: 'SUCCESS',
      user_id: qrCode.user_id,
      user_name: qrCode.display_name || qrCode.email.split('@')[0],
      qr_code_data: qrCode.qr_code_data,
      message: 'QR code validated successfully'
    });
  } catch (error) {
    console.error('Validate QR code error:', error);
    res.status(500).json({
      return_code: 'ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
