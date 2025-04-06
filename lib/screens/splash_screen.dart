import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/user.dart';
import 'auth/login_screen.dart';
import 'customer/home_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';
import 'delivery/delivery_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      _initializeApp();
    }
  }
  
  Future<void> _initializeApp() async {
    print("SplashScreen: _initializeApp called");
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    print("SplashScreen: Initializing product provider");
    // Initialize product data
    await productProvider.initialize();
    
    print("SplashScreen: Starting timer for navigation");
    // Start a timer to show splash screen for minimum time
    _timer = Timer(const Duration(seconds: 2), () {
      _navigateToAppropriateScreen();
    });
  }

  void _navigateToAppropriateScreen() {
    print("SplashScreen: _navigateToAppropriateScreen called");
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print("SplashScreen: isAuthenticated=${authProvider.isAuthenticated}");
    if (authProvider.isAuthenticated) {
      // Navigate based on user type
      print("SplashScreen: User is authenticated, userType=${authProvider.currentUser?.userType}");
      if (authProvider.isCustomer) {
        print("SplashScreen: Navigating to HomeScreen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (authProvider.isVendor) {
        print("SplashScreen: Navigating to VendorDashboardScreen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VendorDashboardScreen()),
        );
      } else if (authProvider.isDeliveryPartner) {
        print("SplashScreen: Navigating to DeliveryDashboardScreen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DeliveryDashboardScreen()),
        );
      } else {
        // Default to customer home screen for any other user type
        print("SplashScreen: User type not recognized, defaulting to HomeScreen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Not authenticated, navigate to login screen
      print("SplashScreen: User not authenticated, navigating to LoginScreen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              AppConstants.secondaryColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Icon(
              Icons.ac_unit,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              AppConstants.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Tagline
            Text(
              AppConstants.appDescription,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
} 