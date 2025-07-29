import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'providers/auth_provider.dart';
import 'providers/points_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh points when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPoints();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh points when app comes to foreground
      _refreshPoints();
    }
  }

  void _refreshPoints() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.id != null) {
      pointsProvider.refreshUserPoints(user!.id!);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355), // Darker beige
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                  if (_profileImagePath != null)
                    _buildImageOption(
                      icon: Icons.delete,
                      label: 'Remove',
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfileImage();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355).withValues(alpha: 0.1), // Darker beige
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B7355), // Darker beige
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B7355), // Darker beige
            ),
          ),
        ],
      ),
    );
  }

  void _pickImageFromCamera() {
    // Simulate picking image from camera
    // In a real app, you would use image_picker package
    setState(() {
      _profileImagePath = 'camera_image_${DateTime.now().millisecondsSinceEpoch}';
    });
    _showSnackBar('Profile picture updated from camera!');
  }

  void _pickImageFromGallery() {
    // Simulate picking image from gallery
    // In a real app, you would use image_picker package
    setState(() {
      _profileImagePath = 'gallery_image_${DateTime.now().millisecondsSinceEpoch}';
    });
    _showSnackBar('Profile picture updated from gallery!');
  }

  void _removeProfileImage() {
    setState(() {
      _profileImagePath = null;
    });
    _showSnackBar('Profile picture removed!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B7355), // Darker beige
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EDE4), // Updated beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B7355), // Darker beige
        foregroundColor: Colors.white,
        title: const Text(
          'My Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshPoints();
          },
          color: const Color(0xFF8B7355),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B7355), Color(0xFFA0956B)], // Darker beige gradient
                    stops: [0, 1],
                    begin: AlignmentDirectional(1, 1),
                    end: AlignmentDirectional(-1, -1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: _profileImagePath != null
                                  ? ClipOval(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.photo,
                                          color: Color(0xFF8B7355), // Darker beige
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Color(0xFF8B7355), // Darker beige
                                      size: 50,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B7355), // Darker beige
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.currentUser;
                          final displayName = user?.displayName ?? user?.email ?? 'Guest';
                          final email = user?.email ?? '';

                          return Column(
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Points Summary Card
              Padding(
                padding: const EdgeInsets.all(24),
                child: Consumer2<AuthProvider, PointsProvider>(
                  builder: (context, authProvider, pointsProvider, child) {
                    final user = authProvider.currentUser;
                    final isLoading = user?.id != null ? pointsProvider.isLoading(user!.id!) : false;
                    final error = user?.id != null ? pointsProvider.getError(user!.id!) : null;
                    final loyaltyPoints = user?.id != null ? pointsProvider.getUserPoints(user!.id!) : null;

                    final currentPoints = loyaltyPoints?.currentPoints ?? 0;
                    final freeCoffees = currentPoints ~/ 10; // Integer division - how many free coffees earned

                    return Container(
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Loyalty Points',
                                  style: TextStyle(
                                    color: Color(0xFF8B4513),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (user?.id != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Color(0xFF8B4513),
                                      size: 20,
                                    ),
                                    onPressed: () => pointsProvider.refreshUserPoints(user!.id!),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isLoading)
                              const Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Loading points...',
                                    style: TextStyle(
                                      color: Color(0xFF8B4513),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            else if (error != null)
                              Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFF8B4513),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Unable to load points',
                                    style: TextStyle(
                                      color: Color(0xFF8B4513),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: user?.id != null ? () => pointsProvider.refreshUserPoints(user!.id!) : null,
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(color: Color(0xFF8B4513)),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '$currentPoints',
                                        style: const TextStyle(
                                          color: Color(0xFF2F1B14),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Current Points',
                                        style: TextStyle(
                                          color: Color(0xFF8B4513),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$freeCoffees',
                                        style: const TextStyle(
                                          color: Color(0xFF2F1B14),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Free Coffees',
                                        style: TextStyle(
                                          color: Color(0xFF8B4513),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5DEB3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '1 point per scan • 10 points = 1 free coffee',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF8B4513),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Account Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildAccountOption(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {
                        // TODO: Navigate to edit profile
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildAccountOption(
                      icon: Icons.card_giftcard,
                      title: 'Rewards History',
                      onTap: () {
                        // TODO: Navigate to rewards history
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildAccountOption(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        // TODO: Navigate to notifications settings
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildAccountOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildAccountOption(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        // TODO: Navigate to about
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildAccountOption(
                      icon: Icons.logout,
                      title: 'Logout',
                      isDestructive: true,
                      onTap: () {
                        // TODO: Implement logout functionality
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x0A000000),
              offset: Offset(0.0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF8B4513),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : const Color(0xFF2F1B14),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.red : const Color(0xFFCCCCCC),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                // TODO: Implement actual logout logic
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
}
