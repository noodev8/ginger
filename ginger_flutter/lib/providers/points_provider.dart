import 'package:flutter/foundation.dart';
import '../models/loyalty_points.dart';
import '../services/points_service.dart';

class PointsProvider extends ChangeNotifier {
  final PointsService _pointsService = PointsService();
  final Map<int, LoyaltyPoints?> _userPoints = {};
  final Map<int, bool> _loadingStates = {};
  final Map<int, String?> _errorStates = {};

  /// Get points for a specific user
  LoyaltyPoints? getUserPoints(int userId) {
    return _userPoints[userId];
  }

  /// Check if points are loading for a user
  bool isLoading(int userId) {
    return _loadingStates[userId] ?? false;
  }

  /// Get error state for a user
  String? getError(int userId) {
    return _errorStates[userId];
  }

  /// Load points for a user
  Future<void> loadUserPoints(int userId) async {
    _loadingStates[userId] = true;
    _errorStates[userId] = null;
    notifyListeners();

    try {
      final points = await _pointsService.getUserPoints(userId);
      _userPoints[userId] = points;
      _loadingStates[userId] = false;
      _errorStates[userId] = null;
    } catch (e) {
      _loadingStates[userId] = false;
      _errorStates[userId] = e.toString();
      if (kDebugMode) {
        print('Error loading points for user $userId: $e');
      }
    }
    
    notifyListeners();
  }

  /// Refresh points for a user (force reload)
  Future<void> refreshUserPoints(int userId) async {
    await loadUserPoints(userId);
  }

  /// Update points locally (for immediate UI updates)
  void updateUserPoints(int userId, int newPoints) {
    final currentPoints = _userPoints[userId];
    if (currentPoints != null) {
      _userPoints[userId] = currentPoints.copyWith(
        currentPoints: newPoints,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Refresh points for all loaded users (useful after QR scans)
  Future<void> refreshAllLoadedUsers() async {
    final userIds = _userPoints.keys.toList();
    for (final userId in userIds) {
      await loadUserPoints(userId);
    }
  }

  /// Clear all cached data
  void clearCache() {
    _userPoints.clear();
    _loadingStates.clear();
    _errorStates.clear();
    notifyListeners();
  }
}
