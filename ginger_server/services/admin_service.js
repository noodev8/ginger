const database = require('./database');

class AdminService {
  /**
   * Get all staff members
   * @returns {Array} List of staff members
   */
  async getAllStaff() {
    try {
      console.log('[AdminService] Getting all staff members');
      
      const query = `
        SELECT 
          id,
          email,
          phone,
          display_name,
          created_at,
          last_active_at,
          staff_admin,
          email_verified
        FROM app_user
        WHERE staff = true
        ORDER BY created_at DESC
      `;
      
      const result = await database.query(query);
      console.log(`[AdminService] Found ${result.rows.length} staff members`);
      
      return result.rows;
    } catch (error) {
      console.error('[AdminService] Error getting staff members:', error);
      throw error;
    }
  }

  /**
   * Get customer count and basic analytics
   * @returns {Object} Customer analytics data
   */
  async getCustomerAnalytics() {
    try {
      console.log('[AdminService] Getting customer analytics');
      
      // Get total customer count (non-staff users)
      const customerCountQuery = `
        SELECT COUNT(*) as total_customers
        FROM app_user
        WHERE staff = false
      `;
      
      // Get customers with points
      const customersWithPointsQuery = `
        SELECT COUNT(DISTINCT lp.user_id) as customers_with_points
        FROM loyalty_points lp
        JOIN app_user au ON lp.user_id = au.id
        WHERE au.staff = false AND lp.current_points > 0
      `;
      
      // Get total points distributed
      const totalPointsQuery = `
        SELECT COALESCE(SUM(lp.current_points), 0) as total_points
        FROM loyalty_points lp
        JOIN app_user au ON lp.user_id = au.id
        WHERE au.staff = false
      `;
      
      // Get recent registrations (last 30 days)
      const recentRegistrationsQuery = `
        SELECT COUNT(*) as recent_registrations
        FROM app_user
        WHERE staff = false 
        AND created_at >= NOW() - INTERVAL '30 days'
      `;

      const [customerCount, customersWithPoints, totalPoints, recentRegistrations] = await Promise.all([
        database.query(customerCountQuery),
        database.query(customersWithPointsQuery),
        database.query(totalPointsQuery),
        database.query(recentRegistrationsQuery)
      ]);

      const analytics = {
        total_customers: parseInt(customerCount.rows[0].total_customers),
        customers_with_points: parseInt(customersWithPoints.rows[0].customers_with_points),
        total_points_distributed: parseInt(totalPoints.rows[0].total_points),
        recent_registrations: parseInt(recentRegistrations.rows[0].recent_registrations)
      };

      console.log('[AdminService] Customer analytics:', analytics);
      return analytics;
    } catch (error) {
      console.error('[AdminService] Error getting customer analytics:', error);
      throw error;
    }
  }

  /**
   * Get recent point transactions for admin overview
   * @param {number} limit - Number of transactions to retrieve
   * @returns {Array} Recent transactions
   */
  async getRecentTransactions(limit = 20) {
    try {
      console.log(`[AdminService] Getting ${limit} recent transactions`);
      
      const query = `
        SELECT 
          pt.id,
          pt.points_amount,
          pt.description,
          pt.transaction_date,
          customer.id as customer_id,
          customer.email as customer_email,
          customer.display_name as customer_name,
          staff.id as staff_id,
          staff.email as staff_email,
          staff.display_name as staff_name
        FROM point_transactions pt
        JOIN app_user customer ON pt.user_id = customer.id
        LEFT JOIN app_user staff ON pt.scanned_by = staff.id
        ORDER BY pt.transaction_date DESC
        LIMIT $1
      `;
      
      const result = await database.query(query, [limit]);
      console.log(`[AdminService] Found ${result.rows.length} recent transactions`);
      
      return result.rows;
    } catch (error) {
      console.error('[AdminService] Error getting recent transactions:', error);
      throw error;
    }
  }
}

module.exports = new AdminService();
