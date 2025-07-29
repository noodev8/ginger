import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class ProfileService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Update user's display name
  static Future<Map<String, dynamic>?> updateDisplayName({
    required String authToken,
    required String newDisplayName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profile/display-name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'display_name': newDisplayName,
        }),
      );

      if (kDebugMode) {
        print('[ProfileService] Update display name response: ${response.statusCode}');
        print('[ProfileService] Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print('[ProfileService] Failed to update display name: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileService] Error updating display name: $e');
      }
      return null;
    }
  }

  /// Update user's profile icon
  static Future<Map<String, dynamic>?> updateProfileIcon({
    required String authToken,
    required String iconId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profile/icon'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'profile_icon_id': iconId,
        }),
      );

      if (kDebugMode) {
        print('[ProfileService] Update profile icon response: ${response.statusCode}');
        print('[ProfileService] Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print('[ProfileService] Failed to update profile icon: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileService] Error updating profile icon: $e');
      }
      return null;
    }
  }

  /// Update both display name and profile icon
  static Future<Map<String, dynamic>?> updateProfile({
    required String authToken,
    String? displayName,
    String? profileIconId,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (displayName != null) body['display_name'] = displayName;
      if (profileIconId != null) body['profile_icon_id'] = profileIconId;

      final response = await http.put(
        Uri.parse('$baseUrl/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('[ProfileService] Update profile response: ${response.statusCode}');
        print('[ProfileService] Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print('[ProfileService] Failed to update profile: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileService] Error updating profile: $e');
      }
      return null;
    }
  }

  /// Get current user profile
  static Future<User?> getCurrentProfile({
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (kDebugMode) {
        print('[ProfileService] Get profile response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        if (kDebugMode) {
          print('[ProfileService] Failed to get profile: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProfileService] Error getting profile: $e');
      }
      return null;
    }
  }
}
