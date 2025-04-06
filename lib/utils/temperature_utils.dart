import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/product.dart';
import '../models/storage.dart' as storage;

class TemperatureUtils {
  /// Checks if the temperature is within the acceptable range
  static bool isTemperatureInRange(double temperature, TemperatureRequirement requirement) {
    return temperature >= requirement.minTemperature && 
           temperature <= requirement.maxTemperature;
  }
  
  /// Calculates the temperature deviation from the acceptable range
  static double getTemperatureDeviation(double temperature, TemperatureRequirement requirement) {
    if (temperature < requirement.minTemperature) {
      return requirement.minTemperature - temperature;
    } else if (temperature > requirement.maxTemperature) {
      return temperature - requirement.maxTemperature;
    } else {
      return 0.0;
    }
  }
  
  /// Converts temperature from Celsius to Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }
  
  /// Converts temperature from Fahrenheit to Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }
  
  /// Gets a color representing the temperature status
  static Color getTemperatureStatusColor(double temperature, TemperatureRequirement requirement) {
    if (isTemperatureInRange(temperature, requirement)) {
      return AppConstants.successColor;
    } else {
      double deviation = getTemperatureDeviation(temperature, requirement);
      if (deviation <= AppConstants.temperatureAlertThreshold) {
        return AppConstants.warningColor;
      } else {
        return AppConstants.errorColor;
      }
    }
  }
  
  /// Gets a temperature zone based on the temperature value
  static String getTemperatureZoneFromValue(double temperature) {
    for (var entry in AppConstants.temperatureZones.entries) {
      double minTemp = entry.value['minTemp'];
      double maxTemp = entry.value['maxTemp'];
      
      if (temperature >= minTemp && temperature <= maxTemp) {
        return entry.key;
      }
    }
    return 'ambient'; // Default to ambient if no match
  }
  
  /// Gets a temperature zone color based on the zone name
  static Color getTemperatureZoneColor(String zoneName) {
    if (AppConstants.temperatureZones.containsKey(zoneName)) {
      return AppConstants.temperatureZones[zoneName]!['color'] as Color;
    }
    return AppConstants.primaryColor;
  }
  
  /// Gets a temperature zone icon based on the zone name
  static IconData getTemperatureZoneIcon(String zoneName) {
    if (AppConstants.temperatureZones.containsKey(zoneName)) {
      return AppConstants.temperatureZones[zoneName]!['icon'] as IconData;
    }
    return Icons.thermostat;
  }
  
  /// Formats temperature for display with unit
  static String formatTemperature(double temperature, {bool showUnit = true, bool showDecimal = true}) {
    if (showDecimal) {
      return '${temperature.toStringAsFixed(1)}${showUnit ? '°C' : ''}';
    } else {
      return '${temperature.round()}${showUnit ? '°C' : ''}';
    }
  }
  
  /// Gets temperature requirement for a specific temperature zone
  static TemperatureRequirement getRequirementForZone(TemperatureZone zone) {
    String zoneName = zone.toString().split('.').last;
    if (AppConstants.temperatureZones.containsKey(zoneName)) {
      double minTemp = AppConstants.temperatureZones[zoneName]!['minTemp'];
      double maxTemp = AppConstants.temperatureZones[zoneName]!['maxTemp'];
      return TemperatureRequirement(
        minTemperature: minTemp,
        maxTemperature: maxTemp,
        zone: zone,
      );
    }
    
    // Default to ambient if zone not found
    return TemperatureRequirement(
      minTemperature: 15.0,
      maxTemperature: 25.0,
      zone: TemperatureZone.ambient,
    );
  }
  
  /// Gets temperature range display string for a temperature zone
  static String getTemperatureRangeDisplay(TemperatureZone zone) {
    String zoneName = zone.toString().split('.').last;
    if (AppConstants.temperatureZones.containsKey(zoneName)) {
      double minTemp = AppConstants.temperatureZones[zoneName]!['minTemp'];
      double maxTemp = AppConstants.temperatureZones[zoneName]!['maxTemp'];
      return '${formatTemperature(minTemp)} to ${formatTemperature(maxTemp)}';
    }
    return 'Temperature range not available';
  }
  
  /// Calculates a simulated temperature for demo purposes
  static double getSimulatedTemperature(TemperatureRequirement requirement, {bool maintainRange = true}) {
    if (maintainRange) {
      // Simulate temperature within range with small variations
      double range = requirement.maxTemperature - requirement.minTemperature;
      double middleTemp = requirement.minTemperature + (range / 2);
      double variation = range * 0.3; // Vary within 30% of the range
      
      return middleTemp + (variation * (DateTime.now().millisecondsSinceEpoch % 100) / 100 - variation / 2);
    } else {
      // Simulate temperature breach (for testing alerts)
      bool breachHigh = DateTime.now().second % 2 == 0;
      if (breachHigh) {
        return requirement.maxTemperature + 3.0;
      } else {
        return requirement.minTemperature - 3.0;
      }
    }
  }
}

/// Get a color corresponding to a temperature zone
Color getTemperatureZoneColor(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return Colors.blue;
    case TemperatureZone.chilled:
      return Colors.cyan;
    case TemperatureZone.cool:
      return Colors.teal;
    case TemperatureZone.ambient:
      return Colors.orange;
  }
}

/// Get an icon corresponding to a temperature zone
IconData getTemperatureZoneIcon(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return Icons.ac_unit;
    case TemperatureZone.chilled:
      return Icons.thermostat;
    case TemperatureZone.cool:
      return Icons.wb_twilight;
    case TemperatureZone.ambient:
      return Icons.wb_sunny;
  }
}

/// Get a description for a temperature zone
String getTemperatureZoneDescription(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return 'Below -18°C';
    case TemperatureZone.chilled:
      return '0°C to 4°C';
    case TemperatureZone.cool:
      return '5°C to 15°C';
    case TemperatureZone.ambient:
      return 'Room temperature (15°C to 25°C)';
  }
}

/// Check if a temperature is within the specified range for a zone
bool isTemperatureInRange(TemperatureZone zone, double temperature) {
  switch (zone) {
    case TemperatureZone.frozen:
      return temperature <= -18;
    case TemperatureZone.chilled:
      return temperature >= 0 && temperature <= 4;
    case TemperatureZone.cool:
      return temperature >= 5 && temperature <= 15;
    case TemperatureZone.ambient:
      return temperature >= 15 && temperature <= 25;
  }
}

/// Get the ideal temperature for a zone
double getIdealTemperature(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return -20;
    case TemperatureZone.chilled:
      return 2;
    case TemperatureZone.cool:
      return 10;
    case TemperatureZone.ambient:
      return 20;
  }
}

/// Get the minimum temperature for a zone
double getMinTemperature(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return -25;
    case TemperatureZone.chilled:
      return 0;
    case TemperatureZone.cool:
      return 5;
    case TemperatureZone.ambient:
      return 15;
  }
}

/// Get the maximum temperature for a zone
double getMaxTemperature(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return -18;
    case TemperatureZone.chilled:
      return 4;
    case TemperatureZone.cool:
      return 15;
    case TemperatureZone.ambient:
      return 25;
  }
}

/// Returns a color based on temperature zone
Color getColorForTemperatureZone(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return Colors.blue.shade700;
    case TemperatureZone.chilled:
      return Colors.lightBlue.shade400;
    case TemperatureZone.cool:
      return Colors.lightGreen;
    case TemperatureZone.ambient:
      return Colors.amber;
    default:
      return Colors.grey;
  }
}

/// Returns an icon based on temperature zone
IconData getIconForTemperatureZone(TemperatureZone zone) {
  switch (zone) {
    case TemperatureZone.frozen:
      return Icons.ac_unit;
    case TemperatureZone.chilled:
      return Icons.severe_cold;
    case TemperatureZone.cool:
      return Icons.waves;
    case TemperatureZone.ambient:
      return Icons.wb_sunny;
    default:
      return Icons.thermostat;
  }
}

/// Extension to add display names to TemperatureStatus enum
extension TemperatureStatusExtension on storage.TemperatureStatus {
  String get displayName {
    switch (this) {
      case storage.TemperatureStatus.normal:
        return 'Normal';
      case storage.TemperatureStatus.warning:
        return 'Warning';
      case storage.TemperatureStatus.outOfRange:
        return 'Out of Range';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (this) {
      case storage.TemperatureStatus.normal:
        return Colors.green;
      case storage.TemperatureStatus.warning:
        return Colors.orange;
      case storage.TemperatureStatus.outOfRange:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Checks if a temperature is within the given temperature requirement
bool isTemperatureWithinRange(
    double temperature, TemperatureRequirement requirement) {
  return temperature >= requirement.minTemperature &&
      temperature <= requirement.maxTemperature;
}

/// Determines the temperature status based on current temperature and recommended range
storage.TemperatureStatus getTemperatureStatus(
    double currentTemp, double minTemp, double maxTemp) {
  // Add buffer zones for warnings (within 2 degrees of limits)
  if (currentTemp < minTemp || currentTemp > maxTemp) {
    return storage.TemperatureStatus.outOfRange;
  } else if (currentTemp < minTemp + 2 || currentTemp > maxTemp - 2) {
    return storage.TemperatureStatus.warning;
  } else {
    return storage.TemperatureStatus.normal;
  }
} 