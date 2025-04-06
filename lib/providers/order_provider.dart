import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/order_service.dart';
import '../utils/temperature_utils.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  // Orders
  List<Order> _orders = [];
  Order? _currentOrder;
  
  // Cart items
  List<OrderItem> _cartItems = [];
  
  // Tracking for temperature alerts
  Map<String, bool> _temperatureAlerts = {};
  
  // Timer for auto-refreshing orders in transit
  Timer? _refreshTimer;
  
  // Loading and error states
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  Map<String, bool> get temperatureAlerts => _temperatureAlerts;
  List<OrderItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get cart item count
  int get cartItemCount => _cartItems.length;
  
  // Get cart subtotal
  double get cartSubtotal {
    if (_cartItems.isEmpty) return 0.0;
    return _cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
  
  // Add item to cart
  void addToCart(Product product, int quantity) {
    // Check if item already exists in cart
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      // Update existing item quantity
      final existingItem = _cartItems[existingIndex];
      final updatedItem = OrderItem(
        productId: existingItem.productId,
        quantity: existingItem.quantity + quantity,
        price: existingItem.price,
        temperatureRequirement: existingItem.temperatureRequirement,
      );
      _cartItems[existingIndex] = updatedItem;
    } else {
      // Add new item to cart
      _cartItems.add(OrderItem(
        productId: product.id,
        quantity: quantity,
        price: product.price,
        temperatureRequirement: product.temperatureRequirement,
      ));
    }
    
    notifyListeners();
  }
  
  // Remove item from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }
  
  // Update cart item quantity
  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        final item = _cartItems[index];
        _cartItems[index] = OrderItem(
          productId: item.productId,
          quantity: quantity,
          price: item.price,
          temperatureRequirement: item.temperatureRequirement,
        );
      }
      
      notifyListeners();
    }
  }
  
  // Clear the cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  // Get pending and in transit orders
  List<Order> get activeOrders => _orders.where(
    (order) => order.status == OrderStatus.pending || 
               order.status == OrderStatus.confirmed || 
               order.status == OrderStatus.inTransit
  ).toList();
  
  // Get delivered orders
  List<Order> get deliveredOrders => _orders.where(
    (order) => order.status == OrderStatus.delivered
  ).toList();
  
  // Getter for vendor orders
  List<Order> get vendorOrders => _orders.where((order) => order.vendorId != null).toList();
  
  // Initialize orders
  Future<void> initialize(String userId) async {
    await fetchUserOrders(userId);
    _startRefreshTimer();
  }
  
  // Start timer to auto-refresh orders in transit
  void _startRefreshTimer() {
    // Cancel existing timer if any
    _refreshTimer?.cancel();
    
    // Start a new timer
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      _refreshActiveOrders();
    });
  }
  
  // Refresh orders that are in transit
  Future<void> _refreshActiveOrders() async {
    final ordersToRefresh = _orders.where(
      (order) => order.status == OrderStatus.inTransit
    ).toList();
    
    for (final order in ordersToRefresh) {
      await getOrderById(order.id);
    }
  }
  
  // Fetch user orders
  Future<void> fetchUserOrders(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final orders = await _orderService.getUserOrders(userId);
      _orders = orders;
      _updateTemperatureAlerts();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    // First check if it's already in our list
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    
    try {
      final order = await _orderService.getOrderById(orderId);
      
      // Update the order in the list if it exists
      if (orderIndex != -1) {
        _orders[orderIndex] = order;
      } else {
        _orders.add(order);
      }
      
      // Update the current order if it matches
      if (_currentOrder != null && _currentOrder!.id == orderId) {
        _currentOrder = order;
      }
      
      _updateTemperatureAlerts();
      notifyListeners();
      return order;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }
  
  // Set current order
  void setCurrentOrder(String orderId) {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    
    if (orderIndex != -1) {
      _currentOrder = _orders[orderIndex];
      notifyListeners();
    }
  }
  
  // Create a new order
  Future<Order?> createOrder({
    required String userId,
    required String vendorId,
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required double tax,
    required double total,
    required String deliveryAddress,
    String? notes,
    String? customerName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final order = Order(
        id: '', // Will be generated by the service
        userId: userId,
        vendorId: vendorId,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        tax: tax,
        total: total,
        orderDate: DateTime.now(),
        deliveryAddress: DeliveryAddress.fromString(deliveryAddress),
        status: OrderStatus.pending,
        temperatureLogs: [],
        notes: notes,
        customerName: customerName ?? 'Customer', // Default customer name
      );
      
      final createdOrder = await _orderService.createOrder(order);
      
      // Add the order to the list
      _orders.add(createdOrder);
      _currentOrder = createdOrder;
      
      _setLoading(false);
      notifyListeners();
      return createdOrder;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }
  
  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    
    if (orderIndex == -1) {
      _setError('Order not found');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, status);
      
      // Update the order in the list
      _orders[orderIndex] = updatedOrder;
      
      // Update current order if it matches
      if (_currentOrder != null && _currentOrder!.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Add temperature log
  Future<bool> addTemperatureLog(String orderId, TemperatureLog log) async {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    
    if (orderIndex == -1) {
      _setError('Order not found');
      return false;
    }
    
    try {
      final updatedOrder = await _orderService.addTemperatureLog(orderId, log);
      
      // Update the order in the list
      _orders[orderIndex] = updatedOrder;
      
      // Update current order if it matches
      if (_currentOrder != null && _currentOrder!.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      _updateTemperatureAlerts();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding temperature log: $e');
      return false;
    }
  }
  
  // Update temperature alerts
  void _updateTemperatureAlerts() {
    _temperatureAlerts.clear();
    
    for (final order in _orders) {
      if (order.status == OrderStatus.inTransit) {
        final logs = order.temperatureLogs;
        
        if (logs.isNotEmpty) {
          // Check if any recent logs show temperature breaches
          final recentLogs = logs.where((log) {
            final now = DateTime.now();
            final logTime = log.timestamp;
            return now.difference(logTime).inMinutes <= 30; // Only check logs from last 30 minutes
          }).toList();
          
          final hasAlert = recentLogs.any((log) => !log.isWithinRange);
          
          if (hasAlert) {
            _temperatureAlerts[order.id] = true;
          }
        }
      }
    }
  }
  
  // Get temperature status for display
  String getTemperatureStatus(Order order) {
    if (order.temperatureLogs.isEmpty) {
      return 'No temperature data';
    }
    
    if (order.status != OrderStatus.inTransit) {
      return order.isTemperatureMaintained 
          ? 'Temperature maintained'
          : 'Temperature breach detected';
    }
    
    final latestLog = order.temperatureLogs.last;
    
    if (latestLog.isWithinRange) {
      return 'Temperature OK';
    } else {
      final requirement = order.items.first.temperatureRequirement;
      final deviation = TemperatureUtils.getTemperatureDeviation(
        latestLog.temperature, requirement);
      
      return 'Temperature breach: ${deviation.toStringAsFixed(1)}°C deviation';
    }
  }
  
  // Get orders for vendor
  Future<void> fetchVendorOrders(String vendorId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final orders = await _orderService.getVendorOrders(vendorId);
      _orders = orders;
      _updateTemperatureAlerts();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  // Get orders for delivery partner
  Future<void> fetchDeliveryPartnerOrders(String deliveryPartnerId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final orders = await _orderService.getOrdersForDeliveryPartner(deliveryPartnerId);
      _orders = orders;
      _updateTemperatureAlerts();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
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
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
} 