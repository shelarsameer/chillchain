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

class DeliveryAddress {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? latitude;
  final double? longitude;
  
  DeliveryAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
  });
  
  /// Create a delivery address from a simple string
  factory DeliveryAddress.fromString(String address) {
    return DeliveryAddress(
      addressLine1: address,
    );
  }
  
  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      if (city != null && state != null) '$city, $state',
      postalCode,
      country,
    ].where((part) => part != null && part.isNotEmpty).toList();
    
    return parts.join(', ');
  }
  
  Map<String, dynamic> toMap() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  
  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      addressLine1: map['addressLine1'],
      addressLine2: map['addressLine2'],
      city: map['city'],
      state: map['state'],
      postalCode: map['postalCode'],
      country: map['country'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;
  final TemperatureRequirement temperatureRequirement;
  
  // In-memory only
  Product? product;
  
  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.temperatureRequirement,
    this.product,
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
  final double discount;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final DeliveryAddress? deliveryAddress;
  final OrderStatus status;
  final List<TemperatureLog> temperatureLogs;
  final String? paymentId;
  final String? paymentMethod;
  final bool isPaid;
  final String? notes;
  final String customerName;
  final String? customerPhone;
  final Map<String, DateTime> statusChanges;
  
  Order({
    required this.id,
    required this.userId,
    required this.vendorId,
    this.deliveryPartnerId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.tax = 0.0,
    required this.total,
    this.discount = 0.0,
    required this.orderDate,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.deliveryAddress,
    required this.status,
    required this.temperatureLogs,
    this.paymentId,
    this.paymentMethod,
    this.isPaid = false,
    this.notes,
    required this.customerName,
    this.customerPhone,
    Map<String, DateTime>? statusChanges,
  }) : this.statusChanges = statusChanges ?? {OrderStatus.pending.toString(): orderDate};
  
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
      'discount': discount,
      'total': total,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'estimatedDeliveryTime': estimatedDeliveryTime?.millisecondsSinceEpoch,
      'actualDeliveryTime': actualDeliveryTime?.millisecondsSinceEpoch,
      'deliveryAddress': deliveryAddress?.toMap(),
      'status': status.toString().split('.').last,
      'temperatureLogs': temperatureLogs.map((log) => log.toMap()).toList(),
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'notes': notes,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'statusChanges': statusChanges.map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
    };
  }
  
  factory Order.fromMap(Map<String, dynamic> map) {
    Map<String, DateTime> statusChangesMap = {};
    if (map['statusChanges'] != null) {
      (map['statusChanges'] as Map<String, dynamic>).forEach((key, value) {
        statusChangesMap[key] = DateTime.fromMillisecondsSinceEpoch(value);
      });
    } else {
      statusChangesMap = {
        OrderStatus.pending.toString(): DateTime.fromMillisecondsSinceEpoch(map['orderDate'])
      };
    }
    
    return Order(
      id: map['id'],
      userId: map['userId'],
      vendorId: map['vendorId'],
      deliveryPartnerId: map['deliveryPartnerId'],
      items: (map['items'] as List).map((item) => OrderItem.fromMap(item)).toList(),
      subtotal: map['subtotal'],
      deliveryFee: map['deliveryFee'],
      tax: map['tax'] ?? 0.0,
      discount: map['discount'] ?? 0.0,
      total: map['total'],
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate']),
      estimatedDeliveryTime: map['estimatedDeliveryTime'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['estimatedDeliveryTime']) 
        : null,
      actualDeliveryTime: map['actualDeliveryTime'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['actualDeliveryTime']) 
        : null,
      deliveryAddress: map['deliveryAddress'] != null 
        ? DeliveryAddress.fromMap(map['deliveryAddress']) 
        : null,
      status: OrderStatusExtension.fromString(map['status']),
      temperatureLogs: (map['temperatureLogs'] as List).map((log) => TemperatureLog.fromMap(log)).toList(),
      paymentId: map['paymentId'],
      paymentMethod: map['paymentMethod'],
      isPaid: map['isPaid'] ?? false,
      notes: map['notes'],
      customerName: map['customerName'] ?? 'Customer',
      customerPhone: map['customerPhone'],
      statusChanges: statusChangesMap,
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
    double? discount,
    double? total,
    DateTime? orderDate,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    DeliveryAddress? deliveryAddress,
    OrderStatus? status,
    List<TemperatureLog>? temperatureLogs,
    String? paymentId,
    String? paymentMethod,
    bool? isPaid,
    String? notes,
    String? customerName,
    String? customerPhone,
    Map<String, DateTime>? statusChanges,
  }) {
    // Create a copy of the current status changes
    final updatedStatusChanges = Map<String, DateTime>.from(this.statusChanges);
    
    // If status is changed, add the new status change timestamp
    if (status != null && status != this.status) {
      updatedStatusChanges[status.toString()] = DateTime.now();
    }
    
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      temperatureLogs: temperatureLogs ?? this.temperatureLogs,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      statusChanges: statusChanges ?? updatedStatusChanges,
    );
  }
} 