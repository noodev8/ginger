const database = require('./database');

class QRService {
  /**
   * Get or create QR code for a user (QR code data = user ID)
   */
  async getUserQRCode(userId) {
    try {
      console.log(`[QR_SERVICE] Getting QR code for user: ${userId}`);
      
      // Check if user exists
      const userResult = await database.query(
        'SELECT id, email, display_name FROM app_user WHERE id = $1',
        [userId]
      );
      
      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }
      
      const user = userResult.rows[0];
      
      // Check if QR code already exists
      let qrResult = await database.query(
        'SELECT * FROM user_qr_codes WHERE user_id = $1',
        [userId]
      );
      
      if (qrResult.rows.length === 0) {
        // Create new QR code (QR data = user ID)
        const qrCodeData = userId.toString();
        
        await database.query(
          'INSERT INTO user_qr_codes (user_id, qr_code_data) VALUES ($1, $2)',
          [userId, qrCodeData]
        );
        
        console.log(`[QR_SERVICE] Created new QR code for user ${userId}: ${qrCodeData}`);
        
        return {
          user_id: userId,
          qr_code_data: qrCodeData,
          user_name: user.display_name || user.email
        };
      } else {
        console.log(`[QR_SERVICE] Found existing QR code for user ${userId}: ${qrResult.rows[0].qr_code_data}`);
        
        return {
          user_id: userId,
          qr_code_data: qrResult.rows[0].qr_code_data,
          user_name: user.display_name || user.email
        };
      }
    } catch (error) {
      console.error('[QR_SERVICE] Get QR code error:', error.message);
      throw error;
    }
  }
  
  /**
   * Validate scanned QR code (check if user exists)
   */
  async validateQRCode(qrCodeData) {
    try {
      console.log(`[QR_SERVICE] Validating QR code: ${qrCodeData}`);
      
      // QR code data should be a user ID
      const userId = parseInt(qrCodeData);
      
      if (isNaN(userId) || userId <= 0) {
        console.log(`[QR_SERVICE] Invalid QR code format: ${qrCodeData}`);
        return null;
      }
      
      // Check if user exists and is not staff
      const userResult = await database.query(
        'SELECT id, email, display_name, staff FROM app_user WHERE id = $1',
        [userId]
      );
      
      if (userResult.rows.length === 0) {
        console.log(`[QR_SERVICE] User not found for QR code: ${qrCodeData}`);
        return null;
      }
      
      const user = userResult.rows[0];
      
      if (user.staff) {
        console.log(`[QR_SERVICE] Cannot scan staff member QR code: ${qrCodeData}`);
        return null;
      }
      
      console.log(`[QR_SERVICE] QR code validated for user: ${user.id} (${user.email})`);
      
      return {
        user_id: user.id,
        user_name: user.display_name || user.email,
        user_email: user.email
      };
    } catch (error) {
      console.error('[QR_SERVICE] Validate QR code error:', error.message);
      throw error;
    }
  }
  
  /**
   * Scan QR code and add points (complete flow)
   */
  async scanQRCode(qrCodeData, staffUserId) {
    try {
      console.log(`[QR_SERVICE] Processing QR scan: ${qrCodeData} by staff: ${staffUserId}`);
      
      // Validate QR code
      const validation = await this.validateQRCode(qrCodeData);
      if (!validation) {
        return {
          success: false,
          message: 'Invalid QR code or user not found'
        };
      }
      
      // Check for recent scans (prevent spam - 15 second cooldown)
      const recentScanResult = await database.query(
        `SELECT * FROM point_transactions
         WHERE user_id = $1 AND scanned_by = $2
         AND transaction_date > NOW() - INTERVAL '15 seconds'
         ORDER BY transaction_date DESC LIMIT 1`,
        [validation.user_id, staffUserId]
      );

      if (recentScanResult.rows.length > 0) {
        console.log(`[QR_SERVICE] Recent scan detected, blocking duplicate`);
        return {
          success: false,
          message: 'QR code scanned too recently. Please wait 15 seconds.'
        };
      }
      
      // Add points using existing points service
      const pointsService = require('./points_service');
      const result = await pointsService.addPointsToUser(
        validation.user_id,
        staffUserId,
        1,
        'QR code scan'
      );
      
      if (result.success) {
        console.log(`[QR_SERVICE] Successfully added 1 point to user ${validation.user_id}`);
        return {
          success: true,
          message: `Added 1 point to ${validation.user_name}`,
          user_name: validation.user_name,
          new_total: result.new_total
        };
      } else {
        return {
          success: false,
          message: 'Failed to add points'
        };
      }
    } catch (error) {
      console.error('[QR_SERVICE] Scan QR code error:', error.message);
      return {
        success: false,
        message: 'Internal server error'
      };
    }
  }
}

module.exports = new QRService();
