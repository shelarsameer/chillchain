import 'package:intl/intl.dart';

/// A utility class for handling DateTime operations
class DateTimeUtils {
  /// Format a DateTime into a human-readable string
  /// Format: Jan 1, 2023 10:30 AM
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }
  
  /// Format a DateTime into a date-only string
  /// Format: Jan 1, 2023
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
  
  /// Format a DateTime into a time-only string
  /// Format: 10:30 AM
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
  
  /// Format DateTime into a relative time string
  /// e.g. "2 minutes ago", "1 hour ago", "yesterday", etc.
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return formatDate(dateTime);
    }
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Get the start of day for a given DateTime
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  
  /// Get the end of day for a given DateTime
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }
  
  /// Get the start of week for a given DateTime (Sunday as first day)
  static DateTime startOfWeek(DateTime dateTime) {
    final diff = dateTime.weekday % 7;
    return startOfDay(dateTime.subtract(Duration(days: diff)));
  }
  
  /// Get the end of week for a given DateTime (Saturday as last day)
  static DateTime endOfWeek(DateTime dateTime) {
    final diff = 6 - (dateTime.weekday % 7);
    return endOfDay(dateTime.add(Duration(days: diff)));
  }
  
  /// Get the start of month for a given DateTime
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }
  
  /// Get the end of month for a given DateTime
  static DateTime endOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0, 23, 59, 59, 999);
  }
  
  /// Format a duration into a readable string (e.g. "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
} 