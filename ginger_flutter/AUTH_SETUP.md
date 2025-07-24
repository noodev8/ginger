# Authentication Setup Guide

## Overview
This Flutter app now includes a complete authentication system with login, registration, and secure token storage.

## Features
- ✅ Login with email and password
- ✅ User registration with validation
- ✅ Secure token storage using FlutterSecureStorage
- ✅ Automatic token validation on app start
- ✅ Material 3 UI design matching app theme
- ✅ Loading states and error handling
- ✅ Logout functionality

## API Endpoints Required

Your backend server needs to implement these endpoints:

### 1. Login - `POST /auth/login`
**Request:**
```json
{
  "email": "user@example.com",
  "password": "userpassword"
}
```

**Success Response:**
```json
{
  "return_code": "SUCCESS",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "display_name": "John Doe",
    "phone": "+1234567890",
    "staff": false,
    "email_verified": true,
    "auth_token": "jwt_token_here",
    "auth_token_expires": "2024-01-01T00:00:00Z",
    "created_at": "2023-01-01T00:00:00Z",
    "last_active_at": "2024-01-01T00:00:00Z"
  }
}
```

### 2. Register - `POST /auth/register`
**Request:**
```json
{
  "email": "user@example.com",
  "password": "userpassword",
  "display_name": "John Doe",
  "phone": "+1234567890"
}
```

**Success Response:** Same as login response

### 3. Logout - `POST /auth/logout`
**Headers:**
```
Authorization: Bearer jwt_token_here
```

**Success Response:**
```json
{
  "return_code": "SUCCESS"
}
```

### 4. Validate Token - `POST /auth/validate`
**Headers:**
```
Authorization: Bearer jwt_token_here
```

**Success Response:** Same as login response

## Configuration

### 1. Update API Base URL
Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://your-api-domain.com';
```

### 2. Database Schema
Ensure your `app_user` table matches the schema in `ginger_library/DB_Schema.sql`

### 3. Backend Implementation
- Use bcrypt for password hashing
- Implement JWT token generation and validation
- Follow the project rules for API responses with `return_code`

## Security Features

### Password Requirements
- Minimum 8 characters
- Must contain letters and numbers
- Validated on both client and server

### Token Storage
- Uses FlutterSecureStorage for secure token persistence
- Tokens are automatically validated on app start
- Invalid tokens are cleared from storage

### Error Handling
- Network timeouts (30 seconds)
- Graceful error messages
- Automatic token cleanup on logout

## Usage

### For Users
1. App opens to login screen if not authenticated
2. Users can register new accounts or login
3. Authentication persists across app restarts
4. Logout clears all stored credentials

### For Developers
```dart
// Get current user
final authProvider = Provider.of<AuthProvider>(context);
final user = authProvider.currentUser;

// Check if authenticated
if (authProvider.isAuthenticated) {
  // User is logged in
}

// Get auth token for API calls
final token = await authProvider.getAuthToken();
```

## Testing

1. Start your backend server
2. Update the API base URL in `api_config.dart`
3. Run the Flutter app
4. Test registration and login flows
5. Verify token persistence by restarting the app

## Troubleshooting

### Common Issues
1. **Connection refused**: Check if backend server is running
2. **Invalid token**: Ensure JWT implementation matches expected format
3. **Storage errors**: Check device permissions for secure storage

### Debug Mode
The app includes debug logging for development. Check console output for detailed error messages.
