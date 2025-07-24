/*
=======================================================================================================================================
API Route: Authentication Controller
=======================================================================================================================================
Purpose: Handle user authentication including login, register, logout, and token validation
=======================================================================================================================================
*/

const authService = require('../services/auth_service');

class AuthController {

  /**
   * Register new user
   * POST /auth/register
   */
  async register(req, res) {
    try {
      const { email, password, display_name, phone } = req.body;

      // Validation
      if (!email || !password) {
        return res.status(400).json({
          return_code: 'MISSING_REQUIRED_FIELDS',
          message: 'Email and password are required'
        });
      }

      if (!authService.isValidEmail(email)) {
        return res.status(400).json({
          return_code: 'INVALID_EMAIL_FORMAT',
          message: 'Please provide a valid email address'
        });
      }

      if (!authService.isValidPassword(password)) {
        return res.status(400).json({
          return_code: 'INVALID_PASSWORD',
          message: 'Password must be at least 8 characters with letters and numbers'
        });
      }

      // Register user
      const user = await authService.register({
        email: email.toLowerCase().trim(),
        password,
        display_name: display_name?.trim(),
        phone: phone?.trim()
      });

      res.status(201).json({
        return_code: 'SUCCESS',
        message: 'User registered successfully',
        user: user
      });

    } catch (error) {
      console.error('Register error:', error);

      if (error.message === 'User already exists with this email') {
        return res.status(409).json({
          return_code: 'USER_ALREADY_EXISTS',
          message: 'An account with this email already exists'
        });
      }

      res.status(500).json({
        return_code: 'SERVER_ERROR',
        message: 'Registration failed. Please try again.'
      });
    }
  }

  /**
   * Login user
   * POST /auth/login
   */
  async login(req, res) {
    try {
      const { email, password } = req.body;

      // Validation
      if (!email || !password) {
        return res.status(400).json({
          return_code: 'MISSING_REQUIRED_FIELDS',
          message: 'Email and password are required'
        });
      }

      // Login user
      const user = await authService.login(email.toLowerCase().trim(), password);

      res.status(200).json({
        return_code: 'SUCCESS',
        message: 'Login successful',
        user: user
      });

    } catch (error) {
      console.error('Login error:', error);

      if (error.message === 'Invalid email or password') {
        return res.status(401).json({
          return_code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password'
        });
      }

      res.status(500).json({
        return_code: 'SERVER_ERROR',
        message: 'Login failed. Please try again.'
      });
    }
  }

  /**
   * Validate auth token
   * POST /auth/validate
   */
  async validate(req, res) {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        return res.status(401).json({
          return_code: 'MISSING_TOKEN',
          message: 'Authorization token is required'
        });
      }

      const user = await authService.validateToken(token);

      res.status(200).json({
        return_code: 'SUCCESS',
        message: 'Token is valid',
        user: user
      });

    } catch (error) {
      console.error('Token validation error:', error);

      if (error.message === 'Invalid token' || error.message === 'Token expired') {
        return res.status(401).json({
          return_code: 'INVALID_TOKEN',
          message: 'Invalid or expired token'
        });
      }

      res.status(500).json({
        return_code: 'SERVER_ERROR',
        message: 'Token validation failed'
      });
    }
  }

  /**
   * Logout user
   * POST /auth/logout
   */
  async logout(req, res) {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        return res.status(401).json({
          return_code: 'MISSING_TOKEN',
          message: 'Authorization token is required'
        });
      }

      await authService.logout(token);

      res.status(200).json({
        return_code: 'SUCCESS',
        message: 'Logout successful'
      });

    } catch (error) {
      console.error('Logout error:', error);

      res.status(500).json({
        return_code: 'SERVER_ERROR',
        message: 'Logout failed'
      });
    }
  }
}

module.exports = new AuthController();
