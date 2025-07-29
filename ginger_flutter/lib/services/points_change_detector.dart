import 'dart:async';
import 'package:flutter/foundation.dart';
import 'points_service.dart';
import '../models/loyalty_points.dart';

class PointsChangeDetector {
  static final PointsChangeDetector _instance = PointsChangeDetector._internal();
  factory PointsChangeDetector() => _instance;
  PointsChangeDetector._internal();

  final PointsService _pointsService = PointsService();
  Timer? _timer;
  int? _lastKnownPoints;
  int? _currentUserId;
  bool _isActive = false;

  // Stream controller for points changes
  final StreamController<PointsChangeEvent> _pointsChangeController = 
      StreamController<PointsChangeEvent>.broadcast();

  Stream<PointsChangeEvent> get pointsChangeStream => _pointsChangeController.stream;

  /// Start monitoring points changes for a specific user
  void startMonitoring(int userId) {
    if (_isActive && _currentUserId == userId) {
      return; // Already monitoring this user
    }

    stopMonitoring(); // Stop any existing monitoring

    _currentUserId = userId;
    _isActive = true;
    _lastKnownPoints = null;

    if (kDebugMode) {
      print('[PointsChangeDetector] Starting monitoring for user $userId');
    }

    // Initial points check
    _checkPointsChange();

    // Set up periodic checking every 5 seconds when app is active
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isActive) {
        _checkPointsChange();
      }
    });
  }

  /// Stop monitoring points changes
  void stopMonitoring() {
    if (kDebugMode) {
      print('[PointsChangeDetector] Stopping monitoring');
    }

    _isActive = false;
    _timer?.cancel();
    _timer = null;
    _lastKnownPoints = null;
    _currentUserId = null;
  }

  /// Pause monitoring (when app goes to background)
  void pauseMonitoring() {
    if (kDebugMode) {
      print('[PointsChangeDetector] Pausing monitoring');
    }
    _isActive = false;
  }

  /// Resume monitoring (when app comes to foreground)
  void resumeMonitoring() {
    if (_currentUserId != null) {
      if (kDebugMode) {
        print('[PointsChangeDetector] Resuming monitoring');
      }
      _isActive = true;
      // Check immediately when resuming
      _checkPointsChange();
    }
  }

  /// Check for points changes
  Future<void> _checkPointsChange() async {
    if (!_isActive || _currentUserId == null) {
      return;
    }

    try {
      final loyaltyPoints = await _pointsService.getUserPoints(_currentUserId!);
      if (loyaltyPoints != null) {
        final currentPoints = loyaltyPoints.currentPoints;

        if (_lastKnownPoints != null && currentPoints > _lastKnownPoints!) {
          // Points increased!
          final pointsAdded = currentPoints - _lastKnownPoints!;
          
          if (kDebugMode) {
            print('[PointsChangeDetector] Points increased! +$pointsAdded (from $_lastKnownPoints to $currentPoints)');
          }

          // Emit points change event
          _pointsChangeController.add(PointsChangeEvent(
            userId: _currentUserId!,
            previousPoints: _lastKnownPoints!,
            newPoints: currentPoints,
            pointsAdded: pointsAdded,
            timestamp: DateTime.now(),
          ));
        }

        _lastKnownPoints = currentPoints;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PointsChangeDetector] Error checking points: $e');
      }
    }
  }

  /// Manually trigger a points check (useful after app resume)
  Future<void> checkNow() async {
    if (_isActive && _currentUserId != null) {
      await _checkPointsChange();
    }
  }

  /// Set the initial points value (to avoid false positives on first load)
  void setInitialPoints(int points) {
    _lastKnownPoints = points;
    if (kDebugMode) {
      print('[PointsChangeDetector] Set initial points to $points');
    }
  }

  void dispose() {
    stopMonitoring();
    _pointsChangeController.close();
  }
}

class PointsChangeEvent {
  final int userId;
  final int previousPoints;
  final int newPoints;
  final int pointsAdded;
  final DateTime timestamp;

  PointsChangeEvent({
    required this.userId,
    required this.previousPoints,
    required this.newPoints,
    required this.pointsAdded,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PointsChangeEvent(userId: $userId, previousPoints: $previousPoints, newPoints: $newPoints, pointsAdded: $pointsAdded, timestamp: $timestamp)';
  }
}
