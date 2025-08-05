import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../providers/reward_provider.dart';

class PointsDisplayWidget extends StatefulWidget {
  final int userId;

  const PointsDisplayWidget({super.key, required this.userId});

  @override
  State<PointsDisplayWidget> createState() => _PointsDisplayWidgetState();
}

class _PointsDisplayWidgetState extends State<PointsDisplayWidget> {
  @override
  void initState() {
    super.initState();
    // Load points when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      pointsProvider.loadUserPoints(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PointsProvider, RewardProvider>(
      builder: (context, pointsProvider, rewardProvider, child) {
        final isLoading = pointsProvider.isLoading(widget.userId) || rewardProvider.isLoading;
        final error = pointsProvider.getError(widget.userId) ?? rewardProvider.error;
        final loyaltyPoints = pointsProvider.getUserPoints(widget.userId);

        if (isLoading) {
          return _buildLoadingState();
        }

        if (error != null || loyaltyPoints == null) {
          return _buildErrorState(pointsProvider, rewardProvider);
        }

        return _buildPointsDisplay(loyaltyPoints, rewardProvider);
      },
    );
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

  Widget _buildErrorState(PointsProvider pointsProvider, RewardProvider rewardProvider) {
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
              onPressed: () {
                pointsProvider.refreshUserPoints(widget.userId);
                rewardProvider.refreshRewards();
              },
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

  Widget _buildPointsDisplay(loyaltyPoints, RewardProvider rewardProvider) {
    final currentPoints = loyaltyPoints.currentPoints;
    final firstReward = rewardProvider.firstReward;
    final pointsNeeded = firstReward?.pointsRequired ?? 10; // Fallback to 10 if no rewards loaded
    final pointsToNextReward = pointsNeeded - (currentPoints % pointsNeeded);
    final progress = (currentPoints % pointsNeeded) / pointsNeeded.toDouble();

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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFDACEC3), // Light brown color
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
                          color: const Color(0xFF3E2723).withValues(alpha: 0.3), // Darker brown shadow
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
              '$pointsToNextReward to next free drink',
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
