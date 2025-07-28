import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'account_page.dart';
import 'rewards_page.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/points_provider.dart';
import 'services/qr_service.dart';
import 'services/points_service.dart';
import 'widgets/qr_scanner_widget.dart';
import 'widgets/user_qr_widget.dart';
import 'widgets/points_display_widget.dart';
import 'widgets/user_points_summary_widget.dart';



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
      ],
      child: MaterialApp(
        title: 'Ginger & Co Coffee',
        debugShowCheckedModeBanner: false, // Remove debug banner
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA0956B)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
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
                    image: AssetImage('assets/logo.png'),
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
        return const HomeWidget();
      },
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _logoTapCount = 0;

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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
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
              const Icon(
                Icons.local_cafe,
                color: Color(0xFF8B7355),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '$userName has $currentPoints points',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Would you like to redeem 10 points for a free coffee?',
                style: TextStyle(
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
              child: const Text('Yes, Redeem Free Coffee'),
            ),
          ],
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

  void _onLogoTap() {
    setState(() {
      _logoTapCount++;
    });

    if (_logoTapCount >= 5) {
      _logoTapCount = 0; // Reset counter
      _showStaffPinDialog();
    }
  }

  void _showStaffPinDialog() {
    String enteredPin = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Staff Login',
                style: TextStyle(
                  color: Color(0xFFA0956B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter Staff PIN:'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < enteredPin.length
                              ? const Color(0xFF8B7355) // Darker beige
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Simple text field for PIN entry
                  SizedBox(
                    width: 150,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: const InputDecoration(
                        hintText: '• • •',
                        counterText: '',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B7355), width: 2), // Darker beige
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 3) {
                          _checkPin(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _checkPin(String pin) {
    // PIN functionality removed - staff access now controlled by database
    Navigator.of(context).pop(); // Close pin dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staff access is now controlled by your account permissions'),
        backgroundColor: Color(0xFF8B7355), // Darker beige
      ),
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
        // Refresh points in provider for all UI components
        await pointsProvider.refreshUserPoints(userId);

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
        return AlertDialog(
          title: const Text(
            'Free Coffee Redeemed!',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header Section
              Container(
                width: double.infinity,
                height: 220, // Made smaller
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFA0956B), // Warm beige at top
                      Color(0xFFC4B896), // Light beige
                      Color(0x80C4B896), // Semi-transparent light beige
                      Color(0x00F7EDE4), // Fully transparent to match new background
                    ],
                    stops: [0, 0.4, 0.8, 1],
                    begin: AlignmentDirectional(0, -1), // Top
                    end: AlignmentDirectional(0, 1),   // Bottom
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Top menu row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40), // Spacer for balance
                          const Expanded(
                            child: Text(
                              'Ginger & Co Coffee',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                            onSelected: (String value) {
                              if (value == 'account') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AccountPage(),
                                  ),
                                );
                              } else if (value == 'logout') {
                                _showLogoutDialog();
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'account',
                                child: Row(
                                  children: [
                                    Icon(Icons.person, color: Color(0xFF8B7355)), // Darker beige
                                    SizedBox(width: 8),
                                    Text('My Account'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Logout', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Logo (moved closer to text above)
                      Flexible(
                        child: GestureDetector(
                          onTap: _onLogoTap,
                          child: Image.asset(
                            'assets/logo.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RewardsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.card_giftcard, color: Color(0xFF8B7355)),
                          label: const Text('View Rewards'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B7355), // Match button color
                            foregroundColor: Colors.white,
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
                      ],
                    ),
                  );
                },
              ),




            ],
            ),
          ),
        ),
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
