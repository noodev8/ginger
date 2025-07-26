const database = require('./database');

class QRCodeService {
  
  /**
   * Get QR code for a user
   */
  async getUserQRCode(userId) {
    try {
      console.log(`[QR_CODE_SERVICE] Getting QR code for user ${userId}`);
      
      const result = await database.query(
        'SELECT * FROM user_qr_codes WHERE user_id = $1',
        [userId]
      );

      if (result.rows.length === 0) {
        console.log(`[QR_CODE_SERVICE] No QR code found for user ${userId}`);
        return null;
      }

      console.log(`[QR_CODE_SERVICE] Found QR code for user ${userId}:`, result.rows[0].qr_code_data);
      return result.rows[0];
    } catch (error) {
      console.error('[QR_CODE_SERVICE] Get user QR code error:', error.message);
      throw error;
    }
  }

  /**
   * Create QR code for a user
   */
  async createQRCode(userId, qrCodeData) {
    try {
      console.log(`[QR_CODE_SERVICE] Creating QR code for user ${userId}: ${qrCodeData}`);
      
      // Check if QR code already exists
      const existing = await this.getUserQRCode(userId);
      if (existing) {
        console.log(`[QR_CODE_SERVICE] QR code already exists for user ${userId}, returning existing`);
        return existing;
      }

      // Create new QR code
      const result = await database.query(
        'INSERT INTO user_qr_codes (user_id, qr_code_data) VALUES ($1, $2) RETURNING *',
        [userId, qrCodeData]
      );

      console.log(`[QR_CODE_SERVICE] Successfully created QR code:`, result.rows[0]);
      return result.rows[0];
    } catch (error) {
      console.error('[QR_CODE_SERVICE] Create QR code error:', error.message);
      throw error;
    }
  }

  /**
   * Validate a scanned QR code and return user info
   */
  async validateQRCode(qrCodeData) {
    try {
      console.log(`[QR_CODE_SERVICE] Validating QR code: ${qrCodeData}`);
      
      // First validate format
      if (!this.isValidQRCodeFormat(qrCodeData)) {
        console.log(`[QR_CODE_SERVICE] Invalid QR code format: ${qrCodeData}`);
        return null;
      }

      const result = await database.query(
        `SELECT uqr.*, au.display_name, au.email 
         FROM user_qr_codes uqr 
         JOIN app_user au ON uqr.user_id = au.id 
         WHERE uqr.qr_code_data = $1`,
        [qrCodeData]
      );

      if (result.rows.length === 0) {
        console.log(`[QR_CODE_SERVICE] QR code not found in database: ${qrCodeData}`);
        return null;
      }

      const qrCode = result.rows[0];
      console.log(`[QR_CODE_SERVICE] Found QR code for user ${qrCode.user_id} (${qrCode.display_name || qrCode.email})`);
      
      return {
        user_id: qrCode.user_id,
        user_name: qrCode.display_name || qrCode.email.split('@')[0],
        qr_code_data: qrCode.qr_code_data
      };
    } catch (error) {
      console.error('[QR_CODE_SERVICE] Validate QR code error:', error.message);
      throw error;
    }
  }

  /**
   * Validate QR code format (user_id_5digits)
   */
  isValidQRCodeFormat(qrCodeData) {
    const regex = /^\d+_\d{5}$/;
    const isValid = regex.test(qrCodeData);
    console.log(`[QR_CODE_SERVICE] Format validation for ${qrCodeData}: ${isValid}`);
    return isValid;
  }
}

module.exports = new QRCodeService();
