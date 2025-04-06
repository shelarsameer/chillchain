import 'package:flutter/material.dart';
import 'product.dart';
import 'storage.dart';

/// StorageCompartment represents a storage unit within a facility
class StorageCompartment {
  final String id;
  final String name; // Compartment identifier e.g., "A1", "Freezer-3"
  final TemperatureZone temperatureZone;
  final double currentTemperature;
  final double minTemperature;
  final double maxTemperature;
  final double capacity; // Capacity in cubic meters
  final bool isAvailable;
  final List<StoredItem> items;
  final double occupiedCapacity;
  
  StorageCompartment({
    required this.id,
    required this.name,
    required this.temperatureZone,
    required this.currentTemperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.capacity,
    this.isAvailable = true,
    this.items = const [],
    this.occupiedCapacity = 0.0,
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'temperatureZone': temperatureZone.toString().split('.').last,
      'currentTemperature': currentTemperature,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'capacity': capacity,
      'isAvailable': isAvailable,
      'items': items.map((item) => item.toMap()).toList(),
      'occupiedCapacity': occupiedCapacity,
    };
  }
  
  // Create from Map
  factory StorageCompartment.fromMap(Map<String, dynamic> map) {
    return StorageCompartment(
      id: map['id'],
      name: map['name'],
      temperatureZone: TemperatureZoneExtension.fromString(map['temperatureZone']),
      currentTemperature: map['currentTemperature'],
      minTemperature: map['minTemperature'],
      maxTemperature: map['maxTemperature'],
      capacity: map['capacity'],
      isAvailable: map['isAvailable'] ?? true,
      items: map['items'] != null
          ? (map['items'] as List).map((i) => StoredItem.fromMap(i)).toList()
          : [],
      occupiedCapacity: map['occupiedCapacity'] ?? 0.0,
    );
  }
  
  // Available capacity
  double get availableCapacity => capacity - occupiedCapacity;
  
  // Total capacity - alias for capacity for backward compatibility
  double get totalCapacity => capacity;
  
  // Check if temperature is in valid range
  bool get isTemperatureValid {
    return currentTemperature >= minTemperature && 
           currentTemperature <= maxTemperature;
  }
  
  // Get temperature status
  TemperatureStatus get temperatureStatus {
    if (!isTemperatureValid) {
      if (currentTemperature < minTemperature) {
        return TemperatureStatus.warning;
      } else {
        return TemperatureStatus.warning;
      }
    }
    
    // If temperature is in the middle 75% of the valid range, it's optimal
    final range = maxTemperature - minTemperature;
    final lowerOptimal = minTemperature + range * 0.125;
    final upperOptimal = maxTemperature - range * 0.125;
    
    if (currentTemperature >= lowerOptimal && currentTemperature <= upperOptimal) {
      return TemperatureStatus.normal;
    }
    
    return TemperatureStatus.normal;
  }
} 