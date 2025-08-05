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

        final allRewards = rewardProvider.rewards ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFFAF6F2), // Same as main screen background
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
            // Logo Header
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 8),
              child: Image.asset(
                'assets/logotext.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),

            // Points Display with Refresh Button
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 16, 60, 24),
              child: Column(
                children: [
                  // Coffee beans and points display
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Coffee beans positioned around the points
                        Positioned(
                          left: 20,
                          top: 10,
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Icon(
                              Icons.coffee,
                              color: const Color(0xFF8B7355).withValues(alpha: 0.4),
                              size: 24,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 25,
                          top: 15,
                          child: Transform.rotate(
                            angle: 0.4,
                            child: Icon(
                              Icons.coffee,
                              color: const Color(0xFF8B7355).withValues(alpha: 0.35),
                              size: 20,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          bottom: 15,
                          child: Transform.rotate(
                            angle: 0.2,
                            child: Icon(
                              Icons.coffee,
                              color: const Color(0xFF8B7355).withValues(alpha: 0.45),
                              size: 18,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          bottom: 10,
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Icon(
                              Icons.coffee,
                              color: const Color(0xFF8B7355).withValues(alpha: 0.38),
                              size: 22,
                            ),
                          ),
                        ),

                      // Centered large points display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$currentPoints',
                            style: TextStyle(
                              color: const Color(0xFF8B7355),
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'pts',
                            style: TextStyle(
                              color: const Color(0xFF8B7355).withValues(alpha: 0.8),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Points until next reward with refresh button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        allRewards.isNotEmpty
                          ? '${allRewards.first.pointsRequired - (currentPoints % allRewards.first.pointsRequired)} more for next reward'
                          : 'Keep collecting points!',
                        style: TextStyle(
                          color: const Color(0xFF8B7355).withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            pointsProvider.refreshUserPoints(user.id!);
                            rewardProvider.refreshRewards();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF8B7355),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            // Rewards available section - Stamp Card Design
            if (hasFreeReward) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF8), // Slightly off-white paper color
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF8B7355), width: 2),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: const Color(0xFF8B7355).withValues(alpha: 0.2),
                        offset: const Offset(0.0, 6),
                      ),
                      const BoxShadow(
                        blurRadius: 4,
                        color: Color(0xFFE0E0E0),
                        offset: Offset(0.0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with decorative elements
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.local_cafe, color: Color(0xFF8B7355), size: 32),
                              const SizedBox(width: 12),
                              Container(
                                width: 40,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allRewards.length > 1
                              ? (availableRewards == 1 ? 'Free Reward Ready!' : '$availableRewards Free Rewards Ready!')
                              : (availableRewards == 1 ? 'Free ${firstReward?.name ?? 'Coffee'} Ready!' : '$availableRewards Free ${firstReward?.name ?? 'Coffee'}s Ready!'),
                            style: const TextStyle(
                              color: Color(0xFF8B7355),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Paper Stamp Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEFC), // Pure paper white
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF8B7355).withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Stamp card title
                            Text(
                              'DAILY STAMP',
                              style: TextStyle(
                                color: const Color(0xFF8B7355).withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'LOYALTY CARD',
                              style: TextStyle(
                                color: const Color(0xFF8B7355).withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Circular Stamps Grid
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: List.generate(availableRewards, (index) =>
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B7355),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.local_cafe, color: Colors.white, size: 28),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'FREE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Bottom decorative line
                            Container(
                              width: 100,
                              height: 1,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(0.5),
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


                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Rewards Section
            if (allRewards.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: allRewards.length == 1 ? 1 : 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: allRewards.length == 1 ? 1.4 : 0.85, // Taller for single reward to accommodate vertical layout
                  ),
                      itemCount: allRewards.length,
                      itemBuilder: (context, index) {
                        final reward = allRewards[index];
                        final canAfford = currentPoints >= reward.pointsRequired;
                        final availableCount = currentPoints ~/ reward.pointsRequired;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                color: const Color(0xFF8B7355).withValues(alpha: 0.15),
                                offset: const Offset(0.0, 4),
                              ),
                              const BoxShadow(
                                blurRadius: 2,
                                color: Color(0xFFE0E0E0),
                                offset: Offset(0.0, 1),
                              )
                            ],
                          ),
                          child: allRewards.length == 1
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Larger Progress Circle for single reward (like main screen)
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
                                            value: canAfford ? 1.0 : (currentPoints / reward.pointsRequired).clamp(0.0, 1.0),
                                            strokeWidth: 6,
                                            backgroundColor: Colors.transparent,
                                            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF8B7355)), // Coffee brown color for progress line
                                          ),
                                        ),
                                        // Reward Icon in center
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B7355),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Icon(_getRewardIcon(reward.name), color: Colors.white, size: 26),
                                        ),
                                        // Completion indicator - small '!' in corner
                                        if (canAfford)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF78937A),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              child: const Icon(
                                                Icons.priority_high,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Reward Name (larger for single reward)
                                  Text(
                                    reward.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2F1B14),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 8),

                                  // Points Required
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B7355),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${reward.pointsRequired} pts',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Status
                                  if (canAfford)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF78937A),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        availableCount == 1 ? '1 available' : '$availableCount available',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      '${reward.pointsRequired - currentPoints} more needed',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              // Progress Circle with Reward Icon
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Background circle
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        value: 1.0,
                                        strokeWidth: 4,
                                        backgroundColor: Colors.transparent,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                    // Progress circle
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        value: canAfford ? 1.0 : (currentPoints / reward.pointsRequired).clamp(0.0, 1.0),
                                        strokeWidth: 4,
                                        backgroundColor: Colors.transparent,
                                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFB2C1B0)), // Green color for progress line
                                      ),
                                    ),
                                    // Reward Icon in center
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B7355),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: Icon(_getRewardIcon(reward.name), color: Colors.white, size: 22),
                                    ),
                                    // Completion indicator - small '!' in corner
                                    if (canAfford)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF78937A),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(
                                            Icons.priority_high,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Reward Name
                              Text(
                                reward.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F1B14),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              // Points Required
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B7355),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${reward.pointsRequired} pts',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Status
                              if (canAfford)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF78937A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    availableCount == 1 ? '1 available' : '$availableCount available',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '${reward.pointsRequired - currentPoints} more needed',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF666666),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],


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
