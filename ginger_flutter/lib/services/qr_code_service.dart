import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_qr_code.dart';
import '../config/api_config.dart';

class QRCodeService {
  static const _storage = FlutterSecureStorage();

  /// Generate a unique QR code for a user (user_id + 5 random numbers)
  static String generateQRCodeData(int userId) {
    if (userId <= 0) {
      throw ArgumentError('User ID must be positive');
    }

    final random = Random();
    final randomNumbers = List.generate(5, (_) => random.nextInt(10)).join();
    return '${userId}_$randomNumbers';
  }

  /// Validate QR code format (user_id_5digits)
  static bool isValidQRCodeFormat(String qrCodeData) {
    final regex = RegExp(r'^\d+_\d{5}$');
    return regex.hasMatch(qrCodeData);
  }

  /// Extract user ID from QR code data
  static int? extractUserIdFromQRCode(String qrCodeData) {
    if (!isValidQRCodeFormat(qrCodeData)) {
      return null;
    }

    final parts = qrCodeData.split('_');
    if (parts.length != 2) {
      return null;
    }

    return int.tryParse(parts[0]);
  }

  /// Get or create QR code for current user
  Future<UserQRCode?> getUserQRCode(int userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/qr-codes/user/$userId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return UserQRCode.fromJson(responseData['qr_code']);
        }
      } else if (response.statusCode == 404) {
        // QR code doesn't exist, create one
        return await createQRCode(userId);
      }

      throw Exception('Failed to get QR code');
    } catch (e) {
      if (kDebugMode) {
        print('Get QR code error: $e');
      }
      throw Exception('Unable to get QR code. Please try again.');
    }
  }

  /// Create a new QR code for user
  Future<UserQRCode?> createQRCode(int userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final qrCodeData = generateQRCodeData(userId);

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.qrCodesEndpoint}'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'user_id': userId,
          'qr_code_data': qrCodeData,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          return UserQRCode.fromJson(responseData['qr_code']);
        }
      }

      throw Exception('Failed to create QR code');
    } catch (e) {
      if (kDebugMode) {
        print('Create QR code error: $e');
      }
      throw Exception('Unable to create QR code. Please try again.');
    }
  }

  /// Validate a scanned QR code and return user info
  Future<Map<String, dynamic>?> validateQRCode(String qrCodeData) async {
    try {
      // First validate the format locally
      if (!isValidQRCodeFormat(qrCodeData)) {
        if (kDebugMode) {
          print('Invalid QR code format: $qrCodeData');
        }
        return null;
      }

      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.validateQRCodeEndpoint}'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'qr_code_data': qrCodeData,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          // Validate that the response contains required fields
          if (responseData['user_id'] != null) {
            return responseData;
          } else {
            if (kDebugMode) {
              print('Invalid response format: missing user_id');
            }
            return null;
          }
        } else {
          if (kDebugMode) {
            print('Server validation failed: ${responseData['message'] ?? 'Unknown error'}');
          }
          return null;
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('QR code not found in database');
        }
        return null;
      } else {
        if (kDebugMode) {
          print('Server error: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Validate QR code error: $e');
      }
      return null;
    }
  }
}
