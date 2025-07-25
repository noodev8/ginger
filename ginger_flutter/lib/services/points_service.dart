import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/loyalty_points.dart';
import '../config/api_config.dart';

class PointsService {
  static const _storage = FlutterSecureStorage();

  /// Get loyalty points for a user
  Future<LoyaltyPoints?> getUserPoints(int userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pointsEndpoint}/user/$userId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return LoyaltyPoints.fromJson(responseData['points']);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Get user points error: $e');
      }
      return null;
    }
  }

  /// Add points to a user (when QR code is scanned by staff)
  Future<bool> addPointsToUser({
    required int userId,
    required int staffUserId,
    required int pointsAmount,
    String? description,
  }) async {
    // Validate input parameters
    if (userId <= 0) {
      throw ArgumentError('User ID must be positive');
    }
    if (staffUserId <= 0) {
      throw ArgumentError('Staff user ID must be positive');
    }
    if (pointsAmount <= 0) {
      throw ArgumentError('Points amount must be positive');
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.addPointsEndpoint}'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'user_id': userId,
          'staff_user_id': staffUserId,
          'points_amount': pointsAmount,
          'description': description ?? 'QR code scan',
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return true;
        } else {
          if (kDebugMode) {
            print('Add points failed: ${responseData['message'] ?? 'Unknown error'}');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('Add points server error: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Add points error: $e');
      }
      rethrow; // Re-throw to let the caller handle the error
    }
  }

  /// Get point transaction history for a user
  Future<List<Map<String, dynamic>>> getPointTransactions(int userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pointsEndpoint}/transactions/$userId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return List<Map<String, dynamic>>.from(responseData['transactions']);
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Get point transactions error: $e');
      }
      return [];
    }
  }

  /// Check if a QR code has been scanned recently (prevent duplicate scans)
  Future<bool> canScanQRCode(String qrCodeData, int staffUserId) async {
    // Validate input parameters
    if (qrCodeData.isEmpty) {
      throw ArgumentError('QR code data cannot be empty');
    }
    if (staffUserId <= 0) {
      throw ArgumentError('Staff user ID must be positive');
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.canScanEndpoint}'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'qr_code_data': qrCodeData,
          'staff_user_id': staffUserId,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return responseData['can_scan'] == true;
        } else {
          if (kDebugMode) {
            print('Can scan check failed: ${responseData['message'] ?? 'Unknown error'}');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('Can scan server error: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Can scan QR code error: $e');
      }
      // For safety, if we can't check, assume we can't scan
      return false;
    }
  }
}
