class Review {
  final String id;
  final String userId;
  final String userName;
  final String facilityId;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isVerified;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.facilityId,
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerified = false,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'facilityId': facilityId,
      'rating': rating,
      'comment': comment,
      'date': date.millisecondsSinceEpoch,
      'isVerified': isVerified,
    };
  }

  // Create from Map
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      facilityId: map['facilityId'],
      rating: map['rating'],
      comment: map['comment'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isVerified: map['isVerified'] ?? false,
    );
  }

  // Copy with modifications
  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? facilityId,
    double? rating,
    String? comment,
    DateTime? date,
    bool? isVerified,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      facilityId: facilityId ?? this.facilityId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      isVerified: isVerified ?? this.isVerified,
    );
  }
} 