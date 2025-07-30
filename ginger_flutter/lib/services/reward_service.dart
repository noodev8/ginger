import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/reward.dart';
import '../config/api_config.dart';

class RewardService {
  static const _storage = FlutterSecureStorage();

  /// Get all active rewards
  Future<List<Reward>?> getActiveRewards() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/rewards'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS') {
          final List<dynamic> rewardsJson = responseData['rewards'];
          return rewardsJson.map((json) => Reward.fromJson(json)).toList();
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Get active rewards error: $e');
      }
      return null;
    }
  }

  /// Get the first available reward for a user's points
  Future<Reward?> getAvailableReward(int userPoints) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/rewards/available/$userPoints'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['return_code'] == 'SUCCESS' && responseData['reward'] != null) {
          return Reward.fromJson(responseData['reward']);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Get available reward error: $e');
      }
      return null;
    }
  }
}
