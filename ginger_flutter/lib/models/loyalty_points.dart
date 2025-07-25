class LoyaltyPoints {
  final int? id;
  final int userId;
  final int currentPoints;
  final DateTime lastUpdated;

  LoyaltyPoints({
    this.id,
    required this.userId,
    required this.currentPoints,
    required this.lastUpdated,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      id: json['id'],
      userId: json['user_id'],
      currentPoints: json['current_points'] ?? 0,
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'current_points': currentPoints,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  LoyaltyPoints copyWith({
    int? id,
    int? userId,
    int? currentPoints,
    DateTime? lastUpdated,
  }) {
    return LoyaltyPoints(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentPoints: currentPoints ?? this.currentPoints,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
