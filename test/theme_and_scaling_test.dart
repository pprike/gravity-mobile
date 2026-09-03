import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:gravity_mobile/app/app.dart";
import "package:gravity_mobile/core/auth/auth_storage.dart";
import "package:gravity_mobile/core/providers/app_providers.dart";
import "package:gravity_mobile/core/theme/gravity_palette.dart";
import "package:gravity_mobile/core/theme/theme_mode_controller.dart";

/// Renders the member shell end to end under a given brightness and font size.
///
/// Layout overflow is reported as a test failure, so these double as guards
/// against fixed heights clipping at large accessibility text sizes.
Future<void> _pumpApp(
  WidgetTester tester, {
  required ThemeMode themeMode,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(430 * 3, 932 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // Exercise the persisted preference rather than poking the notifier.
  SharedPreferences.setMockInitialValues({"appearance_mode": themeMode.name});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStorageProvider.overrideWithValue(
          AuthStorage(persistToSecureStorage: false),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const GravityApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text("Explore demo studio"));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets("renders the dashboard in ${mode.name} mode", (tester) async {
      await _pumpApp(tester, themeMode: mode);

      expect(find.text("Book class"), findsOneWidget);

      final context = tester.element(find.text("Book class"));
      final expected = mode == ThemeMode.dark
          ? GravityPalette.dark
          : GravityPalette.light;
      expect(
        context.palette.surface,
        expected.surface,
        reason: "screens must read colours from the active palette",
      );
      expect(Theme.of(context).scaffoldBackgroundColor, expected.canvas);
    });
  }

  testWidgets("dashboard survives the largest supported text size", (
    tester,
  ) async {
    await _pumpApp(tester, themeMode: ThemeMode.light, textScale: 2.0);

    expect(find.text("Book class"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("bookings tabs survive the largest supported text size", (
    tester,
  ) async {
    await _pumpApp(tester, themeMode: ThemeMode.dark, textScale: 2.0);

    await tester.tap(find.text("Bookings").last);
    await tester.pumpAndSettle();

    expect(find.text("Upcoming"), findsOneWidget);
    expect(find.text("History"), findsOneWidget);

    await tester.tap(find.text("History"));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
