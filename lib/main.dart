import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "app/app.dart";
import "core/api/response_cache.dart";
import "core/providers/app_providers.dart";
import "core/theme/theme_mode_controller.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        responseCacheProvider.overrideWithValue(ResponseCache(prefs)),
      ],
      child: const GravityApp(),
    ),
  );
}
