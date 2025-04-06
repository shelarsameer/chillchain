import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/storage.dart';
import '../models/storage_booking.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

/// Provider for managing cold storage facilities and bookings
class StorageProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  // Storage facilities
  List<StorageFacility> _facilities = [];
  StorageFacility? _selectedFacility;
  
  // Bookings
  List<StorageBooking> _userBookings = [];
  List<StorageBooking> _facilityBookings = [];
  StorageBooking? _selectedBooking;
  
  // Stored items
  List<StoredItem> _storedItems = [];
  List<StoredItem> _expiringItems = [];
  
  // Filters
  TemperatureZone? _selectedZone;
  double _maxDistanceKm = 50.0;
  
  // Search terms
  String _searchTerm = '';
  
  // Loading and error states
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<StorageFacility> get facilities => _facilities;
  StorageFacility? get selectedFacility => _selectedFacility;
  List<StorageBooking> get userBookings => _userBookings;
  List<StorageBooking> get facilityBookings => _facilityBookings;
  StorageBooking? get selectedBooking => _selectedBooking;
  List<StoredItem> get storedItems => _storedItems;
  List<StoredItem> get expiringItems => _expiringItems;
  TemperatureZone? get selectedZone => _selectedZone;
  double get maxDistanceKm => _maxDistanceKm;
  String get searchTerm => _searchTerm;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get filtered facilities
  List<StorageFacility> get filteredFacilities {
    if (_searchTerm.isEmpty && _selectedZone == null) {
      return _facilities;
    }
    
    final searchLower = _searchTerm.toLowerCase();
    
    return _facilities.where((facility) {
      // Apply search filter
      final matchesSearch = _searchTerm.isEmpty || 
        facility.name.toLowerCase().contains(searchLower) ||
        facility.description.toLowerCase().contains(searchLower);
      
      // Apply zone filter
      final matchesZone = _selectedZone == null || 
        facility.compartments.any((comp) => 
          comp.temperatureZone == _selectedZone && comp.isAvailable
        );
      
      return matchesSearch && matchesZone;
    }).toList();
  }
  
  // Get active bookings
  List<StorageBooking> get activeBookings => 
    _userBookings.where((booking) => 
      booking.status == BookingStatus.active || 
      booking.status == BookingStatus.confirmed
    ).toList();
  
  // Get pending bookings
  List<StorageBooking> get pendingBookings => 
    _userBookings.where((booking) => 
      booking.status == BookingStatus.pending
    ).toList();
  
  // Get history of completed or cancelled bookings
  List<StorageBooking> get bookingHistory => 
    _userBookings.where((booking) => 
      booking.status == BookingStatus.completed || 
      booking.status == BookingStatus.cancelled ||
      booking.status == BookingStatus.expired
    ).toList();
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error state
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  // Clear error state
  void _clearError() {
    _error = null;
  }
  
  // Initialize with user ID
  Future<void> initialize(String userId) async {
    await fetchAllFacilities();
    await fetchUserBookings(userId);
  }
  
  // Fetch all storage facilities
  Future<void> fetchAllFacilities() async {
    _setLoading(true);
    _clearError();
    
    try {
      _facilities = await _storageService.getAllFacilities();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load storage facilities: $e');
      _setLoading(false);
    }
  }
  
  // Fetch facilities by temperature zone
  Future<void> fetchFacilitiesByZone(TemperatureZone zone) async {
    _setLoading(true);
    _clearError();
    _selectedZone = zone;
    
    try {
      _facilities = await _storageService.getFacilitiesByZone(zone);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load facilities by zone: $e');
      _setLoading(false);
    }
  }
  
  // Fetch nearby facilities
  Future<void> fetchNearbyFacilities(double latitude, double longitude) async {
    _setLoading(true);
    _clearError();
    
    try {
      _facilities = await _storageService.getNearbyFacilities(
        latitude, 
        longitude, 
        _maxDistanceKm
      );
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load nearby facilities: $e');
      _setLoading(false);
    }
  }
  
  // Set selected facility
  Future<void> selectFacility(String facilityId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final facility = await _storageService.getFacilityById(facilityId);
      _selectedFacility = facility;
      
      // Also fetch bookings and items for this facility
      await fetchFacilityBookings(facilityId);
      await fetchFacilityItems(facilityId);
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load facility details: $e');
      _setLoading(false);
    }
  }
  
  // Fetch bookings for a user
  Future<void> fetchUserBookings(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _userBookings = await _storageService.getUserBookings(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load your bookings: $e');
      _setLoading(false);
    }
  }
  
  // Fetch bookings for a facility
  Future<void> fetchFacilityBookings(String facilityId) async {
    try {
      _facilityBookings = await _storageService.getFacilityBookings(facilityId);
      notifyListeners();
    } catch (e) {
      print('Error fetching facility bookings: $e');
    }
  }
  
  // Fetch stored items in a facility
  Future<void> fetchFacilityItems(String facilityId) async {
    try {
      _storedItems = await _storageService.getFacilityItems(facilityId);
      _expiringItems = await _storageService.getExpiringItems(facilityId);
      notifyListeners();
    } catch (e) {
      print('Error fetching stored items: $e');
    }
  }
  
  // Create a new booking
  Future<StorageBooking?> createBooking(StorageBooking booking) async {
    _setLoading(true);
    _clearError();
    
    try {
      final newBooking = await _storageService.createBooking(booking);
      _userBookings.add(newBooking);
      _setLoading(false);
      notifyListeners();
      return newBooking;
    } catch (e) {
      _setError('Failed to create booking: $e');
      _setLoading(false);
      return null;
    }
  }
  
  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _storageService.cancelBooking(bookingId);
      
      if (success) {
        // Update the local booking status
        final index = _userBookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _userBookings[index] = _userBookings[index].copyWith(
            status: BookingStatus.cancelled
          );
        }
      }
      
      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('Failed to cancel booking: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Set search term
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }
  
  // Set max distance for nearby search
  void setMaxDistance(double distanceKm) {
    _maxDistanceKm = distanceKm;
    notifyListeners();
  }
  
  // Reset filters
  void resetFilters() {
    _selectedZone = null;
    _searchTerm = '';
    _maxDistanceKm = 50.0;
    notifyListeners();
  }
  
  // Select a booking to view details
  void selectBooking(String bookingId) {
    _selectedBooking = _userBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => _facilityBookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => throw Exception('Booking not found'),
      ),
    );
    notifyListeners();
  }
  
  // Clear selected booking
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }
  
  // Estimate booking cost based on temperature zone, space, booking type and duration
  double estimateBookingCost(
    TemperatureZone zone, 
    double spaceInCubicMeters, 
    StorageBookingType bookingType,
    int durationDays,
  ) {
    // Base rates per cubic meter per day (in USD)
    final Map<TemperatureZone, double> baseDailyRates = {
      TemperatureZone.ambient: 0.50,     // Ambient temperature storage
      TemperatureZone.cool: 0.85,        // Cool temperature storage
      TemperatureZone.chilled: 1.25,     // Chilled temperature storage
      TemperatureZone.frozen: 2.00,      // Frozen temperature storage
    };
    
    // Get base daily rate for the selected zone
    final dailyRate = baseDailyRates[zone] ?? 1.25; // Default to chilled rate
    
    // Apply discount based on booking type
    double finalRate = dailyRate;
    switch (bookingType) {
      case StorageBookingType.hourly:
        // Hourly is more expensive per day equivalent
        finalRate = dailyRate * 1.5;
        break;
      case StorageBookingType.daily:
        // No adjustment for daily rate
        break;
      case StorageBookingType.weekly:
        // 10% discount for weekly bookings
        finalRate = dailyRate * 0.9;
        break;
      case StorageBookingType.monthly:
        // 25% discount for monthly bookings
        finalRate = dailyRate * 0.75;
        break;
      case StorageBookingType.custom:
        // Custom rate uses daily rate as base
        break;
    }
    
    // Volume discount for larger spaces
    if (spaceInCubicMeters > 10) {
      finalRate *= 0.9; // 10% discount for space > 10 cubic meters
    } else if (spaceInCubicMeters > 5) {
      finalRate *= 0.95; // 5% discount for space > 5 cubic meters
    }
    
    // Calculate total cost
    double totalCost = finalRate * spaceInCubicMeters * durationDays;
    
    // Minimum charge
    if (totalCost < 10) {
      totalCost = 10; // Minimum charge of $10
    }
    
    return totalCost;
  }
  
  // Fetch a specific facility by ID
  Future<void> fetchFacilityById(String id) async {
    try {
      if (_isLoading) return;
      _isLoading = true;
      _error = null;
      notifyListeners();

      final facility = await _storageService.getFacilityById(id);
      if (facility != null) {
        _selectedFacility = facility;
      } else {
        _error = 'Facility not found';
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Fetch facilities owned by a vendor
  Future<void> fetchVendorFacilities(String vendorId) async {
    _setLoading(true);
    try {
      // In a real app, you would make an API call here
      // For demo, we'll filter the demo facilities
      _facilities = await _storageService.fetchFacilities(
        filter: (facility) => facility.ownerId == vendorId
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch vendor facilities: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
} 