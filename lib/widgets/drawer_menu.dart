import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../screens/customer/storage_facilities_screen.dart';
import '../screens/customer/cold_storage_marketplace_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, user),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  title: 'Home',
                  icon: Icons.home,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                if (user?.userType == UserType.customer || user?.userType == UserType.vendor)
                  _buildMenuItem(
                    context,
                    title: 'Cold Storage Facilities',
                    icon: Icons.warehouse,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StorageFacilitiesScreen(),
                        ),
                      );
                    },
                  ),
                if (user?.userType == UserType.customer)
                  _buildMenuItem(
                    context,
                    title: 'Cold Storage Marketplace',
                    icon: Icons.shopping_bag,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ColdStorageMarketplaceScreen(),
                        ),
                      );
                    },
                  ),
                _buildMenuItem(
                  context,
                  title: 'Categories',
                  icon: Icons.category,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to categories screen
                    Navigator.pushNamed(context, AppConstants.productListRoute);
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Order History',
                  icon: Icons.history,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to order history screen
                    Navigator.pushNamed(context, AppConstants.orderHistoryRoute);
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Track Orders',
                  icon: Icons.track_changes,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to track orders screen
                    Navigator.pushNamed(context, AppConstants.trackOrderRoute);
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Profile',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile screen
                    Navigator.pushNamed(context, AppConstants.profileRoute);
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings screen
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  title: 'Sign Out',
                  icon: Icons.logout,
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: false, // Replace with actual theme state
                onChanged: (value) {
                  // Toggle theme
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true, // Replace with actual notification state
                onChanged: (value) {
                  // Toggle notifications
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('English'),
              onTap: () {
                // Show language options
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: AppConstants.primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user?.name ?? 'Guest',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool indented = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: indented ? 32.0 : 16.0,
        right: 16.0,
      ),
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
} 