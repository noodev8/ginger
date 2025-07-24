/*
=======================================================================================================================================
API Route: Authentication Routes
=======================================================================================================================================
Purpose: Define authentication endpoints for login, register, logout, and token validation
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth_controller');

/*
=======================================================================================================================================
API Route: /auth/register
=======================================================================================================================================
Method: POST
Purpose: Register a new user account
=======================================================================================================================================
Request Payload:
{
  "email": "user@example.com",           // string, required
  "password": "password123",             // string, required (min 8 chars, letters + numbers)
  "display_name": "John Doe",            // string, optional
  "phone": "+1234567890"                 // string, optional
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "User registered successfully",
  "user": {
    "id": 1,                             // integer, user ID
    "email": "user@example.com",         // string, user email
    "display_name": "John Doe",          // string, user display name
    "phone": "+1234567890",              // string, user phone
    "staff": false,                      // boolean, staff status
    "email_verified": false,             // boolean, email verification status
    "staff_admin": false,                // boolean, admin status
    "created_at": "2024-01-01T00:00:00Z", // string, creation timestamp
    "auth_token": "jwt_token_here",      // string, JWT authentication token
    "auth_token_expires": "2024-01-08T00:00:00Z" // string, token expiration
  }
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_REQUIRED_FIELDS"
"INVALID_EMAIL_FORMAT"
"INVALID_PASSWORD"
"USER_ALREADY_EXISTS"
"SERVER_ERROR"
=======================================================================================================================================
*/
router.post('/register', authController.register);

/*
=======================================================================================================================================
API Route: /auth/login
=======================================================================================================================================
Method: POST
Purpose: Authenticate user and return auth token
=======================================================================================================================================
Request Payload:
{
  "email": "user@example.com",           // string, required
  "password": "password123"              // string, required
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Login successful",
  "user": {
    "id": 1,                             // integer, user ID
    "email": "user@example.com",         // string, user email
    "display_name": "John Doe",          // string, user display name
    "phone": "+1234567890",              // string, user phone
    "staff": false,                      // boolean, staff status
    "email_verified": false,             // boolean, email verification status
    "staff_admin": false,                // boolean, admin status
    "created_at": "2024-01-01T00:00:00Z", // string, creation timestamp
    "auth_token": "jwt_token_here",      // string, JWT authentication token
    "auth_token_expires": "2024-01-08T00:00:00Z" // string, token expiration
  }
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_REQUIRED_FIELDS"
"INVALID_CREDENTIALS"
"SERVER_ERROR"
=======================================================================================================================================
*/
router.post('/login', authController.login);

/*
=======================================================================================================================================
API Route: /auth/validate
=======================================================================================================================================
Method: POST
Purpose: Validate authentication token and return user data
=======================================================================================================================================
Request Headers:
Authorization: Bearer jwt_token_here

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Token is valid",
  "user": {
    "id": 1,                             // integer, user ID
    "email": "user@example.com",         // string, user email
    "display_name": "John Doe",          // string, user display name
    "phone": "+1234567890",              // string, user phone
    "staff": false,                      // boolean, staff status
    "email_verified": false,             // boolean, email verification status
    "staff_admin": false,                // boolean, admin status
    "created_at": "2024-01-01T00:00:00Z", // string, creation timestamp
    "auth_token": "jwt_token_here"       // string, JWT authentication token
  }
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_TOKEN"
"INVALID_TOKEN"
"SERVER_ERROR"
=======================================================================================================================================
*/
router.post('/validate', authController.validate);

/*
=======================================================================================================================================
API Route: /auth/logout
=======================================================================================================================================
Method: POST
Purpose: Logout user and invalidate authentication token
=======================================================================================================================================
Request Headers:
Authorization: Bearer jwt_token_here

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Logout successful"
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_TOKEN"
"SERVER_ERROR"
=======================================================================================================================================
*/
router.post('/logout', authController.logout);

module.exports = router;
