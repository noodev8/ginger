const authService = require('../services/auth_service');

/**
 * Middleware to verify JWT token
 */
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    console.log(`[AUTH] Authenticating token for ${req.method} ${req.path}`);

    if (!token) {
      console.log('[AUTH] No token provided');
      return res.status(401).json({
        return_code: 'ERROR',
        message: 'Access token required'
      });
    }

    // Use auth service to validate token (same as /auth/validate endpoint)
    const user = await authService.validateToken(token);

    req.user = user;
    console.log(`[AUTH] Authenticated user:`, { 
      id: req.user.id, 
      email: req.user.email, 
      staff: req.user.staff 
    });
    
    next();
  } catch (error) {
    console.error('[AUTH] Token verification error:', error.message);
    return res.status(401).json({
      return_code: 'ERROR',
      message: 'Invalid token'
    });
  }
};

/**
 * Middleware to require staff privileges
 */
const requireStaff = (req, res, next) => {
  console.log(`[AUTH] Checking staff privileges for user ${req.user.id}`);
  
  if (!req.user.staff) {
    console.log(`[AUTH] Access denied - user ${req.user.id} is not staff`);
    return res.status(403).json({
      return_code: 'ERROR',
      message: 'Staff privileges required'
    });
  }

  console.log(`[AUTH] Staff access granted for user ${req.user.id}`);
  next();
};

/**
 * Middleware to require ownership or staff privileges
 */
const requireOwnershipOrStaff = (paramName) => {
  return (req, res, next) => {
    const resourceUserId = parseInt(req.params[paramName]);
    console.log(`[AUTH] Checking ownership/staff for resource user ${resourceUserId}, auth user ${req.user.id}`);
    
    if (req.user.id !== resourceUserId && !req.user.staff) {
      console.log(`[AUTH] Access denied - user ${req.user.id} cannot access resource for user ${resourceUserId}`);
      return res.status(403).json({
        return_code: 'ERROR',
        message: 'Access denied'
      });
    }

    console.log(`[AUTH] Access granted for user ${req.user.id} to resource ${resourceUserId}`);
    next();
  };
};

module.exports = {
  authenticateToken,
  requireStaff,
  requireOwnershipOrStaff
};

