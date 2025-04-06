class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final TemperatureRequirement temperatureRequirement;
  final double weight;
  final DateTime expiryDate;
  final String vendorId;
  final int stockQuantity;
  final double rating;
  final List<ProductReview> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.temperatureRequirement,
    required this.weight,
    required this.expiryDate,
    required this.vendorId,
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.reviews = const [],
  });

  // Convert Product to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'temperatureRequirement': temperatureRequirement.toMap(),
      'weight': weight,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'vendorId': vendorId,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviews': reviews.map((e) => e.toMap()).toList(),
    };
  }

  // Create Product from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      temperatureRequirement: TemperatureRequirement.fromMap(map['temperatureRequirement']),
      weight: map['weight'],
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      vendorId: map['vendorId'],
      stockQuantity: map['stockQuantity'] ?? 0,
      rating: map['rating'] ?? 0.0,
      reviews: List<ProductReview>.from(map['reviews'].map((e) => ProductReview.fromMap(e))),
    );
  }

  // Copy product with modifications
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    TemperatureRequirement? temperatureRequirement,
    double? weight,
    DateTime? expiryDate,
    String? vendorId,
    int? stockQuantity,
    double? rating,
    List<ProductReview>? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      temperatureRequirement: temperatureRequirement ?? this.temperatureRequirement,
      weight: weight ?? this.weight,
      expiryDate: expiryDate ?? this.expiryDate,
      vendorId: vendorId ?? this.vendorId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
    );
  }
}

class TemperatureRequirement {
  final double minTemperature;
  final double maxTemperature;
  final TemperatureZone zone;

  TemperatureRequirement({
    required this.minTemperature,
    required this.maxTemperature,
    required this.zone,
  });

  // Convert TemperatureRequirement to Map
  Map<String, dynamic> toMap() {
    return {
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'zone': zone.toString().split('.').last,
    };
  }

  // Create TemperatureRequirement from Map
  factory TemperatureRequirement.fromMap(Map<String, dynamic> map) {
    return TemperatureRequirement(
      minTemperature: map['minTemperature'],
      maxTemperature: map['maxTemperature'],
      zone: TemperatureZoneExtension.fromString(map['zone']),
    );
  }
}

enum TemperatureZone { frozen, chilled, cool, ambient }

extension TemperatureZoneExtension on TemperatureZone {
  String get displayName {
    switch (this) {
      case TemperatureZone.frozen:
        return 'Frozen';
      case TemperatureZone.chilled:
        return 'Chilled';
      case TemperatureZone.cool:
        return 'Cool';
      case TemperatureZone.ambient:
        return 'Ambient';
    }
  }
  
  String get temperatureRange {
    switch (this) {
      case TemperatureZone.frozen:
        return '-25°C to -18°C';
      case TemperatureZone.chilled:
        return '0°C to 4°C';
      case TemperatureZone.cool:
        return '8°C to 15°C';
      case TemperatureZone.ambient:
        return '15°C to 25°C';
    }
  }
  
  static TemperatureZone fromString(String value) {
    switch (value.toLowerCase()) {
      case 'frozen':
        return TemperatureZone.frozen;
      case 'chilled':
        return TemperatureZone.chilled;
      case 'cool':
        return TemperatureZone.cool;
      case 'ambient':
        return TemperatureZone.ambient;
      default:
        return TemperatureZone.chilled;
    }
  }
}

class ProductReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  
  ProductReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
  
  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      rating: map['rating'],
      comment: map['comment'],
      date: DateTime.parse(map['date']),
    );
  }
} 