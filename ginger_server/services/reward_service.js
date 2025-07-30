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
}

module.exports = new RewardService();
