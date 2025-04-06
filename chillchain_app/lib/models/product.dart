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
  final int stock;

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
    required this.stock,
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
      'stock': stock,
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
      stock: map['stock'] ?? 0,
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
    int? stock,
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
      stock: stock ?? this.stock,
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