class UserQRCode {
  final int? id;
  final int userId;
  final String qrCodeData;

  UserQRCode({
    this.id,
    required this.userId,
    required this.qrCodeData,
  });

  factory UserQRCode.fromJson(Map<String, dynamic> json) {
    return UserQRCode(
      id: json['id'],
      userId: json['user_id'],
      qrCodeData: json['qr_code_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'qr_code_data': qrCodeData,
    };
  }

  UserQRCode copyWith({
    int? id,
    int? userId,
    String? qrCodeData,
  }) {
    return UserQRCode(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }
}
