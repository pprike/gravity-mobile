class MemberSubscription {
  const MemberSubscription({
    this.planName,
    this.status,
    this.priceLabel,
    this.renewalLabel,
    this.remainingCredits,
    this.features = const [],
  });

  final String? planName;
  final String? status;
  final String? priceLabel;
  final String? renewalLabel;
  final int? remainingCredits;
  final List<String> features;

  bool get isActive =>
      (status ?? "").toLowerCase() == "active" ||
      (status ?? "").toLowerCase() == "trialing";

  factory MemberSubscription.fromJson(Map<String, dynamic> json) {
    return MemberSubscription(
      planName: json["planName"] as String?,
      status: json["status"] as String?,
      priceLabel: json["priceLabel"] as String?,
      renewalLabel: json["renewalLabel"] as String?,
      remainingCredits: json["remainingCredits"] as int?,
      features: (json["features"] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
