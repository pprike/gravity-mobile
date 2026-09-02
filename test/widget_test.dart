import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/app/app.dart";
import "package:gravity_mobile/core/auth/auth_storage.dart";
import "package:gravity_mobile/core/providers/app_providers.dart";

void main() {
  ProviderScope app() {
    return ProviderScope(
      overrides: [
        authStorageProvider.overrideWithValue(
          AuthStorage(persistToSecureStorage: false),
        ),
      ],
      child: const GravityApp(),
    );
  }

  testWidgets("shows login screen", (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text("Welcome back"), findsOneWidget);
    expect(find.textContaining("Sign in to your"), findsOneWidget);
    expect(find.text("Email Address"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Sign In"), findsOneWidget);
    expect(find.text("Explore demo studio"), findsOneWidget);
  });

  testWidgets("demo studio opens the member dashboard", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Explore demo studio"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining("Hello, Alex"), findsOneWidget);
    expect(find.text("Book class"), findsOneWidget);
    expect(find.text("Check in"), findsOneWidget);
  });
}
