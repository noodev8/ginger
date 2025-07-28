const database = require('./database');

class PointsService {
  
  /**
   * Get loyalty points for a user
   */
  async getUserPoints(userId) {
    try {
      console.log(`[POINTS_SERVICE] Getting points for user ${userId}`);
      
      let result = await database.query(
        'SELECT * FROM loyalty_points WHERE user_id = $1',
        [userId]
      );

      if (result.rows.length === 0) {
        console.log(`[POINTS_SERVICE] No points record found for user ${userId}, creating new record`);
        // Create new loyalty points record with 0 points
        result = await database.query(
          'INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, 0) RETURNING *',
          [userId]
        );
        console.log(`[POINTS_SERVICE] Created new points record:`, result.rows[0]);
      } else {
        console.log(`[POINTS_SERVICE] Found existing points record:`, result.rows[0]);
      }

      return result.rows[0];
    } catch (error) {
      console.error('[POINTS_SERVICE] Get user points error:', error.message);
      throw error;
    }
  }

  /**
   * Add points to a user (by staff) - supports negative amounts for deductions
   */
  async addPointsToUser(userId, staffUserId, pointsAmount, description = 'Points added by staff') {
    console.log(`[POINTS_SERVICE] Starting add points transaction - User: ${userId}, Staff: ${staffUserId}, Points: ${pointsAmount}`);

    const client = await database.getClient();

    try {
      await client.query('BEGIN');
      console.log('[POINTS_SERVICE] Transaction started');

      // Get or create loyalty points record
      let pointsResult = await client.query(
        'SELECT * FROM loyalty_points WHERE user_id = $1',
        [userId]
      );

      let currentPoints = 0;
      if (pointsResult.rows.length === 0) {
        console.log(`[POINTS_SERVICE] Creating new points record for user ${userId}`);
        // Create new record - ensure we don't create negative points for new users
        const initialPoints = Math.max(0, pointsAmount);
        await client.query(
          'INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, $2)',
          [userId, initialPoints]
        );
        currentPoints = initialPoints;
      } else {
        console.log(`[POINTS_SERVICE] Updating existing points record. Current: ${pointsResult.rows[0].current_points}`);
        // Update existing record
        currentPoints = pointsResult.rows[0].current_points + pointsAmount;
        // Ensure points don't go below 0
        currentPoints = Math.max(0, currentPoints);
        await client.query(
          'UPDATE loyalty_points SET current_points = $1, last_updated = NOW() WHERE user_id = $2',
          [currentPoints, userId]
        );
      }

      console.log(`[POINTS_SERVICE] New points total: ${currentPoints}`);

      // Record the transaction
      const transactionResult = await client.query(
        'INSERT INTO point_transactions (user_id, scanned_by, points_amount, description) VALUES ($1, $2, $3, $4) RETURNING *',
        [userId, staffUserId, pointsAmount, description]
      );

      console.log(`[POINTS_SERVICE] Transaction recorded:`, transactionResult.rows[0]);

      await client.query('COMMIT');
      console.log('[POINTS_SERVICE] Transaction committed successfully');

      return {
        success: true,
        new_total: currentPoints
      };
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('[POINTS_SERVICE] Transaction rolled back due to error:', error.message);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Get point transaction history for a user
   */
  async getPointTransactions(userId) {
    try {
      console.log(`[POINTS_SERVICE] Getting transaction history for user ${userId}`);
      
      const result = await database.query(
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

      console.log(`[POINTS_SERVICE] Found ${transactions.length} transactions`);
      return transactions;
    } catch (error) {
      console.error('[POINTS_SERVICE] Get transactions error:', error.message);
      throw error;
    }
  }


}

module.exports = new PointsService();
