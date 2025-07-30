import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  /// Login user with email and password
  /// Returns User object with auth token on success, throws exception with error message on failure
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['return_code'] == 'SUCCESS') {
        final userData = responseData['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        // Store auth token and user data securely
        if (user.authToken != null) {
          await _storage.write(key: _tokenKey, value: user.authToken);
          await _storage.write(key: _userKey, value: jsonEncode(userData));
        }

        return user;
      } else {
        // Handle specific error cases
        String errorMessage = 'Login failed. Please try again.';

        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (response.statusCode == 401) {
          errorMessage = 'Invalid email or password.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }

      if (e is Exception) {
        rethrow;
      }

      // Network or other errors
      throw Exception('Unable to connect. Please check your internet connection.');
    }
  }
  
  /// Register new user
  /// Returns User object with auth token on success, throws exception with error message on failure
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'display_name': displayName,
          'phone': phone,
        }),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['return_code'] == 'SUCCESS') {
        final userData = responseData['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        // Store auth token and user data securely
        if (user.authToken != null) {
          await _storage.write(key: _tokenKey, value: user.authToken);
          await _storage.write(key: _userKey, value: jsonEncode(userData));
        }

        return user;
      } else {
        // Handle specific error cases
        String errorMessage = 'Registration failed. Please try again.';

        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (response.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (response.statusCode == 400) {
          errorMessage = 'Please check your information and try again.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }

      if (e is Exception) {
        rethrow;
      }

      // Network or other errors
      throw Exception('Unable to connect. Please check your internet connection.');
    }
  }
  
  /// Logout user
  Future<bool> logout() async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token != null) {
        // Call logout endpoint to invalidate token on server
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}'),
          headers: ApiConfig.getAuthHeaders(token),
        ).timeout(ApiConfig.requestTimeout);

        // Even if server call fails, we still clear local storage
        if (kDebugMode && response.statusCode != 200) {
          print('Server logout failed, but clearing local storage anyway');
        }
      }

      // Clear stored auth data
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      // Even on error, try to clear local storage
      try {
        await _storage.delete(key: _tokenKey);
        await _storage.delete(key: _userKey);
      } catch (storageError) {
        if (kDebugMode) {
          print('Storage clear error: $storageError');
        }
      }
      return false;
    }
  }
  
  /// Get stored auth token
  Future<String?> getStoredToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading stored token: $e');
      }
      return null;
    }
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userDataString = await _storage.read(key: _userKey);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading stored user: $e');
      }
      return null;
    }
  }

  /// Validate stored token with server
  Future<User?> validateStoredToken() async {
    try {
      final token = await getStoredToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.validateTokenEndpoint}'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          final userData = responseData['user'] as Map<String, dynamic>;
          return User.fromJson(userData);
        }
      }

      // Token is invalid, clear storage
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Token validation error: $e');
      }
      return null;
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  bool isValidPassword(String password) {
    // At least 8 characters, contains letter and number
    return password.length >= 8 &&
           RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }
}
