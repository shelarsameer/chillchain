import 'package:flutter/foundation.dart';
import '../models/compartment.dart';
import '../services/compartment_service.dart';

class CompartmentProvider with ChangeNotifier {
  final CompartmentService _compartmentService;
  List<Compartment> _compartments = [];
  bool _isLoading = false;
  String? _error;

  CompartmentProvider(this._compartmentService);

  List<Compartment> get compartments => _compartments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get compartments by status
  List<Compartment> getAvailableCompartments() {
    return _compartments.where((c) => c.status == CompartmentStatus.available).toList();
  }

  List<Compartment> getOccupiedCompartments() {
    return _compartments.where((c) => c.status == CompartmentStatus.occupied).toList();
  }

  List<Compartment> getMaintenanceCompartments() {
    return _compartments.where((c) => c.status == CompartmentStatus.maintenance).toList();
  }

  // Get compartments by temperature zone
  List<Compartment> getCompartmentsByZone(TemperatureZone zone) {
    return _compartments.where((c) => c.temperatureZone == zone).toList();
  }

  // Get compartment by ID
  Compartment? getCompartmentById(String id) {
    return _compartments.firstWhere((c) => c.id == id);
  }

  // Load all compartments
  Future<void> loadCompartments() async {
    _setLoading(true);
    _clearError();

    try {
      _compartments = await _compartmentService.getCompartments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add new compartment
  Future<bool> addCompartment(Compartment compartment) async {
    _setLoading(true);
    _clearError();

    try {
      final newCompartment = await _compartmentService.addCompartment(compartment);
      _compartments.add(newCompartment);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update compartment
  Future<bool> updateCompartment(Compartment compartment) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedCompartment = await _compartmentService.updateCompartment(compartment);
      final index = _compartments.indexWhere((c) => c.id == compartment.id);
      if (index != -1) {
        _compartments[index] = updatedCompartment;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete compartment
  Future<bool> deleteCompartment(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _compartmentService.deleteCompartment(id);
      _compartments.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update compartment status
  Future<bool> updateCompartmentStatus(String id, CompartmentStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      final compartment = getCompartmentById(id);
      if (compartment == null) return false;

      final updatedCompartment = await _compartmentService.updateCompartment(
        compartment.copyWith(status: status),
      );
      
      final index = _compartments.indexWhere((c) => c.id == id);
      if (index != -1) {
        _compartments[index] = updatedCompartment;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update compartment temperature
  Future<bool> updateCompartmentTemperature(String id, double temperature) async {
    _setLoading(true);
    _clearError();

    try {
      final compartment = getCompartmentById(id);
      if (compartment == null) return false;

      final updatedCompartment = await _compartmentService.updateCompartment(
        compartment.copyWith(currentTemperature: temperature),
      );
      
      final index = _compartments.indexWhere((c) => c.id == id);
      if (index != -1) {
        _compartments[index] = updatedCompartment;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Assign compartment to order
  Future<bool> assignCompartmentToOrder(String compartmentId, String orderId, String customerId) async {
    _setLoading(true);
    _clearError();

    try {
      final compartment = getCompartmentById(compartmentId);
      if (compartment == null || compartment.status != CompartmentStatus.available) return false;

      final updatedCompartment = await _compartmentService.updateCompartment(
        compartment.copyWith(
          status: CompartmentStatus.occupied,
          currentOrderId: orderId,
          currentCustomerId: customerId,
        ),
      );
      
      final index = _compartments.indexWhere((c) => c.id == compartmentId);
      if (index != -1) {
        _compartments[index] = updatedCompartment;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Release compartment from order
  Future<bool> releaseCompartmentFromOrder(String compartmentId) async {
    _setLoading(true);
    _clearError();

    try {
      final compartment = getCompartmentById(compartmentId);
      if (compartment == null || compartment.status != CompartmentStatus.occupied) return false;

      final updatedCompartment = await _compartmentService.updateCompartment(
        compartment.copyWith(
          status: CompartmentStatus.available,
          currentOrderId: null,
          currentCustomerId: null,
        ),
      );
      
      final index = _compartments.indexWhere((c) => c.id == compartmentId);
      if (index != -1) {
        _compartments[index] = updatedCompartment;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 