import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/storage.dart';
import '../models/storage_booking.dart';
import '../models/product.dart';
import '../models/user.dart';

class StorageService {
  static const String _baseUrl = '${AppConstants.apiBaseUrl}/storage';
  static const String _facilitiesCacheKey = 'cached_storage_facilities';
  static const String _bookingsCacheKey = 'cached_storage_bookings';
  static const Duration _cacheDuration = Duration(hours: 1);
  
  // For demo/MVP purpose with demo storage facilities
  static final List<StorageFacility> _demoFacilities = [
    StorageFacility(
      id: '1',
      name: 'Arctic Cold Storage',
      ownerId: 'vendor1',
      address: Address(
        id: 'addr1',
        streetAddress: '123 Freeze Lane',
        city: 'Cooltown',
        state: 'Refrigerator',
        postalCode: '12345',
        country: 'USA',
        latitude: 37.7749,
        longitude: -122.4194,
      ),
      licenseNumber: 'CS-2023-001',
      contactPhone: '555-123-4567',
      compartments: [
        StorageCompartment(
          id: '101',
          name: 'Freezer Unit A',
          temperatureZone: TemperatureZone.frozen,
          currentTemperature: -20.5,
          minTemperature: -25.0,
          maxTemperature: -18.0,
          capacity: 50.0,
          isAvailable: true,
          occupiedCapacity: 15.0,
        ),
        StorageCompartment(
          id: '102',
          name: 'Chiller Unit B',
          temperatureZone: TemperatureZone.chilled,
          currentTemperature: 2.3,
          minTemperature: 0.0,
          maxTemperature: 4.0,
          capacity: 75.0,
          isAvailable: true,
          occupiedCapacity: 25.0,
        ),
        StorageCompartment(
          id: '103',
          name: 'Cool Unit C',
          temperatureZone: TemperatureZone.cool,
          currentTemperature: 10.7,
          minTemperature: 8.0,
          maxTemperature: 15.0,
          capacity: 100.0,
          isAvailable: true,
          occupiedCapacity: 35.0,
        ),
      ],
      isVerified: true,
      rating: 4.5,
      totalRatings: 28,
      images: [
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d',
        'https://images.unsplash.com/photo-1604335398980-adadb8c2e0e3',
      ],
      description: 'State-of-the-art cold storage facility with multiple temperature zones for all your storage needs.',
      hourlyRates: {
        'frozen': 2.5,
        'chilled': 2.0,
        'cool': 1.5,
        'ambient': 1.0,
      },
      dailyRates: {
        'frozen': 45.0,
        'chilled': 35.0,
        'cool': 25.0,
        'ambient': 15.0,
      },
      monthlyRates: {
        'frozen': 1200.0,
        'chilled': 900.0,
        'cool': 700.0,
        'ambient': 500.0,
      },
    ),
    StorageFacility(
      id: '2',
      name: 'FreshKeep Storage Solutions',
      ownerId: 'vendor2',
      address: Address(
        id: 'addr2',
        streetAddress: '456 Chill Avenue',
        city: 'Frostville',
        state: 'Iceberg',
        postalCode: '54321',
        country: 'USA',
        latitude: 34.0522,
        longitude: -118.2437,
      ),
      licenseNumber: 'CS-2023-002',
      contactPhone: '555-987-6543',
      compartments: [
        StorageCompartment(
          id: '201',
          name: 'Deep Freeze 1',
          temperatureZone: TemperatureZone.frozen,
          currentTemperature: -22.1,
          minTemperature: -30.0,
          maxTemperature: -18.0,
          capacity: 80.0,
          isAvailable: true,
          occupiedCapacity: 40.0,
        ),
        StorageCompartment(
          id: '202',
          name: 'Chill Zone 2',
          temperatureZone: TemperatureZone.chilled,
          currentTemperature: 3.1,
          minTemperature: 0.0,
          maxTemperature: 5.0,
          capacity: 120.0,
          isAvailable: true,
          occupiedCapacity: 70.0,
        ),
      ],
      isVerified: true,
      rating: 4.8,
      totalRatings: 35,
      images: [
        'https://images.unsplash.com/photo-1595246007497-68986932fb03',
        'https://images.unsplash.com/photo-1596411753066-0a50b3707fae',
      ],
      description: 'Premium cold storage with 24/7 monitoring and state-of-the-art temperature control systems.',
      hourlyRates: {
        'frozen': 3.0,
        'chilled': 2.5,
        'cool': 2.0,
        'ambient': 1.5,
      },
      dailyRates: {
        'frozen': 55.0,
        'chilled': 45.0,
        'cool': 35.0,
        'ambient': 25.0,
      },
      monthlyRates: {
        'frozen': 1500.0,
        'chilled': 1200.0,
        'cool': 900.0,
        'ambient': 700.0,
      },
    ),
    StorageFacility(
      id: '3',
      name: 'FarmFresh Cold Chain',
      ownerId: 'vendor3',
      address: Address(
        id: 'addr3',
        streetAddress: '789 Harvest Road',
        city: 'Cropsville',
        state: 'Farmland',
        postalCode: '67890',
        country: 'USA',
        latitude: 41.8781,
        longitude: -87.6298,
      ),
      licenseNumber: 'CS-2023-003',
      contactPhone: '555-456-7890',
      compartments: [
        StorageCompartment(
          id: '301',
          name: 'Produce Cooler A',
          temperatureZone: TemperatureZone.cool,
          currentTemperature: 12.4,
          minTemperature: 8.0,
          maxTemperature: 15.0,
          capacity: 150.0,
          isAvailable: true,
          occupiedCapacity: 90.0,
        ),
        StorageCompartment(
          id: '302',
          name: 'Dairy Chiller B',
          temperatureZone: TemperatureZone.chilled,
          currentTemperature: 3.7,
          minTemperature: 2.0,
          maxTemperature: 6.0,
          capacity: 100.0,
          isAvailable: true,
          occupiedCapacity: 45.0,
        ),
      ],
      isVerified: true,
      rating: 4.2,
      totalRatings: 18,
      images: [
        'https://images.unsplash.com/photo-1565614861542-01c2c9766f65',
      ],
      description: 'Specialized storage facility designed for farmers and local food producers.',
      hourlyRates: {
        'frozen': 2.0,
        'chilled': 1.8,
        'cool': 1.5,
        'ambient': 1.0,
      },
      dailyRates: {
        'frozen': 40.0,
        'chilled': 35.0,
        'cool': 30.0,
        'ambient': 20.0,
      },
      monthlyRates: {
        'frozen': 1100.0,
        'chilled': 950.0,
        'cool': 800.0,
        'ambient': 600.0,
      },
    ),
  ];
  
  // Demo bookings for testing
  static final List<StorageBooking> _demoBookings = [
    StorageBooking(
      id: 'b1',
      userId: 'user1',
      facilityId: '1',
      compartmentId: '101',
      requestDate: DateTime.now().subtract(const Duration(days: 5)),
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      items: [
        BookingItem(
          id: 'bi1',
          productId: 'p1',
          productName: 'Organic Apples',
          category: 'Fruits',
          quantity: 300.0, // kg
          temperatureZone: TemperatureZone.cool,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          spaceRequired: 5.0, // cubic meters
        ),
      ],
      bookingType: StorageBookingType.monthly,
      status: BookingStatus.active,
      totalAmount: 800.0,
      isPaid: true,
      paymentId: 'pay_123456',
      notes: 'Organic produce that needs to be kept away from chemical products',
    ),
    StorageBooking(
      id: 'b2',
      userId: 'user2',
      facilityId: '2',
      compartmentId: '201',
      requestDate: DateTime.now().subtract(const Duration(days: 10)),
      startDate: DateTime.now().subtract(const Duration(days: 8)),
      endDate: DateTime.now().add(const Duration(days: 22)),
      items: [
        BookingItem(
          id: 'bi2',
          productId: 'p2',
          productName: 'Frozen Fish',
          category: 'Seafood',
          quantity: 500.0, // kg
          temperatureZone: TemperatureZone.frozen,
          expiryDate: DateTime.now().add(const Duration(days: 90)),
          spaceRequired: 8.0, // cubic meters
        ),
      ],
      bookingType: StorageBookingType.monthly,
      status: BookingStatus.active,
      totalAmount: 1500.0,
      isPaid: true,
      paymentId: 'pay_234567',
    ),
    StorageBooking(
      id: 'b3',
      userId: 'user3',
      facilityId: '3',
      compartmentId: '302',
      requestDate: DateTime.now().subtract(const Duration(days: 2)),
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 31)),
      items: [
        BookingItem(
          id: 'bi3',
          productId: 'p3',
          productName: 'Fresh Milk',
          category: 'Dairy',
          quantity: 200.0, // kg
          temperatureZone: TemperatureZone.chilled,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          spaceRequired: 3.0, // cubic meters
        ),
      ],
      bookingType: StorageBookingType.monthly,
      status: BookingStatus.confirmed,
      totalAmount: 950.0,
      isPaid: false,
    ),
    StorageBooking(
      id: 'b4',
      userId: 'user1',
      facilityId: '1',
      requestDate: DateTime.now().subtract(const Duration(hours: 12)),
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 10)),
      items: [
        BookingItem(
          id: 'bi4',
          productId: 'p4',
          productName: 'Organic Strawberries',
          category: 'Fruits',
          quantity: 100.0, // kg
          temperatureZone: TemperatureZone.chilled,
          expiryDate: DateTime.now().add(const Duration(days: 14)),
          spaceRequired: 2.0, // cubic meters
        ),
      ],
      bookingType: StorageBookingType.weekly,
      status: BookingStatus.pending,
      totalAmount: 245.0,
      isPaid: false,
    ),
  ];
  
  // Get all facilities
  Future<List<StorageFacility>> getAllFacilities() async {
    // In a real app, fetch from API or local DB
    return Future.delayed(Duration(milliseconds: 500), () => _demoFacilities);
  }
  
  // Fetch facilities with optional filter
  Future<List<StorageFacility>> fetchFacilities({
    bool Function(StorageFacility)? filter
  }) async {
    // In a real app, you would apply the filter in the database query
    // For demo, we'll filter the in-memory list
    final allFacilities = await getAllFacilities();
    
    if (filter == null) {
      return allFacilities;
    }
    
    return allFacilities.where(filter).toList();
  }
  
  // Get a facility by ID
  Future<StorageFacility?> getFacilityById(String id) async {
    if (AppConstants.isDemoMode) {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      
      try {
        return _demoFacilities.firstWhere((f) => f.id == id);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/facilities/$id'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        return StorageFacility.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to load storage facility: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching storage facility: $e');
    }
  }
  
  // Get storage facilities by temperature zone
  Future<List<StorageFacility>> getFacilitiesByZone(TemperatureZone zone) async {
    final facilities = await getAllFacilities();
    
    return facilities.where((facility) {
      return facility.compartments.any((comp) => 
        comp.temperatureZone == zone && comp.isAvailable
      );
    }).toList();
  }
  
  // Get nearby storage facilities
  Future<List<StorageFacility>> getNearbyFacilities(double lat, double lng, double radiusKm) async {
    final facilities = await getAllFacilities();
    
    return facilities.where((facility) {
      final distance = _calculateDistance(
        lat, lng, 
        facility.address.latitude, facility.address.longitude
      );
      return distance <= radiusKm;
    }).toList();
  }
  
  // Get all bookings for a user
  Future<List<StorageBooking>> getUserBookings(String userId) async {
    if (AppConstants.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 700)); // Simulate network delay
      return _demoBookings.where((b) => b.userId == userId).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookings/user/$userId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> bookingsJson = json.decode(response.body);
        return bookingsJson
            .map((json) => StorageBooking.fromMap(json))
            .toList();
      } else {
        throw Exception('Failed to load user bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user bookings: $e');
    }
  }
  
  // Get all bookings for a facility
  Future<List<StorageBooking>> getFacilityBookings(String facilityId) async {
    if (AppConstants.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 700)); // Simulate network delay
      return _demoBookings.where((b) => b.facilityId == facilityId).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookings/facility/$facilityId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> bookingsJson = json.decode(response.body);
        return bookingsJson
            .map((json) => StorageBooking.fromMap(json))
            .toList();
      } else {
        throw Exception('Failed to load facility bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility bookings: $e');
    }
  }
  
  // Create a new storage booking
  Future<StorageBooking> createBooking(StorageBooking booking) async {
    if (AppConstants.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network delay
      // In demo mode, just return the booking with an ID
      final newBooking = booking.copyWith(
        id: 'b${_demoBookings.length + 1}',
        status: BookingStatus.pending,
      );
      _demoBookings.add(newBooking);
      return newBooking;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bookings'),
        headers: await _getHeaders(),
        body: json.encode(booking.toMap()),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 201) {
        return StorageBooking.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }
  
  // Update a booking status
  Future<StorageBooking> updateBookingStatus(String bookingId, BookingStatus status) async {
    if (AppConstants.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 700)); // Simulate network delay
      
      final index = _demoBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final updatedBooking = _demoBookings[index].copyWith(status: status);
        _demoBookings[index] = updatedBooking;
        return updatedBooking;
      } else {
        throw Exception('Booking not found');
      }
    }
    
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/bookings/$bookingId/status'),
        headers: await _getHeaders(),
        body: json.encode({'status': status.toString().split('.').last}),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        return StorageBooking.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to update booking status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }
  
  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    if (AppConstants.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 700)); // Simulate network delay
      
      final index = _demoBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final updatedBooking = _demoBookings[index].copyWith(
          status: BookingStatus.cancelled
        );
        _demoBookings[index] = updatedBooking;
        return true;
      } else {
        throw Exception('Booking not found');
      }
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bookings/$bookingId/cancel'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }
  
  // Get items stored in a facility
  Future<List<StoredItem>> getFacilityItems(String facilityId) async {
    if (AppConstants.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      List<StoredItem> items = [];
      // Get all active bookings for this facility
      final bookings = _demoBookings.where(
        (b) => b.facilityId == facilityId && 
              (b.status == BookingStatus.active || b.status == BookingStatus.confirmed)
      ).toList();
      
      // Create stored items from booking items
      for (final booking in bookings) {
        for (final item in booking.items) {
          items.add(StoredItem(
            id: 'si${items.length + 1}',
            productId: item.productId,
            ownerId: booking.userId,
            productName: item.productName,
            category: item.category,
            quantity: item.quantity,
            storedDate: booking.startDate,
            expiryDate: item.expiryDate,
            bookingType: booking.bookingType,
            status: booking.status,
            spaceOccupied: item.spaceRequired,
          ));
        }
      }
      
      return items;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/facilities/$facilityId/items'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = json.decode(response.body);
        return itemsJson
            .map((json) => StoredItem.fromMap(json))
            .toList();
      } else {
        throw Exception('Failed to load facility items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility items: $e');
    }
  }
  
  // Get items expiring soon (within next 7 days)
  Future<List<StoredItem>> getExpiringItems(String facilityId) async {
    final items = await getFacilityItems(facilityId);
    final now = DateTime.now();
    
    return items.where((item) {
      final daysUntilExpiry = item.expiryDate.difference(now).inDays;
      return daysUntilExpiry >= 0 && daysUntilExpiry <= 7;
    }).toList();
  }
  
  // Cache facilities to local storage
  Future<void> _cacheFacilities(List<StorageFacility> facilities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facilitiesJson = facilities.map((f) => json.encode(f.toMap())).toList();
      await prefs.setStringList(_facilitiesCacheKey, facilitiesJson);
      
      // Save cache timestamp
      await prefs.setInt('${_facilitiesCacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail on cache errors
      print('Failed to cache facilities: $e');
    }
  }
  
  // Get cached facilities
  Future<List<StorageFacility>> _getCachedFacilities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedList = prefs.getStringList(_facilitiesCacheKey);
      final cacheTimestamp = prefs.getInt('${_facilitiesCacheKey}_timestamp') ?? 0;
      
      // Check if cache is expired
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
      if (cacheAge > _cacheDuration.inMilliseconds) {
        return [];
      }
      
      if (cachedList != null && cachedList.isNotEmpty) {
        return cachedList
            .map((item) => StorageFacility.fromMap(json.decode(item)))
            .toList();
      }
      
      return [];
    } catch (e) {
      // Return empty list on cache errors
      return [];
    }
  }
  
  // Get API request headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey) ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Calculate distance between two coordinates in km (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
              sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
} 