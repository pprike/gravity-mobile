class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  static AppConfig fromEnvironment() {
    const baseUrl = String.fromEnvironment(
      "API_BASE_URL",
      defaultValue: "http://localhost:8080",
    );
    return AppConfig(apiBaseUrl: baseUrl.replaceAll(RegExp(r"/$"), ""));
  }
}
