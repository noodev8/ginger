import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class QRService {
  static const _storage = FlutterSecureStorage();

  /// Get QR code for a user
  Future<Map<String, dynamic>?> getUserQRCode(int userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/qr/user/$userId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return responseData['qr_code'];
        }
      }
      return null;
    } catch (e) {
      print('Get QR code error: $e');
      return null;
    }
  }

  /// Validate a scanned QR code
  Future<Map<String, dynamic>?> validateQRCode(String qrCodeData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/qr/validate'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'qr_code_data': qrCodeData,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return responseData['user'];
        }
      }
      return null;
    } catch (e) {
      print('Validate QR code error: $e');
      return null;
    }
  }

  /// Scan QR code and add points
  Future<Map<String, dynamic>?> scanQRCode(String qrCodeData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/qr/scan'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'qr_code_data': qrCodeData,
        }),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['return_code'] == 'SUCCESS') {
        return {
          'success': true,
          'message': responseData['message'],
          'user_name': responseData['user_name'],
          'new_total': responseData['new_total'],
          'reward_eligible': responseData['reward_eligible'] ?? false,
          'user_id': responseData['user_id'],
          'current_points': responseData['current_points'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Scan failed',
        };
      }
    } catch (e) {
      print('Scan QR code error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Redeem reward for a user (deduct 10 points, add 1 point for current scan)
  Future<Map<String, dynamic>?> redeemReward(int userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/qr/redeem-reward'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'user_id': userId,
        }),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['return_code'] == 'SUCCESS') {
        return {
          'success': true,
          'message': responseData['message'],
          'new_total': responseData['new_total'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Redemption failed',
        };
      }
    } catch (e) {
      print('Redeem reward error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
