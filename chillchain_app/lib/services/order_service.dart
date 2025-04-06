import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../utils/temperature_utils.dart';

class OrderService {
  static const String _baseUrl = '${AppConstants.apiBaseUrl}/orders';
  static const Duration _cacheDuration = Duration(minutes: 30);
  
  // Demo orders for testing
  final List<Order> _demoOrders = [
    Order(
      id: '1',
      userId: 'user1',
      vendorId: 'vendor1',
      deliveryPartnerId: 'delivery1',
      items: [
        OrderItem(
          productId: 'product1',
          quantity: 2,
          price: 15.99,
          temperatureRequirement: TemperatureRequirement(
            minTemperature: -20.0,
            maxTemperature: -18.0,
            zone: TemperatureZone.frozen,
          ),
        ),
      ],
      subtotal: 31.98,
      deliveryFee: 5.99,
      tax: 3.79,
      total: 41.76,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      estimatedDeliveryTime: DateTime.now().add(const Duration(hours: 2)),
      deliveryAddress: '123 Main St, Anytown, USA',
      status: OrderStatus.inTransit,
      temperatureLogs: [],
      customerName: 'John Doe',
    ),
    Order(
      id: 'ORD-002',
      userId: 'user1',
      vendorId: 'vendor2',
      deliveryPartnerId: 'driver2',
      items: [
        OrderItem(
          productId: '3',
          quantity: 2,
          price: 5.99,
          temperatureRequirement: TemperatureRequirement(
            minTemperature: -25.0,
            maxTemperature: -18.0,
            zone: TemperatureZone.frozen,
          ),
        ),
      ],
      subtotal: 11.98,
      deliveryFee: 3.99,
      tax: 0.80,
      total: 16.77,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      actualDeliveryTime: DateTime.now().subtract(const Duration(hours: 20)),
      deliveryAddress: '456 Elm St, Anytown, CA 12345',
      status: OrderStatus.delivered,
      temperatureLogs: _generateDemoTemperatureLogs(
        TemperatureRequirement(
          minTemperature: -25.0,
          maxTemperature: -18.0,
          zone: TemperatureZone.frozen,
        ),
        20,
        true,
      ),
      paymentId: 'PAY-7654321',
      customerName: 'Jane Smith',
    ),
    Order(
      id: 'ORD-003',
      userId: 'user1',
      vendorId: 'vendor3',
      items: [
        OrderItem(
          productId: '5',
          quantity: 3,
          price: 2.49,
          temperatureRequirement: TemperatureRequirement(
            minTemperature: 4.0,
            maxTemperature: 10.0,
            zone: TemperatureZone.cool,
          ),
        ),
        OrderItem(
          productId: '7',
          quantity: 2,
          price: 1.99,
          temperatureRequirement: TemperatureRequirement(
            minTemperature: 0.0,
            maxTemperature: 4.0,
            zone: TemperatureZone.chilled,
          ),
        ),
      ],
      subtotal: 11.45,
      deliveryFee: 2.99,
      tax: 0.72,
      total: 15.16,
      orderDate: DateTime.now().subtract(const Duration(minutes: 15)),
      deliveryAddress: '789 Oak St, Anytown, CA 12345',
      status: OrderStatus.confirmed,
      temperatureLogs: [],
      paymentId: 'PAY-8901234',
      customerName: 'Robert Johnson',
    ),
    Order(
      id: 'ORD-004',
      userId: 'user1',
      vendorId: 'vendor1',
      items: [
        OrderItem(
          productId: '8',
          quantity: 1,
          price: 4.99,
          temperatureRequirement: TemperatureRequirement(
            minTemperature: -23.0,
            maxTemperature: -18.0,
            zone: TemperatureZone.frozen,
          ),
        ),
        OrderItem(
          productId: '6',
          quantity: 2,
          price: 7.99,
          temperatureRequirement: TemperatureRequirement(
            minTemperature: -22.0,
            maxTemperature: -18.0,
            zone: TemperatureZone.frozen,
          ),
        ),
      ],
      subtotal: 20.97,
      deliveryFee: 3.99,
      tax: 1.25,
      total: 26.21,
      orderDate: DateTime.now(),
      deliveryAddress: '123 Main St, Anytown, CA 12345',
      status: OrderStatus.pending,
      temperatureLogs: [],
      customerName: 'Michael Brown',
    ),
  ];
  
  // Helper to generate demo temperature logs
  static List<TemperatureLog> _generateDemoTemperatureLogs(
    TemperatureRequirement requirement,
    int count,
    bool maintainRange,
  ) {
    final logs = <TemperatureLog>[];
    final now = DateTime.now();
    
    // Generate logs with a small chance of temperature breach
    final random = Random();
    
    for (int i = 0; i < count; i++) {
      final timestamp = now.subtract(Duration(minutes: (count - i) * 5));
      
      // Determine if this log should have a temperature breach (for demo purposes)
      bool shouldBreach = random.nextInt(100) < 10 && !maintainRange; // 10% chance of breach if !maintainRange
      
      // Generate a simulated temperature
      double temperature;
      if (shouldBreach) {
        // Temperature breach - either too high or too low
        bool tooHigh = random.nextBool();
        temperature = tooHigh 
          ? requirement.maxTemperature + random.nextDouble() * 3
          : requirement.minTemperature - random.nextDouble() * 3;
      } else {
        // Temperature within normal range
        temperature = requirement.minTemperature + 
                     (requirement.maxTemperature - requirement.minTemperature) * random.nextDouble();
      }
      
      logs.add(
        TemperatureLog(
          timestamp: timestamp,
          temperature: temperature,
          sensorId: 'sensor-${random.nextInt(3) + 1}',
          isWithinRange: TemperatureUtils.isTemperatureInRange(temperature, requirement),
        ),
      );
    }
    
    return logs;
  }
  
  // Get user's orders
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return demo orders for MVP
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        return _demoOrders;
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load user orders: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Get order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return a demo order for MVP
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        final order = _demoOrders.firstWhere(
          (o) => o.id == orderId,
          orElse: () => throw Exception('Order not found'),
        );
        
        // If the order is in transit, update the temperature logs to simulate real-time monitoring
        if (order.status == OrderStatus.inTransit) {
          final updatedLogs = List<TemperatureLog>.from(order.temperatureLogs);
          
          // Get the last temperature requirement from the items
          final requirements = order.items.map((item) => item.temperatureRequirement).toList();
          final mostCriticalRequirement = requirements.reduce((a, b) => 
            a.minTemperature < b.minTemperature ? a : b);
          
          // Add a new temperature log
          updatedLogs.add(
            TemperatureLog(
              timestamp: DateTime.now(),
              temperature: TemperatureUtils.getSimulatedTemperature(
                mostCriticalRequirement,
                maintainRange: true, // Usually maintain range, except in demo cases
              ),
              sensorId: 'sensor-${Random().nextInt(3) + 1}',
              isWithinRange: true,
            ),
          );
          
          // Update the order with the new temperature logs
          final updatedOrder = order.copyWith(
            temperatureLogs: updatedLogs,
          );
          
          return updatedOrder;
        }
        
        return order;
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$orderId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromMap(data);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      if (AppConstants.isDemoMode) {
        // Create a demo order for MVP
        await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network delay
        
        // Generate a new order ID
        final newOrderId = 'ORD-${(100 + _demoOrders.length).toString().padLeft(3, '0')}';
        
        // Create a new order with the generated ID
        final newOrder = order.copyWith(
          id: newOrderId,
          orderDate: DateTime.now(),
          status: OrderStatus.pending,
          temperatureLogs: [],
          customerName: order.customerName,
        );
        
        // Add the new order to the demo orders
        _demoOrders.add(newOrder);
        
        return newOrder;
      }
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: await _getHeaders(),
        body: json.encode(order.toMap()),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Order.fromMap(data);
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Update an order's status
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      if (AppConstants.isDemoMode) {
        // Update a demo order for MVP
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        
        // Find the order to update
        final orderIndex = _demoOrders.indexWhere((o) => o.id == orderId);
        if (orderIndex == -1) {
          throw Exception('Order not found');
        }
        
        // Get the current order
        final currentOrder = _demoOrders[orderIndex];
        
        // Create updated order with new status
        final updatedOrder = currentOrder.copyWith(
          status: status,
          actualDeliveryTime: status == OrderStatus.delivered ? DateTime.now() : null,
        );
        
        // Update the order in the demo orders list
        _demoOrders[orderIndex] = updatedOrder;
        
        return updatedOrder;
      }
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/$orderId/status'),
        headers: await _getHeaders(),
        body: json.encode({
          'status': status.toString().split('.').last,
        }),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromMap(data);
      } else {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Add a temperature log to an order
  Future<Order> addTemperatureLog(String orderId, TemperatureLog log) async {
    try {
      if (AppConstants.isDemoMode) {
        // Add a temperature log to a demo order for MVP
        await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
        
        // Find the order to update
        final orderIndex = _demoOrders.indexWhere((o) => o.id == orderId);
        if (orderIndex == -1) {
          throw Exception('Order not found');
        }
        
        // Get the current order
        final currentOrder = _demoOrders[orderIndex];
        
        // Create updated order with new temperature log
        final updatedLogs = List<TemperatureLog>.from(currentOrder.temperatureLogs)..add(log);
        final updatedOrder = currentOrder.copyWith(
          temperatureLogs: updatedLogs,
        );
        
        // Update the order in the demo orders list
        _demoOrders[orderIndex] = updatedOrder;
        
        return updatedOrder;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/$orderId/temperature-logs'),
        headers: await _getHeaders(),
        body: json.encode(log.toMap()),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromMap(data);
      } else {
        throw Exception('Failed to add temperature log: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
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
  
  // Get orders awaiting delivery by a delivery partner
  Future<List<Order>> getOrdersForDeliveryPartner(String deliveryPartnerId) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return filtered demo orders for MVP
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        return _demoOrders
            .where((o) => o.deliveryPartnerId == deliveryPartnerId && 
                         (o.status == OrderStatus.confirmed || o.status == OrderStatus.inTransit))
            .toList();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery-partner/$deliveryPartnerId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load delivery partner orders: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Get vendor's orders
  Future<List<Order>> getVendorOrders(String vendorId) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return filtered demo orders for MVP
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        return _demoOrders.where((o) => o.vendorId == vendorId).toList();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/vendor/$vendorId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load vendor orders: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
} 