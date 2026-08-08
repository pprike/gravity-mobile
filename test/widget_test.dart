import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/app/app.dart";

void main() {
  testWidgets("shows login screen", (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GravityApp()));
    await tester.pumpAndSettle();

    expect(find.text("Welcome back"), findsOneWidget);
    expect(find.textContaining("Sign in to your"), findsOneWidget);
    expect(find.text("Email Address"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Sign In"), findsOneWidget);
  });
}
