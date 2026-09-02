class CheckInQr {
  const CheckInQr({
    required this.token,
    required this.qrPayload,
    required this.expiresAt,
  });

  final String token;
  final String qrPayload;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory CheckInQr.fromJson(Map<String, dynamic> json) {
    return CheckInQr(
      token: json["token"] as String,
      qrPayload: json["qrPayload"] as String? ?? json["token"] as String,
      expiresAt: DateTime.parse(json["expiresAt"] as String).toLocal(),
    );
  }
}
