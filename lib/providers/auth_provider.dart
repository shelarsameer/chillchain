import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/user.dart' as user_models;
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/vendor/vendor_dashboard_screen.dart';
import '../screens/delivery/delivery_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../main.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // User state
  user_models.User? _currentUser;
  
  // Loading and error states
  bool _isLoading = false;
  String? _error;
  
  // Stream subscription for changes to the user
  late StreamSubscription<user_models.User?> _userSubscription;
  
  AuthProvider() {
    _initializeUserStream();
  }
  
  // Initialize the stream subscription
  void _initializeUserStream() {
    _userSubscription = _authService.currentUserStream.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }
  
  // Navigate based on user role
  void _navigateBasedOnUserRole(user_models.UserType? role) {
    if (role == null) {
      print('AuthProvider: User role is null');
      return;
    }

    print('AuthProvider: _navigateBasedOnUserRole called with role=$role');
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('AuthProvider: Error - navigation context is null');
      return;
    }
    
    switch (role) {
      case user_models.UserType.customer:
        print('AuthProvider: Navigating to HomeScreen');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case user_models.UserType.vendor:
        print('AuthProvider: Navigating to VendorDashboardScreen');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const VendorDashboardScreen()),
          (route) => false,
        );
        break;
      case user_models.UserType.deliveryPartner:
        print('AuthProvider: Navigating to DeliveryDashboardScreen');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DeliveryDashboardScreen()),
          (route) => false,
        );
        break;
      case user_models.UserType.admin:
        print('AuthProvider: Navigating to AdminDashboardScreen');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          (route) => false,
        );
        break;
      default:
        print('AuthProvider: Unknown user type: $role');
    }
    print('AuthProvider: Navigation completed');
  }
  
  // Getters
  user_models.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCustomer => _currentUser?.userType == user_models.UserType.customer;
  bool get isVendor => _currentUser?.userType == user_models.UserType.vendor;
  bool get isDeliveryPartner => _currentUser?.userType == user_models.UserType.deliveryPartner;
  bool get isAdmin => _currentUser?.userType == user_models.UserType.admin;
  
  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    print("AuthProvider: signIn called with email=$email");
    try {
      _setLoading(true);
      _clearError();
  
      final user = await _authService.signInWithEmailAndPassword(email, password);
      print("AuthProvider: Sign in successful, user=${user.name}, role=${user.userType}");

      _currentUser = user;
      
      print("AuthProvider: About to navigate based on user role");
      // Force a short delay to make sure UI is updated correctly
      await Future.delayed(Duration(milliseconds: 100));
      _navigateBasedOnUserRole(user.userType);
      print("AuthProvider: Navigation completed");
      return true;
    } catch (e) {
      print("AuthProvider: Error during sign in: $e");
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Register with email and password
  Future<bool> register(
    String email, 
    String password, 
    String name, 
    String phoneNumber,
    user_models.UserType userType,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.registerWithEmailAndPassword(
        email, 
        password, 
        name, 
        phoneNumber,
        userType,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Navigate to the login screen (for logout or session expiry)
  void navigateToLogin() {
    print("AuthProvider: navigateToLogin called");
    final context = navigatorKey.currentContext;
    if (context == null) {
      print("AuthProvider: ERROR - No valid navigation context available for login redirect");
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Sign out the current user
  Future<void> signOut() async {
    print("AuthProvider: signOut called");
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
      navigateToLogin();
      print("AuthProvider: User signed out, navigated to login");
    } catch (e) {
      print("AuthProvider: Error during sign out: $e");
      _setError(e.toString());
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = await _authService.updateUserProfile(
        _currentUser!.id,
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );
      _currentUser = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Update user profile with email and name
  Future<bool> updateUserProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // Check if email is being changed
      final bool isEmailChanged = email != _currentUser!.email;
      
      // Update profile using the existing method
      final success = await updateProfile(
        name: name,
      );
      
      // If email is changed, additional verification might be needed
      // For MVP we'll assume it works without extra verification
      if (isEmailChanged && success) {
        // In a real app, we would send a verification email
        // and only update the email once verified
        // For now, we'll update the user object directly
        _currentUser = _currentUser!.copyWith(email: email);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update password
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // For the MVP, we'll just simulate password change
      // In a real app, we would verify the current password
      // and then update it in the backend
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Password updated successfully
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Delete account
  Future<bool> deleteAccount({
    required String password,
  }) async {
    if (_currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // For the MVP, we'll just simulate account deletion
      // In a real app, we would verify the password
      // and then delete the account in the backend
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Sign out the user after account deletion
      await signOut();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Add user address
  Future<bool> addAddress(user_models.Address address) async {
    if (_currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = await _authService.addUserAddress(
        _currentUser!.id,
        address,
      );
      _currentUser = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Refresh current user
  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _userSubscription.cancel();
    _authService.dispose();
    super.dispose();
  }
} 