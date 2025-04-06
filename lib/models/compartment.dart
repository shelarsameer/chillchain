import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

enum CompartmentStatus {
  available,
  occupied,
  maintenance,
  reserved
}

enum TemperatureZone {
  frozen,
  chilled,
  cool,
  ambient
}

class Compartment {
  final String id;
  final String facilityId;
  final String name;
  final String description;
  final double capacity; // in cubic meters
  final TemperatureZone temperatureZone;
  final double minTemperature;
  final double maxTemperature;
  final double currentTemperature;
  final CompartmentStatus status;
  final String? currentOrderId;
  final String? currentCustomerId;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final List<String>? productIds;
  final Map<String, dynamic>? metadata;

  Compartment({
    required this.id,
    required this.facilityId,
    required this.name,
    required this.description,
    required this.capacity,
    required this.temperatureZone,
    required this.minTemperature,
    required this.maxTemperature,
    required this.currentTemperature,
    required this.status,
    this.currentOrderId,
    this.currentCustomerId,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.productIds,
    this.metadata,
  });

  factory Compartment.fromJson(Map<String, dynamic> json) {
    return Compartment(
      id: json['id'] as String,
      facilityId: json['facilityId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      capacity: (json['capacity'] as num).toDouble(),
      temperatureZone: TemperatureZone.values.firstWhere(
        (e) => e.toString() == json['temperatureZone'],
        orElse: () => TemperatureZone.frozen,
      ),
      minTemperature: (json['minTemperature'] as num).toDouble(),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      currentTemperature: (json['currentTemperature'] as num).toDouble(),
      status: CompartmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => CompartmentStatus.available,
      ),
      currentOrderId: json['currentOrderId'] as String?,
      currentCustomerId: json['currentCustomerId'] as String?,
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'] as String)
          : null,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'] as String)
          : null,
      productIds: (json['productIds'] as List<dynamic>?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityId': facilityId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'temperatureZone': temperatureZone.toString(),
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'currentTemperature': currentTemperature,
      'status': status.toString(),
      'currentOrderId': currentOrderId,
      'currentCustomerId': currentCustomerId,
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'nextMaintenanceDate': nextMaintenanceDate?.toIso8601String(),
      'productIds': productIds,
      'metadata': metadata,
    };
  }

  Compartment copyWith({
    String? id,
    String? facilityId,
    String? name,
    String? description,
    double? capacity,
    TemperatureZone? temperatureZone,
    double? minTemperature,
    double? maxTemperature,
    double? currentTemperature,
    CompartmentStatus? status,
    String? currentOrderId,
    String? currentCustomerId,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    List<String>? productIds,
    Map<String, dynamic>? metadata,
  }) {
    return Compartment(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      temperatureZone: temperatureZone ?? this.temperatureZone,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      currentCustomerId: currentCustomerId ?? this.currentCustomerId,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      productIds: productIds ?? this.productIds,
      metadata: metadata ?? this.metadata,
    );
  }
} 