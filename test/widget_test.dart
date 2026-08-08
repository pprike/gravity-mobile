import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/app/app.dart";

void main() {
  testWidgets("shows login screen", (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GravityApp()));
    await tester.pumpAndSettle();

    expect(find.text("Sign in to your member account"), findsOneWidget);
    expect(find.text("Sign in"), findsOneWidget);
  });
}
