import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  assigned,
  outForDelivery,
  inTransit,
  delivered,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.assigned:
        return 'Assigned';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;
  final TemperatureRequirement temperatureRequirement;
  
  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.temperatureRequirement,
  });
  
  double get subtotal => price * quantity;
  
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'temperatureRequirement': temperatureRequirement.toMap(),
    };
  }
  
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      quantity: map['quantity'],
      price: map['price'],
      temperatureRequirement: TemperatureRequirement.fromMap(map['temperatureRequirement']),
    );
  }
}

class TemperatureLog {
  final DateTime timestamp;
  final double temperature;
  final String sensorId;
  final bool isWithinRange;
  
  TemperatureLog({
    required this.timestamp,
    required this.temperature,
    required this.sensorId,
    required this.isWithinRange,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'temperature': temperature,
      'sensorId': sensorId,
      'isWithinRange': isWithinRange,
    };
  }
  
  factory TemperatureLog.fromMap(Map<String, dynamic> map) {
    return TemperatureLog(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      temperature: map['temperature'],
      sensorId: map['sensorId'],
      isWithinRange: map['isWithinRange'],
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String vendorId;
  final String? deliveryPartnerId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String deliveryAddress;
  final OrderStatus status;
  final List<TemperatureLog> temperatureLogs;
  final String? paymentId;
  final String? notes;
  final String customerName;
  
  Order({
    required this.id,
    required this.userId,
    required this.vendorId,
    this.deliveryPartnerId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.orderDate,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    required this.deliveryAddress,
    required this.status,
    required this.temperatureLogs,
    this.paymentId,
    this.notes,
    required this.customerName,
  });
  
  DateTime get dateCreated => orderDate;
  double get totalAmount => total;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vendorId': vendorId,
      'deliveryPartnerId': deliveryPartnerId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'estimatedDeliveryTime': estimatedDeliveryTime?.millisecondsSinceEpoch,
      'actualDeliveryTime': actualDeliveryTime?.millisecondsSinceEpoch,
      'deliveryAddress': deliveryAddress,
      'status': status.toString().split('.').last,
      'temperatureLogs': temperatureLogs.map((log) => log.toMap()).toList(),
      'paymentId': paymentId,
      'notes': notes,
      'customerName': customerName,
    };
  }
  
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      vendorId: map['vendorId'],
      deliveryPartnerId: map['deliveryPartnerId'],
      items: (map['items'] as List).map((item) => OrderItem.fromMap(item)).toList(),
      subtotal: map['subtotal'],
      deliveryFee: map['deliveryFee'],
      tax: map['tax'],
      total: map['total'],
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate']),
      estimatedDeliveryTime: map['estimatedDeliveryTime'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['estimatedDeliveryTime']) 
        : null,
      actualDeliveryTime: map['actualDeliveryTime'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['actualDeliveryTime']) 
        : null,
      deliveryAddress: map['deliveryAddress'],
      status: OrderStatusExtension.fromString(map['status']),
      temperatureLogs: (map['temperatureLogs'] as List).map((log) => TemperatureLog.fromMap(log)).toList(),
      paymentId: map['paymentId'],
      notes: map['notes'],
      customerName: map['customerName'] ?? 'Customer',
    );
  }
  
  bool get isTemperatureMaintained {
    if (temperatureLogs.isEmpty) return true;
    return !temperatureLogs.any((log) => !log.isWithinRange);
  }
  
  Order copyWith({
    String? id,
    String? userId,
    String? vendorId,
    String? deliveryPartnerId,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? total,
    DateTime? orderDate,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    String? deliveryAddress,
    OrderStatus? status,
    List<TemperatureLog>? temperatureLogs,
    String? paymentId,
    String? notes,
    String? customerName,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      temperatureLogs: temperatureLogs ?? this.temperatureLogs,
      paymentId: paymentId ?? this.paymentId,
      notes: notes ?? this.notes,
      customerName: customerName ?? this.customerName,
    );
  }
} 