import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/compartment.dart';
import '../constants/app_constants.dart';

class CompartmentService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final bool isDemoMode = AppConstants.isDemoMode;

  // Get all compartments
  Future<List<Compartment>> getCompartments() async {
    if (isDemoMode) {
      // Return demo data
      return _getDemoCompartments();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/compartments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Compartment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load compartments');
      }
    } catch (e) {
      throw Exception('Error fetching compartments: $e');
    }
  }
  
  // Generate demo compartments for testing
  List<Compartment> _getDemoCompartments() {
    return [
      Compartment(
        id: '1',
        facilityId: 'facility1',
        name: 'Freezer Compartment A1',
        description: 'Large deep freeze compartment for long-term storage',
        capacity: 50.0,
        temperatureZone: TemperatureZone.frozen,
        minTemperature: -25.0,
        maxTemperature: -18.0,
        currentTemperature: -20.5,
        status: CompartmentStatus.available,
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 30)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 90)),
      ),
      Compartment(
        id: '2',
        facilityId: 'facility1',
        name: 'Chiller Compartment B2',
        description: 'Medium chiller for dairy and produce',
        capacity: 30.0,
        temperatureZone: TemperatureZone.chilled,
        minTemperature: 2.0,
        maxTemperature: 6.0,
        currentTemperature: 4.2,
        status: CompartmentStatus.occupied,
        currentOrderId: 'order123',
        currentCustomerId: 'customer456',
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 15)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 75)),
        productIds: ['product1', 'product2', 'product3'],
      ),
      Compartment(
        id: '3',
        facilityId: 'facility1',
        name: 'Cool Storage C3',
        description: 'Cool storage area for fruits and vegetables',
        capacity: 40.0,
        temperatureZone: TemperatureZone.cool,
        minTemperature: 8.0,
        maxTemperature: 12.0,
        currentTemperature: 10.1,
        status: CompartmentStatus.maintenance,
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 2)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 120)),
      ),
      Compartment(
        id: '4',
        facilityId: 'facility1',
        name: 'Ambient Storage D4',
        description: 'Room temperature storage for non-perishables',
        capacity: 60.0,
        temperatureZone: TemperatureZone.ambient,
        minTemperature: 18.0,
        maxTemperature: 24.0,
        currentTemperature: 21.3,
        status: CompartmentStatus.reserved,
        currentOrderId: 'order789',
        currentCustomerId: 'customer012',
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 45)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 45)),
      ),
      Compartment(
        id: '5',
        facilityId: 'facility1',
        name: 'Freezer Compartment A2',
        description: 'Small deep freeze compartment for special items',
        capacity: 25.0,
        temperatureZone: TemperatureZone.frozen,
        minTemperature: -25.0,
        maxTemperature: -18.0,
        currentTemperature: -22.0,
        status: CompartmentStatus.available,
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 20)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 100)),
      ),
    ];
  }

  // Get compartment by ID
  Future<Compartment> getCompartmentById(String id) async {
    if (isDemoMode) {
      // Return demo data
      final compartments = _getDemoCompartments();
      final compartment = compartments.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Compartment not found'),
      );
      return compartment;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/compartments/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Compartment.fromJson(data);
      } else {
        throw Exception('Failed to load compartment');
      }
    } catch (e) {
      throw Exception('Error fetching compartment: $e');
    }
  }

  // Add new compartment
  Future<Compartment> addCompartment(Compartment compartment) async {
    if (isDemoMode) {
      // In demo mode, just return the same compartment with perhaps a generated ID
      return compartment.copyWith(
        id: compartment.id.isNotEmpty ? compartment.id : DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compartments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(compartment.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Compartment.fromJson(data);
      } else {
        throw Exception('Failed to add compartment');
      }
    } catch (e) {
      throw Exception('Error adding compartment: $e');
    }
  }

  // Update compartment
  Future<Compartment> updateCompartment(Compartment compartment) async {
    if (isDemoMode) {
      // In demo mode, just return the updated compartment
      return compartment;
    }
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/compartments/${compartment.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(compartment.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Compartment.fromJson(data);
      } else {
        throw Exception('Failed to update compartment');
      }
    } catch (e) {
      throw Exception('Error updating compartment: $e');
    }
  }

  // Delete compartment
  Future<void> deleteCompartment(String id) async {
    if (isDemoMode) {
      // In demo mode, do nothing but return successfully
      return;
    }
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/compartments/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete compartment');
      }
    } catch (e) {
      throw Exception('Error deleting compartment: $e');
    }
  }

  // Get compartments by temperature zone
  Future<List<Compartment>> getCompartmentsByZone(TemperatureZone zone) async {
    if (isDemoMode) {
      // Return filtered demo data
      final compartments = _getDemoCompartments();
      return compartments.where((c) => c.temperatureZone == zone).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/compartments?zone=${zone.toString()}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Compartment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load compartments by zone');
      }
    } catch (e) {
      throw Exception('Error fetching compartments by zone: $e');
    }
  }

  // Get compartments by status
  Future<List<Compartment>> getCompartmentsByStatus(CompartmentStatus status) async {
    if (isDemoMode) {
      // Return filtered demo data
      final compartments = _getDemoCompartments();
      return compartments.where((c) => c.status == status).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/compartments?status=${status.toString()}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Compartment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load compartments by status');
      }
    } catch (e) {
      throw Exception('Error fetching compartments by status: $e');
    }
  }

  // Get compartments by customer
  Future<List<Compartment>> getCompartmentsByCustomer(String customerId) async {
    if (isDemoMode) {
      // Return filtered demo data
      final compartments = _getDemoCompartments();
      return compartments.where((c) => c.currentCustomerId == customerId).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/compartments?customerId=$customerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Compartment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load compartments by customer');
      }
    } catch (e) {
      throw Exception('Error fetching compartments by customer: $e');
    }
  }

  // Get compartments by order
  Future<List<Compartment>> getCompartmentsByOrder(String orderId) async {
    if (isDemoMode) {
      // Return filtered demo data
      final compartments = _getDemoCompartments();
      return compartments.where((c) => c.currentOrderId == orderId).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/compartments?orderId=$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Compartment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load compartments by order');
      }
    } catch (e) {
      throw Exception('Error fetching compartments by order: $e');
    }
  }
} 