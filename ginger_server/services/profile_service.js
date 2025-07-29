const database = require('./database');

class ProfileService {
  /**
   * Get user profile by ID
   * @param {number} userId - The user ID
   * @returns {Object|null} User profile or null if not found
   */
  async getUserProfile(userId) {
    try {
      console.log('[ProfileService] Getting profile for user:', userId);
      
      const query = `
        SELECT 
          id,
          email,
          phone,
          display_name,
          profile_icon_id,
          created_at,
          last_active_at,
          staff,
          email_verified,
          staff_admin
        FROM app_user
        WHERE id = $1
      `;
      
      const result = await database.query(query, [userId]);
      
      if (result.rows.length === 0) {
        console.log('[ProfileService] User not found:', userId);
        return null;
      }
      
      const user = result.rows[0];
      console.log('[ProfileService] Found user profile:', {
        id: user.id,
        email: user.email,
        display_name: user.display_name,
        profile_icon_id: user.profile_icon_id
      });
      
      return user;
    } catch (error) {
      console.error('[ProfileService] Error getting user profile:', error);
      throw error;
    }
  }

  /**
   * Update user profile
   * @param {number} userId - The user ID
   * @param {Object} updates - The updates to apply
   * @param {string} [updates.display_name] - New display name
   * @param {string} [updates.profile_icon_id] - New profile icon ID
   * @returns {Object|null} Updated user profile or null if not found
   */
  async updateUserProfile(userId, updates) {
    try {
      console.log('[ProfileService] Updating profile for user:', userId, updates);
      
      // Build dynamic query based on provided updates
      const updateFields = [];
      const values = [];
      let paramIndex = 1;
      
      if (updates.display_name !== undefined) {
        updateFields.push(`display_name = $${paramIndex}`);
        values.push(updates.display_name);
        paramIndex++;
      }
      
      if (updates.profile_icon_id !== undefined) {
        updateFields.push(`profile_icon_id = $${paramIndex}`);
        values.push(updates.profile_icon_id);
        paramIndex++;
      }
      
      if (updateFields.length === 0) {
        console.log('[ProfileService] No updates provided');
        return await this.getUserProfile(userId);
      }
      
      // Add updated timestamp
      updateFields.push(`last_active_at = NOW()`);
      
      // Add user ID for WHERE clause
      values.push(userId);
      
      const query = `
        UPDATE app_user
        SET ${updateFields.join(', ')}
        WHERE id = $${paramIndex}
        RETURNING 
          id,
          email,
          phone,
          display_name,
          profile_icon_id,
          created_at,
          last_active_at,
          staff,
          email_verified,
          staff_admin
      `;
      
      console.log('[ProfileService] Executing query:', query);
      console.log('[ProfileService] With values:', values);
      
      const result = await database.query(query, values);
      
      if (result.rows.length === 0) {
        console.log('[ProfileService] User not found for update:', userId);
        return null;
      }
      
      const updatedUser = result.rows[0];
      console.log('[ProfileService] Profile updated successfully:', {
        id: updatedUser.id,
        display_name: updatedUser.display_name,
        profile_icon_id: updatedUser.profile_icon_id
      });
      
      return updatedUser;
    } catch (error) {
      console.error('[ProfileService] Error updating user profile:', error);
      throw error;
    }
  }

  /**
   * Update user's display name
   * @param {number} userId - The user ID
   * @param {string} displayName - New display name
   * @returns {Object|null} Updated user profile or null if not found
   */
  async updateDisplayName(userId, displayName) {
    return await this.updateUserProfile(userId, { display_name: displayName });
  }

  /**
   * Update user's profile icon
   * @param {number} userId - The user ID
   * @param {string} profileIconId - New profile icon ID
   * @returns {Object|null} Updated user profile or null if not found
   */
  async updateProfileIcon(userId, profileIconId) {
    return await this.updateUserProfile(userId, { profile_icon_id: profileIconId });
  }
}

module.exports = new ProfileService();
