import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'account_page.dart';
import 'rewards_page.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart';
import 'services/qr_code_service.dart';
import 'services/points_service.dart';
import 'models/user_qr_code.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
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
                          const Text(
                            '847 Points • 84 Free Coffees',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                      child: const QRScannerWidget(),
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
                  final isStaff = user?.staff ?? false;

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

                          // Progress Circle Points Card
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7EDE4), // Match main background
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
                                    // Progress Circle - Made smaller
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
                                              value: 0.7, // 7/10 = 0.7
                                              strokeWidth: 6,
                                              backgroundColor: Colors.transparent,
                                              valueColor: const AlwaysStoppedAnimation<Color>(
                                                Color(0xFF8B7355), // Darker beige
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
                                    // Points text - Made smaller
                                    const Text(
                                      '7 pts',
                                      style: TextStyle(
                                        color: Color(0xFF2F1B14),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      '3 to next free drink',
                                      style: TextStyle(
                                        color: Color(0xFF8B7355), // Darker beige
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
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

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (BarcodeCapture capture) {
            if (!isScanning) return;

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                setState(() {
                  isScanning = false;
                });
                _handleScanResult(barcode.rawValue!);
                break;
              }
            }
          },
        ),
        // Scanning overlay
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF8B7355),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void _handleScanResult(String scannedData) async {
    // Close the scanner dialog
    Navigator.of(context).pop();

    // Get current user (staff member)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffUser = authProvider.currentUser;

    if (staffUser == null || !staffUser.staff) {
      _showErrorDialog('Only staff members can scan QR codes.');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
              ),
              SizedBox(height: 16),
              Text('Processing QR code...'),
            ],
          ),
        );
      },
    );

    try {
      final qrCodeService = QRCodeService();
      final pointsService = PointsService();

      // First validate QR code format locally
      if (!QRCodeService.isValidQRCodeFormat(scannedData)) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Invalid QR code format. Please scan a valid customer QR code.');
        return;
      }

      // Validate the QR code with server
      final validationResult = await qrCodeService.validateQRCode(scannedData);

      if (!mounted) return;

      if (validationResult == null) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('QR code not found or invalid. Please ensure the customer has a valid account.');
        return;
      }

      final userId = validationResult['user_id'] as int;
      final userName = validationResult['user_name'] as String? ?? 'Customer';

      // Check if this QR code can be scanned (prevent duplicates)
      final canScan = await pointsService.canScanQRCode(scannedData, staffUser.id!);

      if (!mounted) return;

      if (!canScan) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('This QR code has been scanned recently. Please wait before scanning again.');
        return;
      }

      // Add points to the user
      final success = await pointsService.addPointsToUser(
        userId: userId,
        staffUserId: staffUser.id!,
        pointsAmount: 1,
        description: 'QR code scan by ${staffUser.displayName ?? staffUser.email}',
      );

      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        _showSuccessDialog(userName, scannedData);
      } else {
        _showErrorDialog('Failed to add points. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }

  void _showSuccessDialog(String userName, String qrData) {
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
              Text(
                'QR Code: $qrData',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '1 point added successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Error',
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
}

// Widget for displaying user's QR code
class UserQRCodeWidget extends StatefulWidget {
  final int userId;

  const UserQRCodeWidget({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserQRCodeWidget> createState() => _UserQRCodeWidgetState();
}

class _UserQRCodeWidgetState extends State<UserQRCodeWidget> {
  final QRCodeService _qrCodeService = QRCodeService();
  UserQRCode? _userQRCode;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQRCode();
  }

  Future<void> _loadQRCode() async {
    try {
      final qrCode = await _qrCodeService.getUserQRCode(widget.userId);
      if (mounted) {
        setState(() {
          _userQRCode = qrCode;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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

    if (_error != null || _userQRCode == null) {
      return SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to load QR code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadQRCode();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return QrImageView(
      data: _userQRCode!.qrCodeData,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF2F1B14),
      ),
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF2F1B14),
      ),
    );
  }
}
