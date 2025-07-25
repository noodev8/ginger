const database = require('./database');

class PointsService {
  
  /**
   * Get loyalty points for a user
   */
  async getUserPoints(userId) {
    try {
      let result = await database.query(
        'SELECT * FROM loyalty_points WHERE user_id = $1',
        [userId]
      );

      if (result.rows.length === 0) {
        // Create new loyalty points record with 0 points
        result = await database.query(
          'INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, 0) RETURNING *',
          [userId]
        );
      }

      return result.rows[0];
    } catch (error) {
      console.error('Get user points error:', error.message);
      throw error;
    }
  }

  /**
   * Add points to a user (when QR code is scanned by staff)
   */
  async addPointsToUser(userId, staffUserId, pointsAmount, description = 'QR code scan') {
    const client = await database.getClient();
    
    try {
      await client.query('BEGIN');

      // Get or create loyalty points record
      let pointsResult = await client.query(
        'SELECT * FROM loyalty_points WHERE user_id = $1',
        [userId]
      );

      let currentPoints = 0;
      if (pointsResult.rows.length === 0) {
        // Create new record
        await client.query(
          'INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, $2)',
          [userId, pointsAmount]
        );
        currentPoints = pointsAmount;
      } else {
        // Update existing record
        currentPoints = pointsResult.rows[0].current_points + pointsAmount;
        await client.query(
          'UPDATE loyalty_points SET current_points = $1, last_updated = NOW() WHERE user_id = $2',
          [currentPoints, userId]
        );
      }

      // Record the transaction
      await client.query(
        'INSERT INTO point_transactions (user_id, scanned_by, points_amount, description) VALUES ($1, $2, $3, $4)',
        [userId, staffUserId, pointsAmount, description]
      );

      await client.query('COMMIT');

      return {
        success: true,
        new_total: currentPoints
      };
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Add points error:', error.message);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Get point transaction history for a user
   */
  async getPointTransactions(userId, limit = 50) {
    try {
      const result = await database.query(
        `SELECT pt.*, au.display_name as staff_name, au.email as staff_email 
         FROM point_transactions pt 
         LEFT JOIN app_user au ON pt.scanned_by = au.id 
         WHERE pt.user_id = $1 
         ORDER BY pt.transaction_date DESC 
         LIMIT $2`,
        [userId, limit]
      );

      return result.rows.map(row => ({
        id: row.id,
        user_id: row.user_id,
        scanned_by: row.scanned_by,
        staff_name: row.staff_name || row.staff_email,
        points_amount: row.points_amount,
        description: row.description,
        transaction_date: row.transaction_date
      }));
    } catch (error) {
      console.error('Get point transactions error:', error.message);
      throw error;
    }
  }

  /**
   * Check if a QR code can be scanned (prevent duplicates)
   */
  async canScanQRCode(qrCodeData, staffUserId) {
    try {
      // Extract user ID from QR code
      const userIdMatch = qrCodeData.match(/^(\d+)_\d{5}$/);
      if (!userIdMatch) {
        return {
          can_scan: false,
          message: 'Invalid QR code format'
        };
      }

      const userId = parseInt(userIdMatch[1]);

      // Check for recent scans (within last 30 seconds)
      const recentScanResult = await database.query(
        `SELECT * FROM point_transactions 
         WHERE user_id = $1 AND scanned_by = $2 
         AND transaction_date > NOW() - INTERVAL '30 seconds'
         ORDER BY transaction_date DESC LIMIT 1`,
        [userId, staffUserId]
      );

      const canScan = recentScanResult.rows.length === 0;

      return {
        can_scan: canScan,
        message: canScan ? 'QR code can be scanned' : 'QR code scanned too recently'
      };
    } catch (error) {
      console.error('Can scan check error:', error.message);
      throw error;
    }
  }
}

module.exports = new PointsService();
