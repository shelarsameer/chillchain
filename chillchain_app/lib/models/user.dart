enum UserType { customer, vendor, deliveryPartner, admin }

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.customer:
        return 'Customer';
      case UserType.vendor:
        return 'Vendor';
      case UserType.deliveryPartner:
        return 'Delivery Partner';
      case UserType.admin:
        return 'Admin';
    }
  }
  
  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => UserType.customer,
    );
  }
}

class Address {
  final String id;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String? label;
  
  Address({
    required this.id,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.label,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
    };
  }
  
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      streetAddress: map['streetAddress'],
      city: map['city'],
      state: map['state'],
      postalCode: map['postalCode'],
      country: map['country'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      label: map['label'],
    );
  }
  
  String get fullAddress {
    return '$streetAddress, $city, $state $postalCode, $country';
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final UserType userType;
  final List<Address> addresses;
  final DateTime createdAt;
  final DateTime lastActive;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.userType,
    required this.addresses,
    required this.createdAt,
    required this.lastActive,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'userType': userType.toString().split('.').last,
      'addresses': addresses.map((address) => address.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActive': lastActive.millisecondsSinceEpoch,
    };
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      userType: UserTypeExtension.fromString(map['userType']),
      addresses: (map['addresses'] as List).map((address) => Address.fromMap(address)).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastActive: DateTime.fromMillisecondsSinceEpoch(map['lastActive']),
    );
  }
  
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    UserType? userType,
    List<Address>? addresses,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userType: userType ?? this.userType,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class VendorDetails {
  final String userId;
  final String businessName;
  final String businessRegistrationNumber;
  final Address warehouseAddress;
  final List<String> temperatureZones;
  final bool isVerified;
  final double rating;
  final int totalRatings;
  
  VendorDetails({
    required this.userId,
    required this.businessName,
    required this.businessRegistrationNumber,
    required this.warehouseAddress,
    required this.temperatureZones,
    required this.isVerified,
    required this.rating,
    required this.totalRatings,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessName': businessName,
      'businessRegistrationNumber': businessRegistrationNumber,
      'warehouseAddress': warehouseAddress.toMap(),
      'temperatureZones': temperatureZones,
      'isVerified': isVerified,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }
  
  factory VendorDetails.fromMap(Map<String, dynamic> map) {
    return VendorDetails(
      userId: map['userId'],
      businessName: map['businessName'],
      businessRegistrationNumber: map['businessRegistrationNumber'],
      warehouseAddress: Address.fromMap(map['warehouseAddress']),
      temperatureZones: List<String>.from(map['temperatureZones']),
      isVerified: map['isVerified'],
      rating: map['rating'],
      totalRatings: map['totalRatings'],
    );
  }
}

class DeliveryPartnerDetails {
  final String userId;
  final String vehicleNumber;
  final String vehicleType;
  final bool hasTemperatureControl;
  final List<String> temperatureZones;
  final bool isVerified;
  final bool isAvailable;
  final double rating;
  final int totalRatings;
  final double currentLatitude;
  final double currentLongitude;
  
  DeliveryPartnerDetails({
    required this.userId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.hasTemperatureControl,
    required this.temperatureZones,
    required this.isVerified,
    required this.isAvailable,
    required this.rating,
    required this.totalRatings,
    required this.currentLatitude,
    required this.currentLongitude,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'hasTemperatureControl': hasTemperatureControl,
      'temperatureZones': temperatureZones,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalRatings': totalRatings,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    };
  }
  
  factory DeliveryPartnerDetails.fromMap(Map<String, dynamic> map) {
    return DeliveryPartnerDetails(
      userId: map['userId'],
      vehicleNumber: map['vehicleNumber'],
      vehicleType: map['vehicleType'],
      hasTemperatureControl: map['hasTemperatureControl'],
      temperatureZones: List<String>.from(map['temperatureZones']),
      isVerified: map['isVerified'],
      isAvailable: map['isAvailable'],
      rating: map['rating'],
      totalRatings: map['totalRatings'],
      currentLatitude: map['currentLatitude'],
      currentLongitude: map['currentLongitude'],
    );
  }
} 