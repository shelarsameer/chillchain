import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../utils/temperature_utils.dart';

class TemperatureLog {
  final String id;
  final String deviceId;
  final String facilityId;
  final String vendorId;
  final DateTime timestamp;
  final double temperature;
  final TemperatureZone zone;
  final bool isWithinThreshold;
  final double minThreshold;
  final double maxThreshold;
  
  TemperatureLog({
    required this.id,
    required this.deviceId,
    required this.facilityId,
    required this.vendorId,
    required this.timestamp,
    required this.temperature,
    required this.zone,
    required this.minThreshold,
    required this.maxThreshold,
    required this.isWithinThreshold,
  });
  
  factory TemperatureLog.fromMap(Map<String, dynamic> map) {
    return TemperatureLog(
      id: map['id'],
      deviceId: map['deviceId'],
      facilityId: map['facilityId'],
      vendorId: map['vendorId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      temperature: map['temperature'],
      zone: TemperatureZone.values.firstWhere(
        (e) => e.toString().split('.').last == map['zone'],
        orElse: () => TemperatureZone.ambient,
      ),
      minThreshold: map['minThreshold'],
      maxThreshold: map['maxThreshold'],
      isWithinThreshold: map['isWithinThreshold'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceId': deviceId,
      'facilityId': facilityId,
      'vendorId': vendorId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'temperature': temperature,
      'zone': zone.toString().split('.').last,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'isWithinThreshold': isWithinThreshold,
    };
  }
}

class TemperatureAlertConfig {
  final int delayMinutes;
  final int maxAlerts;
  final bool emailNotification;
  final bool pushNotification;
  final bool smsNotification;
  
  TemperatureAlertConfig({
    this.delayMinutes = 5,
    this.maxAlerts = 3,
    this.emailNotification = true,
    this.pushNotification = true,
    this.smsNotification = false,
  });
}

class TemperatureAlert {
  final String id;
  final TemperatureLog log;
  final DateTime detectedAt;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final String? notes;
  
  TemperatureAlert({
    required this.id,
    required this.log,
    required this.detectedAt,
    this.isAcknowledged = false,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.notes,
  });
}

class FacilityStats {
  final String facilityId;
  final String name;
  final Map<TemperatureZone, double> currentTemperatures;
  final Map<TemperatureZone, double> capacityUsage;
  final List<TemperatureAlert> activeAlerts;
  
  FacilityStats({
    required this.facilityId,
    required this.name,
    required this.currentTemperatures,
    required this.capacityUsage,
    required this.activeAlerts,
  });
}

class TemperatureProvider with ChangeNotifier {
  List<TemperatureLog> _logs = [];
  List<TemperatureAlert> _alerts = [];
  Map<String, FacilityStats> _facilityStats = {};
  
  // Configuration
  TemperatureAlertConfig alertConfig = TemperatureAlertConfig();
  
  // Getters
  List<TemperatureLog> get logs => _logs;
  List<TemperatureAlert> get alerts => _alerts;
  List<TemperatureAlert> get pendingAlerts => 
      _alerts.where((alert) => !alert.isAcknowledged).toList();
  
  Map<String, FacilityStats> get facilityStats => _facilityStats;
  
  // Check if there are any active alerts
  bool get hasActiveAlerts => pendingAlerts.isNotEmpty;
  
  // Demo data generation
  Future<void> fetchTemperatureLogs(String vendorId) async {
    // In a real app, this would fetch temperature logs from a service
    await Future.delayed(const Duration(milliseconds: 800));
    
    final Random random = Random();
    final now = DateTime.now();
    
    final List<TemperatureLog> demoLogs = [];
    final zones = TemperatureZone.values.toList();
    
    // Generate demo temperature logs for the past 24 hours
    for (int hour = 0; hour < 24; hour++) {
      for (final zone in zones) {
        final timestamp = now.subtract(Duration(hours: hour, minutes: random.nextInt(60)));
        
        // Get the expected range for this zone
        final expectedRange = _getExpectedRangeForZone(zone);
        final minThreshold = expectedRange.min;
        final maxThreshold = expectedRange.max;
        
        // Generate a temperature value
        // Mostly within range, but occasionally out of range to simulate issues
        final isWithinRange = random.nextDouble() > 0.1; // 90% chance of being within range
        
        double temperature;
        if (isWithinRange) {
          // Generate a temperature within the expected range
          temperature = minThreshold + random.nextDouble() * (maxThreshold - minThreshold);
        } else {
          // Generate a temperature outside the expected range
          final isAboveRange = random.nextBool();
          if (isAboveRange) {
            temperature = maxThreshold + random.nextDouble() * 3; // Up to 3 degrees above max
          } else {
            temperature = minThreshold - random.nextDouble() * 3; // Up to 3 degrees below min
          }
        }
        
        final log = TemperatureLog(
          id: 'log-${timestamp.millisecondsSinceEpoch}-${zone.toString()}',
          deviceId: 'device-${zone.toString()}-${random.nextInt(3) + 1}',
          facilityId: 'facility-${random.nextInt(2) + 1}',
          vendorId: vendorId,
          timestamp: timestamp,
          temperature: double.parse(temperature.toStringAsFixed(1)),
          zone: zone,
          minThreshold: minThreshold,
          maxThreshold: maxThreshold,
          isWithinThreshold: isWithinRange,
        );
        
        demoLogs.add(log);
        
        // Generate alerts for temperature anomalies
        if (!isWithinRange && hour < 6) { // Only generate alerts for more recent issues
          final alert = TemperatureAlert(
            id: 'alert-${timestamp.millisecondsSinceEpoch}',
            log: log,
            detectedAt: timestamp,
            isAcknowledged: hour > 2, // Acknowledge older alerts
            acknowledgedAt: hour > 2 ? timestamp.add(const Duration(minutes: 15)) : null,
            acknowledgedBy: hour > 2 ? 'staff-member-1' : null,
            notes: hour > 2 ? 'Temperature anomaly acknowledged and addressed' : null,
          );
          
          _alerts.add(alert);
        }
      }
    }
    
    // Sort logs by timestamp, newest first
    demoLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    _logs = demoLogs;
    
    // Generate facility stats
    _generateFacilityStats(vendorId);
    
    notifyListeners();
  }
  
  void _generateFacilityStats(String vendorId) {
    final Map<String, FacilityStats> stats = {};
    final facilityIds = _logs.map((log) => log.facilityId).toSet().toList();
    
    for (final facilityId in facilityIds) {
      final facilityLogs = _logs.where((log) => log.facilityId == facilityId).toList();
      final facilityAlerts = _alerts.where(
        (alert) => alert.log.facilityId == facilityId && !alert.isAcknowledged
      ).toList();
      
      // Get the most recent temperature for each zone
      final currentTemperatures = <TemperatureZone, double>{};
      final capacityUsage = <TemperatureZone, double>{};
      
      for (final zone in TemperatureZone.values) {
        final zoneLogs = facilityLogs.where((log) => log.zone == zone).toList();
        if (zoneLogs.isNotEmpty) {
          // Sort by timestamp, newest first
          zoneLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          // Get the most recent temperature
          currentTemperatures[zone] = zoneLogs.first.temperature;
          // Generate a random capacity usage between 30% and 90%
          capacityUsage[zone] = 0.3 + Random().nextDouble() * 0.6;
        }
      }
      
      stats[facilityId] = FacilityStats(
        facilityId: facilityId,
        name: 'Facility ${facilityId.split('-').last}',
        currentTemperatures: currentTemperatures,
        capacityUsage: capacityUsage,
        activeAlerts: facilityAlerts,
      );
    }
    
    _facilityStats = stats;
  }
  
  // Helper to get expected temperature range for a zone
  ({double min, double max}) _getExpectedRangeForZone(TemperatureZone zone) {
    switch (zone) {
      case TemperatureZone.frozen:
        return (min: -25.0, max: -18.0);
      case TemperatureZone.chilled:
        return (min: 0.0, max: 4.0);
      case TemperatureZone.cool:
        return (min: 4.0, max: 10.0);
      case TemperatureZone.ambient:
        return (min: 15.0, max: 25.0);
    }
  }
  
  // Acknowledge an alert
  Future<void> acknowledgeAlert(String alertId, String userId, String? notes) async {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    
    if (index != -1) {
      final alert = _alerts[index];
      final acknowledgedAlert = TemperatureAlert(
        id: alert.id,
        log: alert.log,
        detectedAt: alert.detectedAt,
        isAcknowledged: true,
        acknowledgedAt: DateTime.now(),
        acknowledgedBy: userId,
        notes: notes,
      );
      
      _alerts[index] = acknowledgedAlert;
      notifyListeners();
      
      // In a real app, you would call a service to update the alert in the backend
    }
  }
  
  // Get temperature logs for a specific facility and zone
  List<TemperatureLog> getLogsForFacilityAndZone(
    String facilityId,
    TemperatureZone zone,
    {DateTime? startDate, DateTime? endDate}
  ) {
    return _logs.where((log) {
      final matchesFacility = log.facilityId == facilityId;
      final matchesZone = log.zone == zone;
      final matchesDateRange = (startDate == null || log.timestamp.isAfter(startDate)) &&
                               (endDate == null || log.timestamp.isBefore(endDate));
      
      return matchesFacility && matchesZone && matchesDateRange;
    }).toList();
  }
  
  // Get the current temperature for a facility zone
  double? getCurrentTemperature(String facilityId, TemperatureZone zone) {
    if (_facilityStats.containsKey(facilityId) && 
        _facilityStats[facilityId]!.currentTemperatures.containsKey(zone)) {
      return _facilityStats[facilityId]!.currentTemperatures[zone];
    }
    return null;
  }
  
  // Get the capacity usage for a facility zone (0.0 to 1.0)
  double getCapacityUsage(String facilityId, TemperatureZone zone) {
    if (_facilityStats.containsKey(facilityId) && 
        _facilityStats[facilityId]!.capacityUsage.containsKey(zone)) {
      return _facilityStats[facilityId]!.capacityUsage[zone]!;
    }
    return 0.0;
  }
} 