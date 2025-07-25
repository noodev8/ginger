const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const database = require('./database');

class AuthService {
  
  /**
   * Hash password using bcrypt
   */
  async hashPassword(password) {
    const rounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
    return await bcrypt.hash(password, rounds);
  }

  /**
   * Compare password with hash
   */
  async comparePassword(password, hash) {
    return await bcrypt.compare(password, hash);
  }

  /**
   * Generate JWT token
   */
  generateToken(user) {
    const payload = {
      id: user.id,
      email: user.email,
      staff: user.staff,
      staff_admin: user.staff_admin
    };

    const options = {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
      issuer: 'ginger-app'
    };

    return jwt.sign(payload, process.env.JWT_SECRET, options);
  }

  /**
   * Verify JWT token
   */
  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw new Error('Invalid token');
    }
  }

  /**
   * Register new user
   */
  async register(userData) {
    const { email, password, display_name, phone } = userData;

    try {
      // Check if user already exists
      const existingUser = await database.query(
        'SELECT id FROM app_user WHERE email = $1',
        [email]
      );

      if (existingUser.rows.length > 0) {
        throw new Error('User already exists with this email');
      }

      // Hash password
      const passwordHash = await this.hashPassword(password);

      // Insert new user
      const result = await database.query(
        `INSERT INTO app_user (email, password_hash, display_name, phone, created_at, staff, email_verified, staff_admin)
         VALUES ($1, $2, $3, $4, NOW(), false, false, false)
         RETURNING id, email, display_name, phone, created_at, staff, email_verified, staff_admin`,
        [email, passwordHash, display_name, phone]
      );

      const user = result.rows[0];

      // Generate auth token
      const authToken = this.generateToken(user);
      const expiresAt = new Date(Date.now() + (7 * 24 * 60 * 60 * 1000)); // 7 days

      // Update user with auth token
      await database.query(
        'UPDATE app_user SET auth_token = $1, auth_token_expires = $2, last_active_at = NOW() WHERE id = $3',
        [authToken, expiresAt, user.id]
      );

      // Create loyalty points record
      await database.query(
        'INSERT INTO loyalty_points (user_id, current_points) VALUES ($1, 0)',
        [user.id]
      );

      return {
        ...user,
        auth_token: authToken,
        auth_token_expires: expiresAt.toISOString()
      };

    } catch (error) {
      console.error('Registration error:', error.message);
      throw error;
    }
  }

  /**
   * Login user
   */
  async login(email, password) {
    try {
      // Get user by email
      const result = await database.query(
        'SELECT id, email, password_hash, display_name, phone, staff, email_verified, staff_admin, created_at FROM app_user WHERE email = $1',
        [email]
      );

      if (result.rows.length === 0) {
        throw new Error('Invalid email or password');
      }

      const user = result.rows[0];

      // Verify password
      const isValidPassword = await this.comparePassword(password, user.password_hash);
      if (!isValidPassword) {
        throw new Error('Invalid email or password');
      }

      // Generate new auth token
      const authToken = this.generateToken(user);
      const expiresAt = new Date(Date.now() + (7 * 24 * 60 * 60 * 1000)); // 7 days

      // Update user with new auth token
      await database.query(
        'UPDATE app_user SET auth_token = $1, auth_token_expires = $2, last_active_at = NOW() WHERE id = $3',
        [authToken, expiresAt, user.id]
      );

      // Remove password hash from response
      delete user.password_hash;

      return {
        ...user,
        auth_token: authToken,
        auth_token_expires: expiresAt.toISOString()
      };

    } catch (error) {
      console.error('Login error:', error.message);
      throw error;
    }
  }

  /**
   * Validate auth token and get user
   */
  async validateToken(token) {
    try {
      // Verify JWT token
      const decoded = this.verifyToken(token);

      // Get user from database
      const result = await database.query(
        `SELECT id, email, display_name, phone, staff, email_verified, staff_admin, created_at, auth_token_expires 
         FROM app_user 
         WHERE id = $1 AND auth_token = $2`,
        [decoded.id, token]
      );

      if (result.rows.length === 0) {
        throw new Error('Invalid token');
      }

      const user = result.rows[0];

      // Check if token is expired
      if (new Date() > new Date(user.auth_token_expires)) {
        throw new Error('Token expired');
      }

      // Update last active
      await database.query(
        'UPDATE app_user SET last_active_at = NOW() WHERE id = $1',
        [user.id]
      );

      return {
        ...user,
        auth_token: token
      };

    } catch (error) {
      console.error('Token validation error:', error.message);
      throw error;
    }
  }

  /**
   * Logout user (invalidate token)
   */
  async logout(token) {
    try {
      const decoded = this.verifyToken(token);

      // Clear auth token from database
      await database.query(
        'UPDATE app_user SET auth_token = NULL, auth_token_expires = NULL WHERE id = $1',
        [decoded.id]
      );

      return true;
    } catch (error) {
      console.error('Logout error:', error.message);
      throw error;
    }
  }

  /**
   * Validate email format
   */
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Validate password strength
   */
  isValidPassword(password) {
    // At least 8 characters, contains letter and number
    return password.length >= 8 && 
           /[A-Za-z]/.test(password) && 
           /\d/.test(password);
  }
}

module.exports = new AuthService();
