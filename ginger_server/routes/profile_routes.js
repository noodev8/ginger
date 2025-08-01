const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth_middleware');
const profileService = require('../services/profile_service');

// Get current user profile
router.get('/api/profile', authMiddleware.authenticateToken, async (req, res) => {
  try {
    console.log('[ProfileRoutes] Getting profile for user:', req.user.id);
    
    const user = await profileService.getUserProfile(req.user.id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      user: user
    });
  } catch (error) {
    console.error('[ProfileRoutes] Error getting profile:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Update user profile (display name and/or profile icon)
router.put('/api/profile', authMiddleware.authenticateToken, async (req, res) => {
  try {
    const { display_name, profile_icon_id } = req.body;
    console.log('[ProfileRoutes] Updating profile for user:', req.user.id, {
      display_name,
      profile_icon_id
    });

    // Validate input
    if (!display_name && !profile_icon_id) {
      return res.status(400).json({
        success: false,
        message: 'At least one field (display_name or profile_icon_id) is required'
      });
    }

    if (display_name && (typeof display_name !== 'string' || display_name.trim().length === 0)) {
      return res.status(400).json({
        success: false,
        message: 'Display name must be a non-empty string'
      });
    }

    if (profile_icon_id && typeof profile_icon_id !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Profile icon ID must be a string'
      });
    }

    const updatedUser = await profileService.updateUserProfile(req.user.id, {
      display_name: display_name ? display_name.trim() : undefined,
      profile_icon_id
    });

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('[ProfileRoutes] Error updating profile:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Update display name only
router.put('/api/profile/display-name', authMiddleware.authenticateToken, async (req, res) => {
  try {
    const { display_name } = req.body;
    console.log('[ProfileRoutes] Updating display name for user:', req.user.id, display_name);

    if (!display_name || typeof display_name !== 'string' || display_name.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Display name is required and must be a non-empty string'
      });
    }

    const updatedUser = await profileService.updateUserProfile(req.user.id, {
      display_name: display_name.trim()
    });

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'Display name updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('[ProfileRoutes] Error updating display name:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Update profile icon only
router.put('/api/profile/icon', authMiddleware.authenticateToken, async (req, res) => {
  try {
    const { profile_icon_id } = req.body;
    console.log('[ProfileRoutes] Updating profile icon for user:', req.user.id, profile_icon_id);

    if (!profile_icon_id || typeof profile_icon_id !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Profile icon ID is required and must be a string'
      });
    }

    const updatedUser = await profileService.updateUserProfile(req.user.id, {
      profile_icon_id
    });

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'Profile icon updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('[ProfileRoutes] Error updating profile icon:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Delete user account and all associated data
router.delete('/api/profile', authMiddleware.authenticateToken, async (req, res) => {
  try {
    console.log('[ProfileRoutes] Deleting account for user:', req.user.id);

    const success = await profileService.deleteUserAccount(req.user.id);

    if (success) {
      res.json({
        success: true,
        message: 'Account deleted successfully'
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to delete account'
      });
    }
  } catch (error) {
    console.error('[ProfileRoutes] Error deleting account:', error);

    if (error.message === 'User not found') {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;
