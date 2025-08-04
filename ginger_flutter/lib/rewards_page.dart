import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/points_provider.dart';
import 'providers/reward_provider.dart';
import 'widgets/user_qr_widget.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {

  // Helper function to get icon based on reward name
  IconData _getRewardIcon(String? rewardName) {
    if (rewardName == null) return Icons.local_cafe;

    final name = rewardName.toLowerCase();

    if (name.contains('coffee')) {
      return Icons.local_cafe;
    } else if (name.contains('pastry') || name.contains('cake') || name.contains('muffin') || name.contains('croissant')) {
      return Icons.cake;
    } else if (name.contains('lunch') || name.contains('sandwich') || name.contains('salad')) {
      return Icons.lunch_dining;
    } else if (name.contains('specialty') || name.contains('latte') || name.contains('cappuccino') || name.contains('mocha')) {
      return Icons.coffee;
    } else if (name.contains('upgrade') || name.contains('large')) {
      return Icons.keyboard_arrow_up;
    } else if (name.contains('combo')) {
      return Icons.restaurant;
    } else {
      // Default to coffee cup for unknown rewards
      return Icons.local_cafe;
    }
  }

  @override
  void initState() {
    super.initState();
    // Load points and rewards when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user?.id != null) {
        pointsProvider.loadUserPoints(user!.id!);
      }
      rewardProvider.loadRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, PointsProvider, RewardProvider>(
      builder: (context, authProvider, pointsProvider, rewardProvider, child) {
        final user = authProvider.currentUser;

        if (user?.id == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7EDE4),
            appBar: AppBar(
              title: const Text('Your Rewards'),
              backgroundColor: const Color(0xFF8B7355),
            ),
            body: const Center(
              child: Text('User not found'),
            ),
          );
        }

        final isLoading = pointsProvider.isLoading(user!.id!) || rewardProvider.isLoading;
        final error = pointsProvider.getError(user.id!) ?? rewardProvider.error;
        final loyaltyPoints = pointsProvider.getUserPoints(user.id!);

        // Calculate points data using dynamic reward values
        final int currentPoints = loyaltyPoints?.currentPoints ?? 0;
        final firstReward = rewardProvider.firstReward;
        final int pointsNeeded = firstReward?.pointsRequired ?? 10; // Fallback to 10 if no rewards loaded
        final bool hasFreeReward = currentPoints >= pointsNeeded;
        final int availableRewards = currentPoints ~/ pointsNeeded; // Number of complete rewards
        final int pointsToNext = pointsNeeded - (currentPoints % pointsNeeded);
        final allRewards = rewardProvider.rewards ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF7EDE4), // Updated beige background
          appBar: AppBar(
            title: const Text(
              'Your Rewards',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF8B7355), // Darker beige
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  pointsProvider.refreshUserPoints(user.id!);
                  rewardProvider.refreshRewards();
                },
              ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
                  ),
                )
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Unable to load points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => pointsProvider.refreshUserPoints(user.id!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7355),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
        child: Column(
          children: [
            // Current Status Card
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      color: Color(0x1A000000),
                      offset: Offset(0.0, 5),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progress Circle
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle
                            SizedBox(
                              width: 80,
                              height: 80,
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
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: currentPoints / pointsNeeded,
                                strokeWidth: 6,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  hasFreeReward ? Colors.green : const Color(0xFF8B7355), // Darker beige
                                ),
                              ),
                            ),
                            // Coffee icon in center
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: hasFreeReward ? Colors.green : const Color(0xFF8B7355), // Darker beige
                                shape: BoxShape.circle,
                              ),
                              child: hasFreeReward
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.local_cafe,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Status Text
                      Text(
                        '$currentPoints / $pointsNeeded Points',
                        style: const TextStyle(
                          color: Color(0xFF2F1B14),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasFreeReward) ...[
                        Text(
                          allRewards.length > 1
                            ? (availableRewards == 1 ? '1 free reward ready!' : '$availableRewards free rewards ready!')
                            : (availableRewards == 1 ? '1 free ${firstReward?.name.toLowerCase() ?? 'coffee'} ready!' : '$availableRewards free ${firstReward?.name.toLowerCase() ?? 'coffee'}s ready!'),
                          style: const TextStyle(
                            color: Color(0xFF8B7355),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          allRewards.length > 1
                            ? '$pointsToNext more points till next reward'
                            : '$pointsToNext more points to ${firstReward?.name.toLowerCase() ?? 'free coffee'}',
                          style: const TextStyle(
                            color: Color(0xFF8B7355), // Darker beige
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Rewards available section - Stamp Card Design
            if (hasFreeReward) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF8B7355), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_cafe, color: Color(0xFF8B7355), size: 28),
                          const SizedBox(width: 8),
                          Text(
                            allRewards.length > 1
                              ? (availableRewards == 1 ? 'Free Reward Ready!' : '$availableRewards Free Rewards Ready!')
                              : (availableRewards == 1 ? 'Free ${firstReward?.name ?? 'Coffee'} Ready!' : '$availableRewards Free ${firstReward?.name ?? 'Coffee'}s Ready!'),
                            style: const TextStyle(
                              color: Color(0xFF8B7355),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stamp Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7EDE4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF8B7355), width: 1),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'COFFEE REWARDS',
                              style: TextStyle(
                                color: Color(0xFF8B7355),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Stamps Grid
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: List.generate(availableRewards, (index) =>
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B7355),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.local_cafe, color: Colors.white, size: 24),
                                      Text(
                                        'FREE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showQRCode(context, user.id!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B7355),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Show QR Code'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        'Show your QR code to staff to redeem',
                        style: TextStyle(
                          color: Color(0xFF8B7355),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // All Rewards Section
            if (allRewards.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Rewards',
                      style: TextStyle(
                        color: Color(0xFF2F1B14),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...allRewards.map((reward) {
                      final canAfford = currentPoints >= reward.pointsRequired;
                      final availableCount = currentPoints ~/ reward.pointsRequired;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: canAfford ? Colors.green : const Color(0xFFE0E0E0),
                            width: canAfford ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Reward Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: canAfford ? Colors.green : const Color(0xFF8B7355),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: canAfford
                                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                                  : Icon(_getRewardIcon(reward.name), color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),

                            // Reward Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reward.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2F1B14),
                                    ),
                                  ),
                                  if (reward.description != null && reward.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      reward.description!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B7355),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${reward.pointsRequired} points',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (canAfford) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            availableCount == 1 ? '1 available' : '$availableCount available',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Status Indicator
                            if (canAfford)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              )
                            else
                              Text(
                                '${reward.pointsRequired - currentPoints}\nmore needed',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // How it works card
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How it works:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.qr_code, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Show your QR code to staff when you buy a coffee',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.add_circle, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Earn 1 point for every coffee purchase',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.local_cafe, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Get a free coffee when you reach 10 points',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
                    ),
                  ),
                );
    },
  );
}

  void _showQRCode(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Show this to the barista',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final user = authProvider.currentUser;
                      if (user?.id == null) {
                        return const SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        );
                      }

                      return UserQRWidget(userId: user!.id!);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Close button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B7355),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
