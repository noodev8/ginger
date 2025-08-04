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

      // Get current points to check for reward eligibility
      const pointsService = require('./points_service');
      const rewardService = require('./reward_service');
      const currentPoints = await pointsService.getUserPoints(validation.user_id);
      const pointsTotal = currentPoints ? currentPoints.current_points : 0;

      console.log(`[QR_SERVICE] User ${validation.user_id} has ${pointsTotal} points`);

      // Check if user has enough points for any available rewards
      const availableRewards = await rewardService.getAvailableRewards(pointsTotal);
      if (availableRewards && availableRewards.length > 0) {
        console.log(`[QR_SERVICE] User eligible for ${availableRewards.length} reward(s)`);

        if (availableRewards.length === 1) {
          // Single reward - use existing logic
          const reward = availableRewards[0];
          console.log(`[QR_SERVICE] Single reward available: ${reward.name} (${reward.points_required} points)`);
          return {
            success: true,
            reward_eligible: true,
            user_id: validation.user_id,
            user_name: validation.user_name,
            current_points: pointsTotal,
            reward: reward,
            message: `${validation.user_name} has ${pointsTotal} points and is eligible for ${reward.name}!`
          };
        } else {
          // Multiple rewards - let staff choose
          console.log(`[QR_SERVICE] Multiple rewards available: ${availableRewards.map(r => `${r.name} (${r.points_required}pts)`).join(', ')}`);
          return {
            success: true,
            reward_eligible: true,
            multiple_rewards: true,
            user_id: validation.user_id,
            user_name: validation.user_name,
            current_points: pointsTotal,
            available_rewards: availableRewards,
            message: `${validation.user_name} has ${pointsTotal} points and can choose from ${availableRewards.length} rewards!`
          };
        }
      } else {
        // Add 1 point as normal
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
            reward_eligible: false,
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
      }
    } catch (error) {
      console.error('[QR_SERVICE] Scan QR code error:', error.message);
      return {
        success: false,
        message: 'Internal server error'
      };
    }
  }

  /**
   * Redeem reward (deduct points based on reward from database)
   */
  async redeemReward(userId, staffUserId) {
    try {
      console.log(`[QR_SERVICE] Processing reward redemption for user: ${userId} by staff: ${staffUserId}`);

      const pointsService = require('./points_service');
      const rewardService = require('./reward_service');

      // Get current points to verify eligibility
      const currentPoints = await pointsService.getUserPoints(userId);
      if (!currentPoints) {
        return {
          success: false,
          message: 'User points record not found'
        };
      }

      // Find the best available reward for the user's points
      const availableReward = await rewardService.getAvailableReward(currentPoints.current_points);
      if (!availableReward) {
        return {
          success: false,
          message: 'User does not have enough points for any reward'
        };
      }

      // Deduct points for the reward (no additional point for scan)
      const deductResult = await pointsService.addPointsToUser(
        userId,
        staffUserId,
        -availableReward.points_required,
        `${availableReward.name} reward redeemed`
      );

      if (deductResult.success) {
        console.log(`[QR_SERVICE] Successfully redeemed ${availableReward.name} for user ${userId}. New total: ${deductResult.new_total}`);
        return {
          success: true,
          message: `${availableReward.name} reward redeemed successfully!`,
          reward: availableReward,
          new_total: deductResult.new_total
        };
      } else {
        return {
          success: false,
          message: 'Failed to deduct points for reward'
        };
      }
    } catch (error) {
      console.error('[QR_SERVICE] Redeem reward error:', error.message);
      return {
        success: false,
        message: 'Internal server error'
      };
    }
  }

  /**
   * Redeem a specific reward by ID
   */
  async redeemSpecificReward(userId, staffUserId, rewardId) {
    try {
      console.log(`[QR_SERVICE] Processing specific reward redemption for user: ${userId}, reward: ${rewardId} by staff: ${staffUserId}`);

      const pointsService = require('./points_service');
      const rewardService = require('./reward_service');

      // Get current points to verify eligibility
      const currentPoints = await pointsService.getUserPoints(userId);
      if (!currentPoints) {
        return {
          success: false,
          message: 'User points record not found'
        };
      }

      // Get the specific reward
      const reward = await rewardService.getRewardById(rewardId);
      if (!reward) {
        return {
          success: false,
          message: 'Reward not found or inactive'
        };
      }

      // Check if user has enough points for this specific reward
      if (currentPoints.current_points < reward.points_required) {
        return {
          success: false,
          message: `User does not have enough points for ${reward.name}. Required: ${reward.points_required}, Available: ${currentPoints.current_points}`
        };
      }

      // Deduct points for the specific reward
      const deductResult = await pointsService.addPointsToUser(
        userId,
        staffUserId,
        -reward.points_required,
        `${reward.name} reward redeemed`
      );

      if (deductResult.success) {
        console.log(`[QR_SERVICE] Successfully redeemed ${reward.name} for user ${userId}. New total: ${deductResult.new_total}`);
        return {
          success: true,
          message: `${reward.name} reward redeemed successfully!`,
          reward: reward,
          new_total: deductResult.new_total
        };
      } else {
        return {
          success: false,
          message: 'Failed to deduct points for reward'
        };
      }
    } catch (error) {
      console.error('[QR_SERVICE] Redeem specific reward error:', error.message);
      return {
        success: false,
        message: 'Internal server error'
      };
    }
  }
}

module.exports = new QRService();
