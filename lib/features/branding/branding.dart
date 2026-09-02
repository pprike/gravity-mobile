import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_client.dart";
import "../../core/providers/app_providers.dart";

class TenantBranding {
  const TenantBranding({
    this.primaryColor,
    this.accentColor,
    this.logoUrl,
    this.fontFamily,
    this.organizationName = "Gravity",
  });

  final Color? primaryColor;
  final Color? accentColor;
  final String? logoUrl;
  final String? fontFamily;
  final String organizationName;

  factory TenantBranding.fromJson(Map<String, dynamic> json) {
    return TenantBranding(
      primaryColor: _parseColor(json["primaryColor"] as String?),
      accentColor: _parseColor(json["accentColor"] as String?),
      logoUrl: json["logoUrl"] as String?,
      fontFamily: json["fontFamily"] as String?,
      organizationName: json["organizationName"] as String? ?? "Gravity",
    );
  }

  static Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) return null;
    var hex = value.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    if (hex.length != 8) return null;
    return Color(int.parse(hex, radix: 16));
  }
}

class BrandingRepository {
  BrandingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<TenantBranding> getBranding() {
    return _apiClient.get(
      "/api/v1/organizations/current/branding",
      fromJson: (json) => TenantBranding.fromJson(json as Map<String, dynamic>),
    );
  }
}

final brandingRepositoryProvider = Provider<BrandingRepository>((ref) {
  return BrandingRepository(ref.watch(apiClientProvider));
});

final tenantBrandingProvider = FutureProvider<TenantBranding>((ref) async {
  try {
    return await ref.watch(brandingRepositoryProvider).getBranding();
  } catch (_) {
    return const TenantBranding();
  }
});
