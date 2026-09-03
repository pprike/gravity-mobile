import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/core/api/api_exception.dart";
import "package:gravity_mobile/features/scheduling/class_detail_sheet.dart";
import "package:gravity_mobile/features/scheduling/models/scheduling_models.dart";

ClassSession _session({int capacity = 10, int bookedCount = 0}) {
  final startsAt = DateTime.now().add(const Duration(days: 1));
  return ClassSession(
    id: "session-1",
    name: "Morning Yoga",
    startsAt: startsAt,
    endsAt: startsAt.add(const Duration(hours: 1)),
    capacity: capacity,
    bookedCount: bookedCount,
    status: "scheduled",
    bookedByMe: false,
  );
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required ClassSession session,
  required Future<void> Function() onBook,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ClassDetailSheet(
          session: session,
          onBook: onBook,
          onWaitlist: () async {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets("surfaces a booking failure inline instead of failing silently", (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      session: _session(),
      onBook: () async => throw ApiException(
        message: "This class is already full.",
        code: "BOOKING_CONFLICT",
        statusCode: 409,
      ),
    );

    await tester.tap(find.text("Book this class"));
    await tester.pumpAndSettle();

    expect(find.text("This class is already full."), findsOneWidget);
    // The sheet stays open so the member can react to the failure.
    expect(find.text("Book this class"), findsOneWidget);
  });

  testWidgets("does not leak transport details into the failure message", (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      session: _session(),
      onBook: () async => throw ApiException(
        message: "DioException [connection error]: http://localhost:8080",
        code: "NETWORK_ERROR",
      ),
    );

    await tester.tap(find.text("Book this class"));
    await tester.pumpAndSettle();

    expect(find.textContaining("DioException"), findsNothing);
    expect(find.textContaining("Check your connection"), findsOneWidget);
  });

  testWidgets("closes on a successful booking", (tester) async {
    var booked = false;
    await _pumpSheet(
      tester,
      session: _session(),
      onBook: () async => booked = true,
    );

    await tester.tap(find.text("Book this class"));
    await tester.pumpAndSettle();

    expect(booked, isTrue);
    expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
  });
}
