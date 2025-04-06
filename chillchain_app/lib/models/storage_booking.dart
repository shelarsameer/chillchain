import 'storage.dart';
import 'product.dart' as product;

/// StorageBooking represents a booking request made by a farmer/producer
/// to store items in a cold storage facility
class StorageBooking {
  final String id;
  final String userId; // Farmer/producer ID
  final String facilityId; // Cold storage facility ID
  final String? compartmentId; // Optional specific compartment request
  final DateTime requestDate;
  final DateTime startDate;
  final DateTime endDate; // Expected end date
  final List<BookingItem> items;
  final StorageBookingType bookingType;
  final BookingStatus status;
  final double totalAmount;
  final bool isPaid;
  final String? paymentId;
  final String? notes;
  
  StorageBooking({
    required this.id,
    required this.userId,
    required this.facilityId,
    this.compartmentId,
    required this.requestDate,
    required this.startDate,
    required this.endDate,
    required this.items,
    required this.bookingType,
    this.status = BookingStatus.pending,
    required this.totalAmount,
    this.isPaid = false,
    this.paymentId,
    this.notes,
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'facilityId': facilityId,
      'compartmentId': compartmentId,
      'requestDate': requestDate.millisecondsSinceEpoch,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'items': items.map((item) => item.toMap()).toList(),
      'bookingType': bookingType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'paymentId': paymentId,
      'notes': notes,
    };
  }
  
  // Create from Map
  factory StorageBooking.fromMap(Map<String, dynamic> map) {
    return StorageBooking(
      id: map['id'],
      userId: map['userId'],
      facilityId: map['facilityId'],
      compartmentId: map['compartmentId'],
      requestDate: DateTime.fromMillisecondsSinceEpoch(map['requestDate']),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      items: (map['items'] as List)
          .map((item) => BookingItem.fromMap(item))
          .toList(),
      bookingType: StorageBookingTypeExtension.fromString(map['bookingType']),
      status: BookingStatusExtension.fromString(map['status']),
      totalAmount: map['totalAmount'],
      isPaid: map['isPaid'] ?? false,
      paymentId: map['paymentId'],
      notes: map['notes'],
    );
  }
  
  // Get total weight of all items
  double get totalWeight {
    return items.fold(0.0, (sum, item) => sum + item.quantity);
  }
  
  // Get total space required
  double get totalSpaceRequired {
    return items.fold(0.0, (sum, item) => sum + item.spaceRequired);
  }
  
  // Get booking duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }
  
  // Check if booking is active
  bool get isActive {
    final now = DateTime.now();
    return status == BookingStatus.active && 
           now.isAfter(startDate) && 
           now.isBefore(endDate);
  }
  
  // Check if booking is overdue
  bool get isOverdue {
    return status == BookingStatus.active && 
           DateTime.now().isAfter(endDate);
  }
  
  // Create a copy with updates
  StorageBooking copyWith({
    String? id,
    String? userId,
    String? facilityId,
    String? compartmentId,
    DateTime? requestDate,
    DateTime? startDate,
    DateTime? endDate,
    List<BookingItem>? items,
    StorageBookingType? bookingType,
    BookingStatus? status,
    double? totalAmount,
    bool? isPaid,
    String? paymentId,
    String? notes,
  }) {
    return StorageBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      facilityId: facilityId ?? this.facilityId,
      compartmentId: compartmentId ?? this.compartmentId,
      requestDate: requestDate ?? this.requestDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      items: items ?? this.items,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      isPaid: isPaid ?? this.isPaid,
      paymentId: paymentId ?? this.paymentId,
      notes: notes ?? this.notes,
    );
  }
}

/// BookingItem represents a product to be stored in a cold storage facility
class BookingItem {
  final String id;
  final String productId;
  final String productName;
  final String category;
  final double quantity; // Quantity in weight (kg)
  final product.TemperatureZone temperatureZone;
  final DateTime expiryDate;
  final double spaceRequired; // Space in cubic meters
  
  BookingItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.temperatureZone,
    required this.expiryDate,
    required this.spaceRequired,
  });
  
  // Add name getter as an alias for productName
  String get name => productName;
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'temperatureZone': temperatureZone.toString().split('.').last,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'spaceRequired': spaceRequired,
    };
  }
  
  // Create from Map
  factory BookingItem.fromMap(Map<String, dynamic> map) {
    return BookingItem(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      category: map['category'],
      quantity: map['quantity'],
      temperatureZone: product.TemperatureZoneExtension.fromString(map['temperatureZone']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      spaceRequired: map['spaceRequired'],
    );
  }
  
  // Create a copy with updates
  BookingItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? category,
    double? quantity,
    product.TemperatureZone? temperatureZone,
    DateTime? expiryDate,
    double? spaceRequired,
  }) {
    return BookingItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      temperatureZone: temperatureZone ?? this.temperatureZone,
      expiryDate: expiryDate ?? this.expiryDate,
      spaceRequired: spaceRequired ?? this.spaceRequired,
    );
  }
} 