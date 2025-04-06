import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../screens/customer/storage_facilities_screen.dart';

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
                _buildMenuItem(
                  context,
                  title: 'Profile',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile screen
                  },
                ),
                _buildMenuItem(
                  context,
                  title: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings screen
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  title: 'Sign Out',
                  icon: Icons.logout,
                  onTap: () async {
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
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
} 