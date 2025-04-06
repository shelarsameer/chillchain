import 'package:flutter/material.dart';

class AppConstants {
  // App information
  static const String appName = 'ChillChain';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Cold storage logistics for perishable goods';
  
  // Routes
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String productListRoute = '/products';
  static const String productDetailRoute = '/product-detail';
  static const String cartRoute = '/cart';
  static const String checkoutRoute = '/checkout';
  static const String orderHistoryRoute = '/order-history';
  static const String orderDetailRoute = '/order-detail';
  static const String trackOrderRoute = '/track-order';
  static const String profileRoute = '/profile';
  static const String vendorDashboardRoute = '/vendor-dashboard';
  static const String deliveryPartnerDashboardRoute = '/delivery-partner-dashboard';
  
  // Temperature Zones
  static const Map<String, Map<String, dynamic>> temperatureZones = {
    'frozen': {
      'name': 'Frozen',
      'minTemp': -25.0,
      'maxTemp': -10.0,
      'color': Color(0xFF2196F3), // Blue
      'description': 'For frozen products like ice cream and frozen meals',
      'icon': Icons.ac_unit,
    },
    'deepFrozen': {
      'name': 'Deep Frozen',
      'minTemp': -40.0,
      'maxTemp': -25.0,
      'color': Color(0xFF3F51B5), // Indigo
      'description': 'For items requiring very low temperatures like seafood',
      'icon': Icons.severe_cold,
    },
    'chilled': {
      'name': 'Chilled',
      'minTemp': 0.0,
      'maxTemp': 5.0,
      'color': Color(0xFF4CAF50), // Green
      'description': 'For dairy products, meat, and other refrigerated items',
      'icon': Icons.thermostat,
    },
    'cool': {
      'name': 'Cool',
      'minTemp': 6.0,
      'maxTemp': 15.0,
      'color': Color(0xFFFFEB3B), // Yellow
      'description': 'For fruits, vegetables, and other cool products',
      'icon': Icons.wb_sunny_outlined,
    },
    'ambient': {
      'name': 'Ambient',
      'minTemp': 15.0,
      'maxTemp': 25.0,
      'color': Color(0xFFFF9800), // Orange
      'description': 'For non-perishable items or room temperature storage',
      'icon': Icons.wb_sunny,
    },
  };
  
  // Temperature alerts
  static const double temperatureAlertThreshold = 2.0;
  
  // Product categories
  static const List<String> productCategories = [
    'Dairy',
    'Meat',
    'Seafood',
    'Fruits',
    'Vegetables',
    'Frozen Foods',
    'Bakery',
    'Beverages',
    'Ice Cream',
    'Pharmaceuticals',
    'Other'
  ];
  
  // Delivery vehicle types
  static const List<String> vehicleTypes = [
    'Refrigerated Van',
    'Refrigerated Truck',
    'Refrigerated Motorcycle',
    'Cooler Box Motorcycle',
    'Insulated Vehicle',
  ];
  
  // API constants
  static const String apiBaseUrl = 'https://api.chillchain.com/v1';
  static const int apiTimeoutSeconds = 10;
  
  // UI Constants
  static const Color primaryColor = Color(0xFF03A9F4);
  static const Color secondaryColor = Color(0xFF00BCD4);
  static const Color accentColor = Color(0xFFFF5722);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultBorderRadius = 8.0;
  static const double smallBorderRadius = 4.0;
  static const double largeBorderRadius = 16.0;
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userTypeKey = 'user_type';
  static const String lastLoginKey = 'last_login';
  
  // Messages
  static const String temperatureAlertMessage = 'Temperature outside acceptable range!';
  static const String orderDeliveredMessage = 'Your order has been delivered successfully!';
  static const String orderConfirmedMessage = 'Your order has been confirmed!';
  static const String orderInTransitMessage = 'Your order is on the way!';
  
  // Demo content for MVP
  static const bool isDemoMode = true;
  static const int demoRefreshSeconds = 30;
} 