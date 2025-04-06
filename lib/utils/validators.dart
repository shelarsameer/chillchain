/// Utility class with form field validators
class Validators {
  /// Validates that a field is not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that a field contains a valid email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates that a field contains a valid password (min 6 characters)
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    return null;
  }

  /// Validates that a field contains a valid number
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  /// Validates that a field contains a valid positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numberError = validateNumber(value, fieldName);
    if (numberError != null) {
      return numberError;
    }
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }
    
    return null;
  }

  /// Validates that a field contains a valid integer
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer';
    }
    
    return null;
  }

  /// Validates that a field contains a valid positive integer
  static String? validatePositiveInteger(String? value, String fieldName) {
    final integerError = validateInteger(value, fieldName);
    if (integerError != null) {
      return integerError;
    }
    
    final number = int.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }
    
    return null;
  }

  /// Validates that a field contains a valid phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Basic validation - at least 10 digits
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedValue.length < 10) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validates that a field contains a valid name (letters, spaces, hyphens, apostrophes)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    // Allow letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-\']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Please enter a valid $fieldName';
    }
    
    return null;
  }

  /// Validates that a field contains a valid URL
  static String? validateUrl(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validates that a field does not exceed a maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    
    return null;
  }

  /// Validates that a field has a minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }

  /// Validates that a field matches a specific pattern
  static String? validatePattern(String? value, RegExp pattern, String message) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    if (!pattern.hasMatch(value)) {
      return message;
    }
    
    return null;
  }
} 