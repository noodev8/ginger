class User {
  final int? id;
  final String email;
  final String? phone;
  final String? displayName;
  final String? profileIconId;
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final bool staff;
  final bool emailVerified;
  final String? authToken;
  final DateTime? authTokenExpires;
  final bool? staffAdmin;

  User({
    this.id,
    required this.email,
    this.phone,
    this.displayName,
    this.profileIconId,
    this.passwordHash,
    this.createdAt,
    this.lastActiveAt,
    this.staff = false,
    this.emailVerified = false,
    this.authToken,
    this.authTokenExpires,
    this.staffAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      displayName: json['display_name'],
      profileIconId: json['profile_icon_id'],
      passwordHash: json['password_hash'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      lastActiveAt: json['last_active_at'] != null 
          ? DateTime.parse(json['last_active_at']) 
          : null,
      staff: json['staff'] ?? false,
      emailVerified: json['email_verified'] ?? false,
      authToken: json['auth_token'],
      authTokenExpires: json['auth_token_expires'] != null 
          ? DateTime.parse(json['auth_token_expires']) 
          : null,
      staffAdmin: json['staff_admin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'profile_icon_id': profileIconId,
      'password_hash': passwordHash,
      'created_at': createdAt?.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'staff': staff,
      'email_verified': emailVerified,
      'auth_token': authToken,
      'auth_token_expires': authTokenExpires?.toIso8601String(),
      'staff_admin': staffAdmin,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? phone,
    String? displayName,
    String? profileIconId,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? staff,
    bool? emailVerified,
    String? authToken,
    DateTime? authTokenExpires,
    bool? staffAdmin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      profileIconId: profileIconId ?? this.profileIconId,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      staff: staff ?? this.staff,
      emailVerified: emailVerified ?? this.emailVerified,
      authToken: authToken ?? this.authToken,
      authTokenExpires: authTokenExpires ?? this.authTokenExpires,
      staffAdmin: staffAdmin ?? this.staffAdmin,
    );
  }
}
