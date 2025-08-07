import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/points_provider.dart';
import 'providers/reward_provider.dart';
import 'services/profile_service.dart';
import 'widgets/preset_profile_icons.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {

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

  void _showEditProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProfileDialog(user: user);
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
              color: const Color(0xFF603d22).withValues(alpha: 0.1), // Coffee brown
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF603d22), // Coffee brown
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF603d22), // Coffee brown
            ),
          ),
        ],
      ),
    );
  }



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF603d22), // Coffee brown
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Could not open $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F2), // Same as main screen background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: RefreshIndicator(
          onRefresh: () async {
            _refreshPoints();
          },
          color: const Color(0xFF603d22),
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
                    colors: [Color(0xFF603d22), Color(0xFF8B7355)], // Coffee brown gradient
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
                        onTap: _showEditProfileDialog,
                        child: Stack(
                          children: [
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return UserProfileIcon(
                                  iconId: authProvider.currentUser?.profileIconId,
                                  size: 100,
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF603d22), // Coffee brown
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
                child: Consumer3<AuthProvider, PointsProvider, RewardProvider>(
                  builder: (context, authProvider, pointsProvider, rewardProvider, child) {
                    final user = authProvider.currentUser;
                    final isLoading = user?.id != null ? pointsProvider.isLoading(user!.id!) : false;
                    final error = user?.id != null ? pointsProvider.getError(user!.id!) : null;
                    final loyaltyPoints = user?.id != null ? pointsProvider.getUserPoints(user!.id!) : null;

                    final currentPoints = loyaltyPoints?.currentPoints ?? 0;
                    final firstReward = rewardProvider.firstReward;
                    final pointsNeeded = firstReward?.pointsRequired ?? 10; // Fallback to 10 if no rewards loaded
                    final freeRewards = currentPoints ~/ pointsNeeded; // Integer division - how many free rewards earned

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
                                    color: Color(0xFF603d22),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (user?.id != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Color(0xFF603d22),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF603d22)),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Loading points...',
                                    style: TextStyle(
                                      color: Color(0xFF603d22),
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
                                    color: Color(0xFF603d22),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Unable to load points',
                                    style: TextStyle(
                                      color: Color(0xFF603d22),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: user?.id != null ? () => pointsProvider.refreshUserPoints(user!.id!) : null,
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(color: Color(0xFF603d22)),
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
                                          color: Color(0xFF603d22),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Current Points',
                                        style: TextStyle(
                                          color: Color(0xFF603d22),
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
                                        '$freeRewards',
                                        style: const TextStyle(
                                          color: Color(0xFF603d22),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Free Rewards',
                                        style: TextStyle(
                                          color: Color(0xFF603d22),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
                      onTap: _showEditProfileDialog,
                    ),
                    const SizedBox(height: 12),
                    _buildAccountOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        _launchURL('https://www.noodev8.com/contact/');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildAccountOption(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        _launchURL('https://www.noodev8.com/privacy-policy/');
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildAccountOption(
                      icon: Icons.delete_forever,
                      title: 'Delete Account',
                      isDestructive: true,
                      onTap: () {
                        _showDeleteAccountDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
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
              color: isDestructive ? Colors.red : const Color(0xFF603d22),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : const Color(0xFF603d22),
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Are you sure you want to delete your account?\n\n'
            'This action cannot be undone and will permanently remove:\n'
            '• Your profile information\n'
            '• All loyalty points\n'
            '• Transaction history\n'
            '• Reward redemption history',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Deleting account...'),
            ],
          ),
        );
      },
    );

    try {
      final success = await authProvider.deleteAccount();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Account deleted successfully - user will be automatically logged out
        // and redirected to login screen by the auth state change
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.lastError ?? 'Failed to delete account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              onPressed: () async {
                Navigator.of(context).pop();
                // Implement actual logout logic
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
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

class EditProfileDialog extends StatefulWidget {
  final User user;

  const EditProfileDialog({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _displayNameController;
  String? _selectedIconId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.user.displayName ?? '');
    _selectedIconId = widget.user.profileIconId;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      _showSnackBar('Please enter a display name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authToken = authProvider.currentUser?.authToken;

      if (authToken == null) {
        _showSnackBar('Authentication error');
        return;
      }

      final result = await ProfileService.updateProfile(
        authToken: authToken,
        displayName: displayName,
        profileIconId: _selectedIconId,
      );

      if (result != null && result['success'] == true) {
        // Update the user in the auth provider
        final updatedUser = widget.user.copyWith(
          displayName: displayName,
          profileIconId: _selectedIconId,
        );
        authProvider.updateCurrentUser(updatedUser);

        if (mounted) {
          _showSnackBar('Profile updated successfully!');
          Navigator.of(context).pop();
        }
      } else {
        _showSnackBar('Failed to update profile');
      }
    } catch (e) {
      _showSnackBar('Error updating profile');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF603d22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF603d22),
              ),
            ),
            const SizedBox(height: 24),

            // Display Name Field
            const Text(
              'Display Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF603d22),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                hintText: 'Enter your display name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF603d22)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF603d22), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Icon Selector
            ProfileIconSelector(
              selectedIconId: _selectedIconId,
              onIconSelected: (iconId) {
                setState(() {
                  _selectedIconId = iconId;
                });
              },
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF603d22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}
