import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'account_page.dart';
import 'rewards_page.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/points_provider.dart';
import 'providers/reward_provider.dart';
import 'services/qr_service.dart';
import 'services/points_service.dart';
import 'services/points_change_detector.dart';
import 'services/global_coffee_stamp_controller.dart';
import 'widgets/qr_scanner_widget.dart';
import 'widgets/user_qr_widget.dart';
import 'widgets/points_display_widget.dart';
import 'widgets/user_points_summary_widget.dart';
import 'widgets/global_coffee_stamp_overlay.dart';
import 'widgets/preset_profile_icons.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PointsProvider()),
        ChangeNotifierProvider(create: (context) => RewardProvider()),
      ],
      child: MaterialApp(
        title: 'DailyStamp',
        debugShowCheckedModeBanner: false, // Remove debug banner
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA0956B)),
          useMaterial3: true,
        ),
        home: const GlobalCoffeeStampOverlay(
          child: AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state (but not during login attempts)
        if (authProvider.isLoading && authProvider.currentUser == null && authProvider.lastError == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7EDE4),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/icon.png'),
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFF8B7355),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show login page if not authenticated
        if (!authProvider.isAuthenticated) {
          return const LoginPage();
        }

        // Show main app if authenticated
        return const MainNavigationWrapper();
      },
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeWidget(),
    const RewardsPage(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B7355),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with WidgetsBindingObserver {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final PointsChangeDetector _pointsChangeDetector = PointsChangeDetector();
  final GlobalCoffeeStampController _coffeeStampController = GlobalCoffeeStampController();
  StreamSubscription<PointsChangeEvent>? _pointsChangeSubscription;

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
    WidgetsBinding.instance.addObserver(this);

    // Refresh points when the home screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPointsIfAuthenticated();
      _setupPointsChangeDetection();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pointsChangeSubscription?.cancel();
    _pointsChangeDetector.stopMonitoring();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh points when app comes to foreground
      _refreshPointsIfAuthenticated();
      _pointsChangeDetector.resumeMonitoring();
    } else if (state == AppLifecycleState.paused) {
      _pointsChangeDetector.pauseMonitoring();
    }
  }

  void _refreshPointsIfAuthenticated() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.id != null) {
      pointsProvider.refreshUserPoints(user!.id!);
    }
    rewardProvider.refreshRewards();
  }

  // Method to trigger reward animation from external sources
  void triggerRewardAnimation() {
    print('[HomeWidget] External trigger for reward animation');
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    final firstReward = rewardProvider.firstReward;
    final rewardName = firstReward?.name ?? 'Coffee';
    _coffeeStampController.showRewardRedeemed(message: 'Enjoy Your $rewardName!');
  }

  void _setupPointsChangeDetection() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.id != null) {
      // Start monitoring points changes
      _pointsChangeDetector.startMonitoring(user!.id!);

      // Set initial points to avoid false positives
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      final currentPoints = pointsProvider.getUserPoints(user.id!);
      if (currentPoints != null) {
        _pointsChangeDetector.setInitialPoints(currentPoints.currentPoints);
      }

      // Listen for points changes and trigger global animation
      _pointsChangeSubscription = _pointsChangeDetector.pointsChangeStream.listen((event) {
        print('[HomeWidget] Points change detected: ${event.pointsAdded} points added');

        // Check if this is a reward redemption (negative points that match reward values)
        final firstReward = rewardProvider.firstReward;
        final pointsNeeded = firstReward?.pointsRequired ?? 10;

        if (event.pointsAdded == -pointsNeeded) {
          print('[HomeWidget] Reward redemption detected (-$pointsNeeded points), showing reward animation');
          final rewardName = firstReward?.name ?? 'Coffee';
          _coffeeStampController.showRewardRedeemed(message: 'Enjoy Your $rewardName!');
        } else if (event.pointsAdded == -(pointsNeeded - 1)) {
          // Handle legacy case where 1 point was added after deducting reward points
          print('[HomeWidget] Reward redemption detected (-${pointsNeeded - 1} points), showing reward animation');
          final rewardName = firstReward?.name ?? 'Coffee';
          _coffeeStampController.showRewardRedeemed(message: 'Enjoy Your $rewardName!');
        } else if (event.pointsAdded > 0) {
          // Regular points addition
          print('[HomeWidget] Positive points change (+${event.pointsAdded}), showing points animation');
          _coffeeStampController.showPointsAdded(event.pointsAdded);
        } else {
          print('[HomeWidget] Other points change: ${event.pointsAdded} points (no animation)');
        }
      });
    }
  }

  void _showQRCodeDialog() {
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
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
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

                      return UserQRCodeWidget(userId: user!.id!);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // User Info
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    final displayName = user?.displayName ?? user?.email ?? 'Guest';

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B7355),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          UserPointsSummaryWidget(userId: user?.id ?? 0),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7355), // Darker beige
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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


  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _handleScanResult(Map<String, dynamic> result) {
    if (result['success'] == true) {
      // Check if customer is eligible for a reward
      if (result['reward_eligible'] == true) {
        _showRewardDialog(
          result['user_name'] ?? 'Customer',
          result['current_points'] ?? 0,
          result['user_id'],
        );
      } else {
        _showSuccessDialog(
          result['user_name'] ?? 'Customer',
          result['new_total']?.toString() ?? '0',
        );
      }
    } else {
      _showErrorDialog(result['message'] ?? 'Scan failed');
    }
  }

  void _showSuccessDialog(String userName, String newTotal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'QR Code Scanned!',
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Customer: $userName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '1 point added successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'New total: $newTotal points',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF8B7355)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRewardDialog(String userName, int currentPoints, int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<RewardProvider>(
          builder: (context, rewardProvider, child) {
            final firstReward = rewardProvider.firstReward;
            final pointsNeeded = firstReward?.pointsRequired ?? 10; // Fallback to 10
            final rewardName = firstReward?.name ?? 'free coffee';

            return AlertDialog(
              title: const Text(
                'Reward Available!',
                style: TextStyle(
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRewardIcon(firstReward?.name),
                    color: const Color(0xFF8B7355),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$userName has $currentPoints points',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Would you like to redeem $pointsNeeded points for $rewardName?',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Add 1 point as normal (no reward redemption)
                    _addNormalPoint(userId, userName);
                  },
                  child: const Text(
                    'No, Add 1 Point',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Redeem reward
                    _redeemReward(userId, userName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B7355),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Yes, Redeem $rewardName'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Scan Failed',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF8B7355)),
              ),
            ),
          ],
        );
      },
    );
  }









  void _addNormalPoint(int userId, String userName) async {
    try {
      final pointsService = PointsService();
      final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);

      if (currentUser == null || currentUser.id == null) {
        _showErrorDialog('Authentication error');
        return;
      }

      final success = await pointsService.addPointsToUser(
        userId: userId,
        staffUserId: currentUser.id!,
        pointsAmount: 1,
        description: 'QR code scan',
      );

      if (success) {
        // Get updated points total
        final updatedPoints = await pointsService.getUserPoints(userId);
        final newTotal = updatedPoints?.currentPoints ?? 0;

        // Refresh points in provider for all UI components
        await pointsProvider.refreshUserPoints(userId);

        if (mounted) {
          _showSuccessDialog(userName, newTotal.toString());
        }
      } else {
        if (mounted) {
          _showErrorDialog('Failed to add points');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error adding points: $e');
      }
    }
  }

  void _redeemReward(int userId, String userName) async {
    try {
      final qrService = QRService();
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      final result = await qrService.redeemReward(userId);

      if (result != null && result['success'] == true) {
        print('[HomeWidget] Reward redemption successful on staff side - animation should appear on customer side');

        // Refresh points in provider for all UI components
        await pointsProvider.refreshUserPoints(userId);

        // Do NOT trigger animation here - this runs on STAFF device
        // Animation will be triggered on CUSTOMER device via points change detection

        if (mounted) {
          _showRewardSuccessDialog(userName, result['new_total']?.toString() ?? '0');
        }
      } else {
        if (mounted) {
          _showErrorDialog(result?['message'] ?? 'Failed to redeem reward');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error redeeming reward: $e');
      }
    }
  }

  void _showRewardSuccessDialog(String userName, String newTotal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<RewardProvider>(
          builder: (context, rewardProvider, child) {
            final firstReward = rewardProvider.firstReward;
            final rewardName = firstReward?.name ?? 'Coffee';

            return AlertDialog(
              title: Text(
                'Free $rewardName Redeemed!',
                style: const TextStyle(
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.bold,
                ),
              ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Customer: $userName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Free coffee redeemed successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'New total: $newTotal points',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF8B7355)),
              ),
            ),
          ],
            );
          },
        );
      },
    );
  }

  void _showScanQRDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 400,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B7355),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Scan Customer QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // QR Scanner
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF8B7355), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: QRScannerWidget(
                        onScanResult: _handleScanResult,
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

  void _showFindUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFF8B7355),
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Find us',
                style: TextStyle(
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visit us at:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B7355),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Ginger & Co. Coffee\n30-31 Princess Street\nShrewsbury\nSY1 1LW',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF7EDE4), // Updated beige background
        body: SafeArea(
          top: true,
          child: RefreshIndicator(
            onRefresh: () async {
              // Refresh points when user pulls down
              _refreshPointsIfAuthenticated();
            },
            child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Logo Text
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.asset(
                    'assets/logotext.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              
              // Welcome Card - Show customer card for everyone, with staff indicator if applicable
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;

                  return Column(
                    children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color(0x1A000000),
                          offset: Offset(0.0, 5),
                        )
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  final user = authProvider.currentUser;
                                  final displayName = user?.displayName ?? (user?.email != null ? user!.email.split('@')[0] : 'Guest');
                                  final isStaff = user?.staff ?? false;

                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(2),
                                        child: Text(
                                          'Welcome back,',
                                          style: TextStyle(
                                            color: Color(0xFF8B7355), // Darker beige
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                              color: Color(0xFF2F1B14),
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (isStaff) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2F1B14),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'STAFF',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AccountPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF8B7355), // Darker beige to match buttons
                                    shape: BoxShape.circle,
                                  ),
                                  child: Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return UserProfileIcon(
                                        iconId: authProvider.currentUser?.profileIconId,
                                        size: 30,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Real Points Display
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: PointsDisplayWidget(userId: user?.id ?? 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                        ),
                      ],
                    );
                },
              ),

              // Action Buttons - Different for staff vs customer
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;
                  final isStaff = user?.staff ?? false;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Show My QR Code button (for everyone)
                        ElevatedButton.icon(
                          onPressed: _showQRCodeDialog,
                          icon: const Icon(
                            Icons.qr_code,
                            color: Colors.white
                          ),
                          label: const Text('Show My QR Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B7355), // Darker beige
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Staff QR Scanner button (additional button for staff)
                        if (isStaff) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _showScanQRDialog,
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white
                            ),
                            label: const Text('Scan Customer QR Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F1B14), // Darker color for staff function
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],

                        // Standard customer buttons (for everyone)
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            _launchURL('https://www.gingerandcocoffeeshop.co.uk/menu');
                          },
                          icon: const Icon(Icons.restaurant_menu, color: Color(0xFF8B7355)),
                          label: const Text('Menu'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFF8B7355), // Darker beige
                            minimumSize: const Size(double.infinity, 56),
                            side: const BorderSide(color: Color(0xFF8B7355), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _showFindUsDialog,
                          icon: const Icon(Icons.location_on, color: Color(0xFF8B7355)),
                          label: const Text('Find us'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFF8B7355), // Darker beige
                            minimumSize: const Size(double.infinity, 56),
                            side: const BorderSide(color: Color(0xFF8B7355), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),




            ],
            ),
          ),
        ),
          ), // Close RefreshIndicator
        ),
    );
  }
}




// User QR code display widget
class UserQRCodeWidget extends StatelessWidget {
  final int userId;

  const UserQRCodeWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return UserQRWidget(userId: userId);
  }
}
