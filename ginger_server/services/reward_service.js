const database = require('./database');

class RewardService {
  
  /**
   * Get all active rewards
   */
  async getActiveRewards() {
    try {
      console.log('[REWARD_SERVICE] Getting all active rewards');
      
      const result = await database.query(
        'SELECT * FROM rewards WHERE is_active = true ORDER BY points_required ASC',
        []
      );

      console.log(`[REWARD_SERVICE] Found ${result.rows.length} active rewards`);
      return result.rows;
    } catch (error) {
      console.error('[REWARD_SERVICE] Get active rewards error:', error.message);
      throw error;
    }
  }

  /**
   * Get the first available reward that the user can afford
   */
  async getAvailableReward(userPoints) {
    try {
      console.log(`[REWARD_SERVICE] Finding available reward for ${userPoints} points`);
      
      const result = await database.query(
        'SELECT * FROM rewards WHERE is_active = true AND points_required <= $1 ORDER BY points_required ASC LIMIT 1',
        [userPoints]
      );

      if (result.rows.length > 0) {
        console.log(`[REWARD_SERVICE] Found available reward: ${result.rows[0].name} (${result.rows[0].points_required} points)`);
        return result.rows[0];
      } else {
        console.log(`[REWARD_SERVICE] No available rewards for ${userPoints} points`);
        return null;
      }
    } catch (error) {
      console.error('[REWARD_SERVICE] Get available reward error:', error.message);
      throw error;
    }
  }

  /**
   * Get a specific reward by ID
   */
  async getRewardById(rewardId) {
    try {
      console.log(`[REWARD_SERVICE] Getting reward by ID: ${rewardId}`);

      const result = await database.query(
        'SELECT * FROM rewards WHERE id = $1 AND is_active = true',
        [rewardId]
      );

      if (result.rows.length > 0) {
        console.log(`[REWARD_SERVICE] Found reward: ${result.rows[0].name}`);
        return result.rows[0];
      } else {
        console.log(`[REWARD_SERVICE] Reward not found or inactive: ${rewardId}`);
        return null;
      }
    } catch (error) {
      console.error('[REWARD_SERVICE] Get reward by ID error:', error.message);
      throw error;
    }
  }

  /**
   * Get all rewards (including inactive ones) - Admin only
   */
  async getAllRewards() {
    try {
      console.log('[REWARD_SERVICE] Getting all rewards for admin');

      const result = await database.query(
        'SELECT * FROM rewards ORDER BY points_required ASC, created_at DESC',
        []
      );

      console.log(`[REWARD_SERVICE] Found ${result.rows.length} total rewards`);
      return result.rows;
    } catch (error) {
      console.error('[REWARD_SERVICE] Get all rewards error:', error.message);
      throw error;
    }
  }

  /**
   * Create a new reward - Admin only
   */
  async createReward(name, description, pointsRequired) {
    try {
      console.log(`[REWARD_SERVICE] Creating new reward: ${name} (${pointsRequired} points)`);

      const result = await database.query(
        'INSERT INTO rewards (name, description, points_required) VALUES ($1, $2, $3) RETURNING *',
        [name, description, pointsRequired]
      );

      console.log(`[REWARD_SERVICE] Created reward with ID: ${result.rows[0].id}`);
      return result.rows[0];
    } catch (error) {
      console.error('[REWARD_SERVICE] Create reward error:', error.message);
      throw error;
    }
  }

  /**
   * Update an existing reward - Admin only
   */
  async updateReward(rewardId, name, description, pointsRequired, isActive) {
    try {
      console.log(`[REWARD_SERVICE] Updating reward ID: ${rewardId}`);

      const result = await database.query(
        'UPDATE rewards SET name = $1, description = $2, points_required = $3, is_active = $4, updated_at = NOW() WHERE id = $5 RETURNING *',
        [name, description, pointsRequired, isActive, rewardId]
      );

      if (result.rows.length > 0) {
        console.log(`[REWARD_SERVICE] Updated reward: ${result.rows[0].name}`);
        return result.rows[0];
      } else {
        console.log(`[REWARD_SERVICE] Reward not found for update: ${rewardId}`);
        return null;
      }
    } catch (error) {
      console.error('[REWARD_SERVICE] Update reward error:', error.message);
      throw error;
    }
  }

  /**
   * Delete (deactivate) a reward - Admin only
   */
  async deleteReward(rewardId) {
    try {
      console.log(`[REWARD_SERVICE] Deactivating reward ID: ${rewardId}`);

      const result = await database.query(
        'UPDATE rewards SET is_active = false, updated_at = NOW() WHERE id = $1 RETURNING *',
        [rewardId]
      );

      if (result.rows.length > 0) {
        console.log(`[REWARD_SERVICE] Deactivated reward: ${result.rows[0].name}`);
        return result.rows[0];
      } else {
        console.log(`[REWARD_SERVICE] Reward not found for deletion: ${rewardId}`);
        return null;
      }
    } catch (error) {
      console.error('[REWARD_SERVICE] Delete reward error:', error.message);
      throw error;
    }
  }
}

module.exports = new RewardService();
