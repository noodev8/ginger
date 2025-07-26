import 'package:flutter/material.dart';
import '../services/points_service.dart';
import '../models/loyalty_points.dart';

class PointsDisplayWidget extends StatefulWidget {
  final int userId;

  const PointsDisplayWidget({super.key, required this.userId});

  @override
  State<PointsDisplayWidget> createState() => _PointsDisplayWidgetState();
}

class _PointsDisplayWidgetState extends State<PointsDisplayWidget> {
  final PointsService _pointsService = PointsService();
  LoyaltyPoints? _loyaltyPoints;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final points = await _pointsService.getUserPoints(widget.userId);
      if (mounted) {
        setState(() {
          _loyaltyPoints = points;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPoints() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _loadPoints();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null || _loyaltyPoints == null) {
      return _buildErrorState();
    }

    return _buildPointsDisplay();
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7EDE4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B7355).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Loading points...',
              style: TextStyle(
                color: Color(0xFF8B7355),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7EDE4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B7355).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFF8B7355),
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load points',
              style: TextStyle(
                color: Color(0xFF2F1B14),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _refreshPoints,
              child: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFF8B7355)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsDisplay() {
    final currentPoints = _loyaltyPoints!.currentPoints;
    final pointsToNextReward = 10 - (currentPoints % 10);
    final progress = (currentPoints % 10) / 10.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7EDE4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B7355).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress Circle
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[300]!,
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B7355),
                      ),
                    ),
                  ),
                  // Coffee cup icon in center
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/coffee_icon2.png',
                      width: 45,
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Points text
            Text(
              '$currentPoints pts',
              style: const TextStyle(
                color: Color(0xFF2F1B14),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              pointsToNextReward == 10 
                  ? 'Congratulations! You earned a free drink!'
                  : '$pointsToNextReward to next free drink',
              style: const TextStyle(
                color: Color(0xFF8B7355),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
