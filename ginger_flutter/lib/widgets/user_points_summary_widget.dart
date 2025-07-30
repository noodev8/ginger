import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../providers/reward_provider.dart';

class UserPointsSummaryWidget extends StatefulWidget {
  final int userId;

  const UserPointsSummaryWidget({super.key, required this.userId});

  @override
  State<UserPointsSummaryWidget> createState() => _UserPointsSummaryWidgetState();
}

class _UserPointsSummaryWidgetState extends State<UserPointsSummaryWidget> {
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
        final loyaltyPoints = pointsProvider.getUserPoints(widget.userId);

        if (isLoading) {
          return const Text(
            'Loading points...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          );
        }

        final currentPoints = loyaltyPoints?.currentPoints ?? 0;
        final firstReward = rewardProvider.firstReward;
        final pointsNeeded = firstReward?.pointsRequired ?? 10; // Fallback to 10 if no rewards loaded
        final freeCoffees = currentPoints ~/ pointsNeeded; // Integer division - how many free coffees earned

        return Text(
          '$currentPoints Points • $freeCoffees Free Coffees Earned',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}
