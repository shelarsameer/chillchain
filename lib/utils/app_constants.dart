import 'package:flutter/material.dart';

class AppConstants {
  // API configuration
  static const String apiBaseUrl = 'https://api.chillchain.com/v1';
  static const int apiTimeoutSeconds = 30;
  static const bool isDemoMode = true;
  
  // App theme colors
  static final Color primaryColor = Color(0xFF2196F3);
  static final Color secondaryColor = Color(0xFF42A5F5);
  static final Color accentColor = Color(0xFF64B5F6);
  static final Color errorColor = Color(0xFFE53935);
  static final Color successColor = Color(0xFF4CAF50);
  static final Color warningColor = Color(0xFFFFA000);
  static final Color infoColor = Color(0xFF29B6F6);
  
  // Text colors
  static final Color primaryTextColor = Color(0xFF212121);
  static final Color secondaryTextColor = Color(0xFF757575);
  static final Color lightTextColor = Color(0xFFFFFFFF);
  
  // Background colors
  static final Color backgroundColor = Color(0xFFF5F5F5);
  static final Color cardColor = Color(0xFFFFFFFF);
  static final Color dividerColor = Color(0xFFEEEEEE);
  
  // Padding and margin values
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  // Border radius values
  static final BorderRadius defaultBorderRadius = BorderRadius.circular(8.0);
  static final BorderRadius largeBorderRadius = BorderRadius.circular(16.0);
  static final BorderRadius roundedBorderRadius = BorderRadius.circular(24.0);
  static final BorderRadius fullBorderRadius = BorderRadius.circular(999.0);
  
  // Font sizes
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double titleFontSize = 20.0;
  static const double headlineFontSize = 24.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Button heights
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 36.0;
  
  // Icon sizes
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  
  // Max lengths
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxAddressLength = 100;
  static const int maxPasswordLength = 20;
  
  // Min lengths
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  
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
    'Snacks',
    'Prepared Meals',
    'Other'
  ];
  
  // Temperature zones with their color mappings
  static const Map<String, Color> temperatureZoneColors = {
    'frozen': Color(0xFF42A5F5),  // Blue
    'chilled': Color(0xFF26A69A),  // Teal
    'cool': Color(0xFF66BB6A),     // Green
    'ambient': Color(0xFFFFB74D),  // Amber
  };
  
  // App information
  static const String appName = 'ChillChain';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Cold chain management solution';
  static const String appCopyright = '© 2023 ChillChain Inc.';
  
  // Contact information
  static const String supportEmail = 'support@chillchain.com';
  static const String supportPhone = '+1-800-CHILL-CHAIN';
  static const String supportHours = 'Monday to Friday, 9am to 5pm EST';
  
  // URLs
  static const String websiteUrl = 'https://chillchain.com';
  static const String privacyPolicyUrl = 'https://chillchain.com/privacy';
  static const String termsAndConditionsUrl = 'https://chillchain.com/terms';
  static const String helpCenterUrl = 'https://help.chillchain.com';
  
  // Cache durations
  static const Duration defaultCacheDuration = Duration(minutes: 30);
  static const Duration longCacheDuration = Duration(hours: 12);
} 