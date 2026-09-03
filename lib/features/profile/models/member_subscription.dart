class MemberSubscription {
  const MemberSubscription({
    this.planName,
    this.status,
    this.priceLabel,
    this.renewalLabel,
    this.remainingCredits,
    this.features = const [],
    this.allowedLocationIds = const [],
    this.allowedLocationNames = const [],
  });

  final String? planName;
  final String? status;
  final String? priceLabel;
  final String? renewalLabel;
  final int? remainingCredits;
  final List<String> features;

  /// IDs of locations this plan grants access to. Empty means all locations.
  final List<String> allowedLocationIds;

  /// Human-readable names corresponding to [allowedLocationIds].
  final List<String> allowedLocationNames;

  bool get isActive =>
      (status ?? "").toLowerCase() == "active" ||
      (status ?? "").toLowerCase() == "trialing";

  bool get isFrozen => (status ?? "").toLowerCase() == "frozen";

  bool get isPastDue => (status ?? "").toLowerCase() == "past_due";

  bool get requiresPaymentAction => isFrozen || isPastDue;

  String get statusLabel {
    switch ((status ?? "").toLowerCase()) {
      case "active":
        return "Active";
      case "trialing":
        return "Trial";
      case "frozen":
        return "Frozen — payment required";
      case "past_due":
        return "Past due — payment required";
      case "cancelled":
        return "Cancelled";
      default:
        return status ?? "";
    }
  }

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
      allowedLocationIds:
          (json["allowedLocationIds"] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      allowedLocationNames:
          (json["allowedLocationNames"] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
    );
  }
}
