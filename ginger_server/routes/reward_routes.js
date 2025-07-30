const express = require('express');
const router = express.Router();
const rewardService = require('../services/reward_service');
const { authenticateToken } = require('../middleware/auth_middleware');

/*
=======================================================================================================================================
API Route: /rewards
=======================================================================================================================================
Method: GET
Purpose: Get all active rewards
=======================================================================================================================================
*/
router.get('/', authenticateToken, async (req, res) => {
  try {
    const rewards = await rewardService.getActiveRewards();
    
    res.json({
      return_code: 'SUCCESS',
      message: 'Rewards retrieved successfully',
      rewards: rewards
    });
  } catch (error) {
    console.error('Get rewards error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/*
=======================================================================================================================================
API Route: /rewards/available/:userPoints
=======================================================================================================================================
Method: GET
Purpose: Get the first available reward for a user's points
=======================================================================================================================================
*/
router.get('/available/:userPoints', authenticateToken, async (req, res) => {
  try {
    const { userPoints } = req.params;
    const points = parseInt(userPoints);
    
    if (isNaN(points) || points < 0) {
      return res.status(400).json({
        return_code: 'INVALID_POINTS',
        message: 'Invalid points value'
      });
    }
    
    const reward = await rewardService.getAvailableReward(points);
    
    res.json({
      return_code: 'SUCCESS',
      message: reward ? 'Available reward found' : 'No available rewards',
      reward: reward
    });
  } catch (error) {
    console.error('Get available reward error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;
