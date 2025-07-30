import 'package:flutter/foundation.dart';
import '../models/reward.dart';
import '../services/reward_service.dart';

class RewardProvider extends ChangeNotifier {
  final RewardService _rewardService = RewardService();
  List<Reward>? _rewards;
  bool _isLoading = false;
  String? _error;

  /// Get all rewards
  List<Reward>? get rewards => _rewards;

  /// Check if rewards are loading
  bool get isLoading => _isLoading;

  /// Get error state
  String? get error => _error;

  /// Get the first reward (lowest points required)
  Reward? get firstReward {
    if (_rewards == null || _rewards!.isEmpty) return null;
    return _rewards!.first; // Already sorted by points_required ASC from server
  }

  /// Get available reward for user points
  Reward? getAvailableReward(int userPoints) {
    if (_rewards == null || _rewards!.isEmpty) return null;
    
    // Find the first reward the user can afford
    for (final reward in _rewards!) {
      if (userPoints >= reward.pointsRequired) {
        return reward;
      }
    }
    return null;
  }

  /// Load all active rewards
  Future<void> loadRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rewards = await _rewardService.getActiveRewards();
      _rewards = rewards;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _rewards = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh rewards
  Future<void> refreshRewards() async {
    await loadRewards();
  }
}
