const database = require('./database');

class QRCodeService {
  
  /**
   * Get QR code for a user
   */
  async getUserQRCode(userId) {
    try {
      const result = await database.query(
        'SELECT * FROM user_qr_codes WHERE user_id = $1',
        [userId]
      );

      if (result.rows.length === 0) {
        return null;
      }

      return result.rows[0];
    } catch (error) {
      console.error('Get user QR code error:', error.message);
      throw error;
    }
  }

  /**
   * Create QR code for a user
   */
  async createQRCode(userId, qrCodeData) {
    try {
      // Check if QR code already exists
      const existing = await this.getUserQRCode(userId);
      if (existing) {
        return existing;
      }

      // Create new QR code
      const result = await database.query(
        'INSERT INTO user_qr_codes (user_id, qr_code_data) VALUES ($1, $2) RETURNING *',
        [userId, qrCodeData]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Create QR code error:', error.message);
      throw error;
    }
  }

  /**
   * Validate a scanned QR code and return user info
   */
  async validateQRCode(qrCodeData) {
    try {
      const result = await database.query(
        `SELECT uqr.*, au.display_name, au.email 
         FROM user_qr_codes uqr 
         JOIN app_user au ON uqr.user_id = au.id 
         WHERE uqr.qr_code_data = $1`,
        [qrCodeData]
      );

      if (result.rows.length === 0) {
        return null;
      }

      const qrCode = result.rows[0];
      
      return {
        user_id: qrCode.user_id,
        user_name: qrCode.display_name || qrCode.email.split('@')[0],
        qr_code_data: qrCode.qr_code_data
      };
    } catch (error) {
      console.error('Validate QR code error:', error.message);
      throw error;
    }
  }

  /**
   * Validate QR code format (user_id_5digits)
   */
  isValidQRCodeFormat(qrCodeData) {
    const regex = /^\d+_\d{5}$/;
    return regex.test(qrCodeData);
  }

  /**
   * Extract user ID from QR code data
   */
  extractUserIdFromQRCode(qrCodeData) {
    const parts = qrCodeData.split('_');
    if (parts.length !== 2) {
      return null;
    }
    
    const userId = parseInt(parts[0]);
    return isNaN(userId) ? null : userId;
  }
}

module.exports = new QRCodeService();
