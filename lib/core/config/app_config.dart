import "package:flutter/foundation.dart";

class AppConfig {
  const AppConfig({required this.apiBaseUrl, this.enableDemo = false});

  final String apiBaseUrl;
  final bool enableDemo;

  static AppConfig fromEnvironment() {
    const baseUrl = String.fromEnvironment(
      "API_BASE_URL",
      defaultValue: "http://localhost:8080",
    );
    const enableDemo = bool.fromEnvironment("ENABLE_DEMO");
    return AppConfig(
      apiBaseUrl: baseUrl.replaceAll(RegExp(r"/$"), ""),
      enableDemo: enableDemo || kDebugMode,
    );
  }
}
