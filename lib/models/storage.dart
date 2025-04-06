import 'package:flutter/material.dart';

import 'product.dart';
import 'user.dart';
import 'review.dart';

/// StorageFacility represents a cold storage facility registered in the system
class StorageFacility {
  final String id;
  final String name;
  final String ownerId; // User ID of the owner (vendor)
  final Address address;
  final String licenseNumber;
  final String contactPhone;
  final List<StorageCompartment> compartments;
  final bool isVerified;
  final double rating;
  final int totalRatings;
  final List<String> images;
  final String description;
  final Map<String, double> hourlyRates; // Rates by temperature zone
  final Map<String, double> dailyRates; // Rates by temperature zone
  final Map<String, double> monthlyRates; // Rates by temperature zone
  final List<Review> reviews; // Facility reviews
  
  StorageFacility({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.address,
    required this.licenseNumber,
    required this.contactPhone,
    required this.compartments,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.images = const [],
    this.description = '',
    required this.hourlyRates,
    required this.dailyRates,
    required this.monthlyRates,
    this.reviews = const [],
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'address': address.toMap(),
      'licenseNumber': licenseNumber,
      'contactPhone': contactPhone,
      'compartments': compartments.map((c) => c.toMap()).toList(),
      'isVerified': isVerified,
      'rating': rating,
      'totalRatings': totalRatings,
      'images': images,
      'description': description,
      'hourlyRates': hourlyRates,
      'dailyRates': dailyRates,
      'monthlyRates': monthlyRates,
      'reviews': reviews.map((r) => r.toMap()).toList(),
    };
  }
  
  // Create from Map
  factory StorageFacility.fromMap(Map<String, dynamic> map) {
    return StorageFacility(
      id: map['id'],
      name: map['name'],
      ownerId: map['ownerId'],
      address: Address.fromMap(map['address']),
      licenseNumber: map['licenseNumber'],
      contactPhone: map['contactPhone'],
      compartments: (map['compartments'] as List)
          .map((c) => StorageCompartment.fromMap(c))
          .toList(),
      isVerified: map['isVerified'] ?? false,
      rating: map['rating'] ?? 0.0,
      totalRatings: map['totalRatings'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] ?? '',
      hourlyRates: Map<String, double>.from(map['hourlyRates'] ?? {}),
      dailyRates: Map<String, double>.from(map['dailyRates'] ?? {}),
      monthlyRates: Map<String, double>.from(map['monthlyRates'] ?? {}),
      reviews: map['reviews'] != null 
          ? (map['reviews'] as List).map((r) => Review.fromMap(r)).toList()
          : [],
    );
  }
  
  // Get total available capacity
  double get totalCapacity {
    return compartments.fold(0.0, (sum, comp) => sum + comp.capacity);
  }
  
  // Get available capacity
  double get availableCapacity {
    return compartments.fold(
      0.0, 
      (sum, comp) => sum + (comp.isAvailable ? comp.availableCapacity : 0.0)
    );
  }
  
  // Get compartments by temperature zone
  List<StorageCompartment> getCompartmentsByZone(TemperatureZone zone) {
    return compartments.where((comp) => comp.temperatureZone == zone).toList();
  }
  
  // Get phone number (alias for contactPhone for backward compatibility)
  String get phoneNumber => contactPhone;
}

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
  final TemperatureStatus temperatureStatus;
  
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
    TemperatureStatus? temperatureStatus,
  }) : temperatureStatus = temperatureStatus ?? 
      _calculateTemperatureStatus(currentTemperature, temperatureZone);
  
  static TemperatureStatus _calculateTemperatureStatus(
      double temp, TemperatureZone zone) {
    // Define expected temperature ranges for each zone
    double minTemp;
    double maxTemp;
    
    switch (zone) {
      case TemperatureZone.frozen:
        minTemp = -25.0;
        maxTemp = -18.0;
        break;
      case TemperatureZone.chilled:
        minTemp = 0.0;
        maxTemp = 4.0;
        break;
      case TemperatureZone.cool:
        minTemp = 8.0;
        maxTemp = 15.0;
        break;
      case TemperatureZone.ambient:
        minTemp = 15.0;
        maxTemp = 25.0;
        break;
      default:
        minTemp = 0.0;
        maxTemp = 25.0;
    }
    
    // Check temperature status
    if (temp < minTemp || temp > maxTemp) {
      return TemperatureStatus.outOfRange;
    } else if (temp < minTemp + 2 || temp > maxTemp - 2) {
      return TemperatureStatus.warning;
    } else {
      return TemperatureStatus.normal;
    }
  }
  
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
      'temperatureStatus': temperatureStatus.toString(),
    };
  }
  
  // Create from Map
  factory StorageCompartment.fromMap(Map<String, dynamic> map) {
    return StorageCompartment(
      id: map['id'],
      name: map['name'],
      temperatureZone: TemperatureZone.values.firstWhere(
          (z) => z.toString().split('.').last.toLowerCase() == (map['temperatureZone'] ?? 'chilled').toLowerCase(),
          orElse: () => TemperatureZone.chilled),
      currentTemperature: map['currentTemperature'],
      minTemperature: map['minTemperature'],
      maxTemperature: map['maxTemperature'],
      capacity: map['capacity'],
      isAvailable: map['isAvailable'] ?? true,
      items: map['items'] != null
          ? (map['items'] as List).map((i) => StoredItem.fromMap(i)).toList()
          : [],
      occupiedCapacity: map['occupiedCapacity'] ?? 0.0,
      temperatureStatus: TemperatureStatusExtension.fromString(map['temperatureStatus'] ?? 'normal'),
    );
  }
  
  // Available capacity
  double get availableCapacity => capacity - occupiedCapacity;
  
  // Check if temperature is in valid range
  bool get isTemperatureValid {
    return currentTemperature >= minTemperature && 
           currentTemperature <= maxTemperature;
  }
}

/// StoredItem represents a product stored in a compartment
class StoredItem {
  final String id;
  final String productId;
  final String ownerId; // Farmer/Producer who owns this item
  final String productName;
  final String category;
  final double quantity; // Quantity in weight (kg)
  final DateTime storedDate;
  final DateTime expiryDate;
  final StorageBookingType bookingType;
  final BookingStatus status;
  final double spaceOccupied; // Space in cubic meters
  final String? compartmentId; // ID of the compartment where item is stored
  
  StoredItem({
    required this.id,
    required this.productId,
    required this.ownerId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.storedDate,
    required this.expiryDate,
    required this.bookingType,
    required this.status,
    required this.spaceOccupied,
    this.compartmentId,
  });
  
  // Add name getter as an alias for productName
  String get name => productName;

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'ownerId': ownerId,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'storedDate': storedDate.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'bookingType': bookingType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'spaceOccupied': spaceOccupied,
      'compartmentId': compartmentId,
    };
  }
  
  // Create from Map
  factory StoredItem.fromMap(Map<String, dynamic> map) {
    return StoredItem(
      id: map['id'],
      productId: map['productId'],
      ownerId: map['ownerId'],
      productName: map['productName'],
      category: map['category'],
      quantity: map['quantity'],
      storedDate: DateTime.fromMillisecondsSinceEpoch(map['storedDate']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      bookingType: StorageBookingTypeExtension.fromString(map['bookingType']),
      status: BookingStatusExtension.fromString(map['status']),
      spaceOccupied: map['spaceOccupied'],
      compartmentId: map['compartmentId'],
    );
  }
  
  // Days until expiry
  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }
  
  // Is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }
  
  // Is near expiry (within 3 days)
  bool get isNearExpiry {
    return daysUntilExpiry <= 3 && !isExpired;
  }
}

/// Storage booking types
enum StorageBookingType {
  hourly,
  daily,
  weekly,
  monthly,
  custom
}

/// Extension for StorageBookingType
extension StorageBookingTypeExtension on StorageBookingType {
  String get displayName {
    switch (this) {
      case StorageBookingType.hourly:
        return 'Hourly';
      case StorageBookingType.daily:
        return 'Daily';
      case StorageBookingType.weekly:
        return 'Weekly';
      case StorageBookingType.monthly:
        return 'Monthly';
      case StorageBookingType.custom:
        return 'Custom';
    }
  }
  
  static StorageBookingType fromString(String value) {
    return StorageBookingType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => StorageBookingType.hourly,
    );
  }
}

/// Booking status
enum BookingStatus {
  pending, // Awaiting confirmation
  confirmed, // Booking confirmed
  active, // Currently in storage
  expired, // Storage period expired
  cancelled, // Booking cancelled
  completed // Storage period completed and items removed
}

/// Extension for BookingStatus
extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.expired:
        return 'Expired';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
  
  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

/// Enum for temperature status
enum TemperatureStatus {
  normal,
  warning,
  outOfRange
}

/// Extension for TemperatureStatus enum
extension TemperatureStatusExtension on TemperatureStatus {
  String get displayName {
    switch (this) {
      case TemperatureStatus.normal:
        return 'Normal';
      case TemperatureStatus.warning:
        return 'Warning';
      case TemperatureStatus.outOfRange:
        return 'Out of Range';
      default:
        return 'Unknown';
    }
  }

  static TemperatureStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'normal':
        return TemperatureStatus.normal;
      case 'optimal':
        return TemperatureStatus.normal;
      case 'warning':
        return TemperatureStatus.warning;
      case 'outofrange':
      case 'out_of_range':
        return TemperatureStatus.outOfRange;
      default:
        return TemperatureStatus.normal;
    }
  }
} 