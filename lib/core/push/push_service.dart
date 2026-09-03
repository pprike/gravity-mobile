import "dart:async";

import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../features/notifications/notification_providers.dart";
import "push_intent.dart";

/// Handles messages delivered while the app is terminated or backgrounded.
///
/// The OS draws the notification itself, so there is nothing to do here beyond
/// keeping an isolate entry point alive — the inbox re-reads on next launch.
@pragma("vm:entry-point")
Future<void> gravityBackgroundMessageHandler(RemoteMessage message) async {}

/// Registers the device with the studio and turns delivered pushes into
/// in-app effects (inbox refresh, foreground banner, tap routing).
///
/// Every entry point degrades to a no-op when Firebase is not configured for
/// the current platform, so the app still runs without `google-services.json`
/// or `GoogleService-Info.plist`.
class PushService {
  PushService(this._ref);

  final Ref _ref;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _started = false;

  bool get _supportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> start() async {
    if (_started || !_supportedPlatform) return;
    _started = true;

    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } catch (error) {
      debugPrint("Push disabled: Firebase is not configured ($error)");
      return;
    }

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // The member can still read everything in the in-app inbox.
      return;
    }

    FirebaseMessaging.onBackgroundMessage(gravityBackgroundMessageHandler);

    await _registerToken(await messaging.getToken());
    _subscriptions.add(messaging.onTokenRefresh.listen(_registerToken));
    _subscriptions.add(FirebaseMessaging.onMessage.listen(_handleForeground));
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpened),
    );

    // A push that launched the app from terminated state.
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleOpened(initial);
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) return;
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? "ios"
        : "android";
    try {
      await _ref
          .read(notificationRepositoryProvider)
          .registerDevice(token: token, platform: platform);
    } catch (error) {
      // Registration retries on the next launch or token refresh.
      debugPrint("Could not register push token: $error");
    }
  }

  void _handleForeground(RemoteMessage message) {
    _ref.invalidate(inboxProvider);

    final notification = message.notification;
    if (notification == null) return;
    _ref.read(foregroundPushProvider.notifier).state = ForegroundPush(
      title: notification.title ?? "New update",
      body: notification.body ?? "",
      intent: PushOpenIntent.fromData(message.data),
    );
  }

  void _handleOpened(RemoteMessage message) {
    _ref.invalidate(inboxProvider);
    final intent =
        PushOpenIntent.fromData(message.data) ??
        const PushOpenIntent(destination: PushDestination.inbox);
    _ref.read(pushOpenIntentProvider.notifier).state = intent;
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(ref);
  ref.onDispose(service.dispose);
  return service;
});

/// Whether the OS lets us deliver push, or `null` when push isn't available in
/// this build (web, desktop, or missing Firebase config).
final pushAuthorizedProvider = FutureProvider<bool?>((ref) async {
  if (kIsWeb ||
      (defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS) ||
      Firebase.apps.isEmpty) {
    return null;
  }

  try {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  } catch (_) {
    return null;
  }
});
