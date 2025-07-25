const authService = require('../services/auth_service');

/**
 * Middleware to authenticate JWT token
 */
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        return_code: 'MISSING_TOKEN',
        message: 'Access token is required'
      });
    }

    // Validate token and get user
    const user = await authService.validateToken(token);
    
    // Add user to request object
    req.user = user;
    next();
  } catch (error) {
    console.error('Authentication error:', error.message);
    
    return res.status(401).json({
      return_code: 'INVALID_TOKEN',
      message: 'Invalid or expired token'
    });
  }
};

/**
 * Middleware to check if user is staff
 */
const requireStaff = (req, res, next) => {
  if (!req.user || !req.user.staff) {
    return res.status(403).json({
      return_code: 'ACCESS_DENIED',
      message: 'Staff access required'
    });
  }
  next();
};

/**
 * Middleware to check if user is staff admin
 */
const requireStaffAdmin = (req, res, next) => {
  if (!req.user || !req.user.staff_admin) {
    return res.status(403).json({
      return_code: 'ACCESS_DENIED',
      message: 'Staff admin access required'
    });
  }
  next();
};

/**
 * Middleware to check if user can access resource (own resource or staff)
 */
const requireOwnershipOrStaff = (userIdParam = 'userId') => {
  return (req, res, next) => {
    const resourceUserId = parseInt(req.params[userIdParam]);
    const currentUserId = req.user.id;
    const isStaff = req.user.staff;

    if (currentUserId !== resourceUserId && !isStaff) {
      return res.status(403).json({
        return_code: 'ACCESS_DENIED',
        message: 'You can only access your own resources'
      });
    }
    next();
  };
};

module.exports = {
  authenticateToken,
  requireStaff,
  requireStaffAdmin,
  requireOwnershipOrStaff
};
