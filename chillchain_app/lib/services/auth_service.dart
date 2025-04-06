import 'dart:async';
import 'dart:convert';

// Commented out to avoid compilation issues for now
// import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/user.dart' as app_models;

class AuthService {
  static const String _baseUrl = '${AppConstants.apiBaseUrl}/auth';
  
  // Firebase auth instance
  // final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
  
  // For demo purposes
  static final Map<String, app_models.User> _demoUsers = {
    'customer@example.com': app_models.User(
      id: 'user1',
      name: 'John Customer',
      email: 'customer@example.com',
      phoneNumber: '+1234567890',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      userType: app_models.UserType.customer,
      addresses: [
        app_models.Address(
          id: 'addr1',
          streetAddress: '123 Main St',
          city: 'Anytown',
          state: 'CA',
          postalCode: '12345',
          country: 'USA',
          latitude: 37.7749,
          longitude: -122.4194,
          label: 'Home',
        ),
        app_models.Address(
          id: 'addr2',
          streetAddress: '456 Market St',
          city: 'Anytown',
          state: 'CA',
          postalCode: '12345',
          country: 'USA',
          latitude: 37.7639,
          longitude: -122.4089,
          label: 'Work',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActive: DateTime.now(),
    ),
    'vendor@example.com': app_models.User(
      id: 'vendor1',
      name: 'Jane Vendor',
      email: 'vendor@example.com',
      phoneNumber: '+1987654321',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      userType: app_models.UserType.vendor,
      addresses: [
        app_models.Address(
          id: 'addr3',
          streetAddress: '789 Cold Storage Ave',
          city: 'Anytown',
          state: 'CA',
          postalCode: '12345',
          country: 'USA',
          latitude: 37.7639,
          longitude: -122.4089,
          label: 'Warehouse',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastActive: DateTime.now(),
    ),
    'driver@example.com': app_models.User(
      id: 'driver1',
      name: 'Bob Driver',
      email: 'driver@example.com',
      phoneNumber: '+1567891234',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      userType: app_models.UserType.deliveryPartner,
      addresses: [
        app_models.Address(
          id: 'addr4',
          streetAddress: '321 Vehicle St',
          city: 'Anytown',
          state: 'CA',
          postalCode: '12345',
          country: 'USA',
          latitude: 37.7639,
          longitude: -122.4089,
          label: 'Home',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastActive: DateTime.now(),
    ),
    'admin@example.com': app_models.User(
      id: 'admin1',
      name: 'Admin User',
      email: 'admin@example.com',
      phoneNumber: '+1555555555',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      userType: app_models.UserType.admin,
      addresses: [
        app_models.Address(
          id: 'addr5',
          streetAddress: '999 Admin Blvd',
          city: 'Anytown',
          state: 'CA',
          postalCode: '12345',
          country: 'USA',
          latitude: 37.7639,
          longitude: -122.4089,
          label: 'Office',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastActive: DateTime.now(),
    ),
  };
  
  // Demo password for MVP - in a real app this would never be stored like this
  static const String _demoPassword = 'password123';
  
  // Current user stream
  Stream<app_models.User?> get currentUserStream {
    if (AppConstants.isDemoMode) {
      // Return a stream that emits the current user whenever it changes
      return _userChanges.stream;
    }
    
    // In a real app, we'd use Firebase Auth
    // return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
    //   if (firebaseUser == null) {
    //     return null;
    //   }
    //   
    //   // Fetch the user data from the backend
    //   return await getCurrentUser();
    // });
    
    // For now, let's just return the same stream in all cases since we're in demo mode
    return _userChanges.stream;
  }
  
  // Stream controller for demo user changes
  final StreamController<app_models.User?> _userChanges = StreamController<app_models.User?>.broadcast();
  
  // Constructor
  AuthService() {
    // Initialize the user stream with the current user
    _initCurrentUser();
  }
  
  // Initialize the current user from shared preferences if available
  Future<void> _initCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConstants.userIdKey);
      
      if (userId != null) {
        final user = await getCurrentUser();
        _userChanges.add(user);
      } else {
        _userChanges.add(null);
      }
    } catch (e) {
      _userChanges.add(null);
      print('Error initializing current user: $e');
    }
  }
  
  // Get the current user
  Future<app_models.User?> getCurrentUser() async {
    try {
      if (AppConstants.isDemoMode) {
        // Return the demo user
        final prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString('user_email');
        
        if (userEmail != null && _demoUsers.containsKey(userEmail)) {
          final user = _demoUsers[userEmail]!;
          // Update last active time
          final updatedUser = user.copyWith(lastActive: DateTime.now());
          _demoUsers[userEmail] = updatedUser;
          return updatedUser;
        }
        
        return null;
      }
      
      // In a real app, we'd use Firebase Auth
      // final firebaseUser = _firebaseAuth.currentUser;
      // 
      // if (firebaseUser == null) {
      //   return null;
      // }
      
      // For now, assume we're not authenticated
      return null;
    } catch (e) {
      // If there's an error, return null
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Sign in with email and password
  Future<app_models.User> signInWithEmailAndPassword(String email, String password) async {
    try {
      print("Attempting to sign in with email: $email and password: $password");
      if (AppConstants.isDemoMode) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Check if the user exists
        print("Demo mode on, checking if user exists in _demoUsers: ${_demoUsers.keys.toList()}");
        if (_demoUsers.containsKey(email)) {
          // Check the password - in a real app, this would be done securely
          print("User found, checking password");
          if (password == _demoPassword) {
            // Get the user
            final user = _demoUsers[email]!;
            print("Password matches, user authenticated: ${user.name} (${user.userType})");
            
            // Store the user info in shared preferences
            final prefs = await SharedPreferences.getInstance();
            print("Storing user data in SharedPreferences");
            await prefs.setString(AppConstants.userIdKey, user.id);
            await prefs.setString(AppConstants.userTypeKey, user.userType.toString().split('.').last);
            await prefs.setString('user_email', email);
            await prefs.setInt(AppConstants.lastLoginKey, DateTime.now().millisecondsSinceEpoch);
            await prefs.setString(AppConstants.tokenKey, 'demo-token-${DateTime.now().millisecondsSinceEpoch}');
            
            // Update the user stream
            print("Adding user to _userChanges stream");
            _userChanges.add(user);
            
            return user;
          } else {
            print("Password does not match");
            throw Exception('Invalid password');
          }
        } else {
          print("User not found with email: $email");
          throw Exception('User not found');
        }
      }
      
      // In a real app, we'd use Firebase Auth
      // ... Firebase auth code ...
      
      // For now, throw an exception
      throw Exception('Only demo mode is supported');
    } catch (e) {
      print("Error during sign in: $e");
      rethrow;
    }
  }
  
  // Register with email and password
  Future<app_models.User> registerWithEmailAndPassword(
    String email, 
    String password, 
    String name, 
    String phoneNumber,
    app_models.UserType userType,
  ) async {
    try {
      if (AppConstants.isDemoMode) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Check if the user already exists
        if (_demoUsers.containsKey(email)) {
          throw Exception('User already exists');
        }
        
        // Generate a new user ID
        final userId = 'user${_demoUsers.length + 1}';
        
        // Create a new user
        final newUser = app_models.User(
          id: userId,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          userType: userType,
          addresses: [],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        // Add the user to the demo users
        _demoUsers[email] = newUser;
        
        // Store the user info in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userIdKey, newUser.id);
        await prefs.setString(AppConstants.userTypeKey, newUser.userType.toString().split('.').last);
        await prefs.setString('user_email', email);
        await prefs.setInt(AppConstants.lastLoginKey, DateTime.now().millisecondsSinceEpoch);
        await prefs.setString(AppConstants.tokenKey, 'demo-token-${DateTime.now().millisecondsSinceEpoch}');
        
        // Update the user stream
        _userChanges.add(newUser);
        
        return newUser;
      }
      
      // In a real app, we'd use Firebase Auth
      // ... Firebase auth code ...
      
      // For now, throw an exception
      throw Exception('Only demo mode is supported');
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      if (AppConstants.isDemoMode) {
        // Clear the user info from shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.userIdKey);
        await prefs.remove(AppConstants.userTypeKey);
        await prefs.remove('user_email');
        await prefs.remove(AppConstants.lastLoginKey);
        await prefs.remove(AppConstants.tokenKey);
        
        // Update the user stream
        _userChanges.add(null);
        
        return;
      }
      
      // In a real app, we'd use Firebase Auth
      // await _firebaseAuth.signOut();
      
      // For now, do the same as in demo mode
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userIdKey);
      await prefs.remove(AppConstants.userTypeKey);
      await prefs.remove('user_email');
      await prefs.remove(AppConstants.lastLoginKey);
      await prefs.remove(AppConstants.tokenKey);
      
      // Update the user stream
      _userChanges.add(null);
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user profile
  Future<app_models.User> updateUserProfile(
    String userId, 
    {
      String? name,
      String? phoneNumber,
      String? profileImageUrl,
    }
  ) async {
    try {
      if (AppConstants.isDemoMode) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Find the user
        final prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString('user_email');
        
        if (userEmail == null || !_demoUsers.containsKey(userEmail)) {
          throw Exception('User not found');
        }
        
        // Get the current user
        final currentUser = _demoUsers[userEmail]!;
        
        // Update the user
        final updatedUser = currentUser.copyWith(
          name: name ?? currentUser.name,
          phoneNumber: phoneNumber ?? currentUser.phoneNumber,
          profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
          lastActive: DateTime.now(),
        );
        
        // Update the demo users
        _demoUsers[userEmail] = updatedUser;
        
        // Update the user stream
        _userChanges.add(updatedUser);
        
        return updatedUser;
      }
      
      // Get the token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Update the user in the backend
      final response = await http.patch(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        }),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return app_models.User.fromMap(data);
      } else {
        throw Exception('Failed to update user profile: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Add user address
  Future<app_models.User> addUserAddress(
    String userId, 
    app_models.Address address,
  ) async {
    try {
      if (AppConstants.isDemoMode) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Find the user
        final prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString('user_email');
        
        if (userEmail == null || !_demoUsers.containsKey(userEmail)) {
          throw Exception('User not found');
        }
        
        // Get the current user
        final currentUser = _demoUsers[userEmail]!;
        
        // Update the user with the new address
        final updatedAddresses = List<app_models.Address>.from(currentUser.addresses)..add(address);
        final updatedUser = currentUser.copyWith(
          addresses: updatedAddresses,
          lastActive: DateTime.now(),
        );
        
        // Update the demo users
        _demoUsers[userEmail] = updatedUser;
        
        // Update the user stream
        _userChanges.add(updatedUser);
        
        return updatedUser;
      }
      
      // Get the token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Add the address in the backend
      final response = await http.post(
        Uri.parse('$_baseUrl/users/$userId/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(address.toMap()),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return app_models.User.fromMap(data);
      } else {
        throw Exception('Failed to add user address: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (AppConstants.isDemoMode) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Check if the user exists
        if (_demoUsers.containsKey(email)) {
          // In a real app, this would send a password reset email
          return;
        } else {
          throw Exception('User not found');
        }
      }
      
      // Send password reset email
      // await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
  
  // Dispose
  void dispose() {
    _userChanges.close();
  }
} 