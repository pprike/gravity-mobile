import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/network/connectivity_providers.dart";
import "../../core/providers/app_providers.dart";
import "../../core/push/push_intent.dart";
import "../../core/push/push_service.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/theme/text_scaling.dart";
import "../../core/widgets/gravity_app_header.dart";
import "../../core/widgets/gravity_offline_banner.dart";
import "../announcements/announcement_providers.dart";
import "../community/community_screen.dart";
import "../notifications/notification_providers.dart";
import "../notifications/notifications_inbox_screen.dart";
import "../profile/profile_controller.dart";
import "../profile/profile_screen.dart";
import "../scheduling/bookings_screen.dart";
import "../scheduling/schedule_screen.dart";
import "../scheduling/scheduling_providers.dart";
import "dashboard_screen.dart";

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // The shell only mounts once a member is signed in, which is exactly when
    // we're allowed to attach their device to the studio.
    ref.read(pushServiceProvider).start();
  }

  void _goToTab(int index) => setState(() => _index = index);

  void _openInbox() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotificationsInboxScreen()),
    );
  }

  void _handlePushIntent(PushOpenIntent intent) {
    ref.read(pushOpenIntentProvider.notifier).state = null;
    switch (intent.destination) {
      case PushDestination.inbox:
        _openInbox();
      case PushDestination.schedule:
        _goToTab(1);
      case PushDestination.bookings:
        _goToTab(2);
      case PushDestination.community:
        _goToTab(3);
    }
  }

  void _showForegroundPush(ForegroundPush push) {
    ref.read(foregroundPushProvider.notifier).state = null;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              push.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (push.body.isNotEmpty) Text(push.body),
          ],
        ),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: "View",
          textColor: context.palette.onInverseSurface,
          onPressed: () => _handlePushIntent(
            push.intent ??
                const PushOpenIntent(destination: PushDestination.inbox),
          ),
        ),
      ),
    );
  }

  /// Anything a member sees without an explicit refresh gesture, so coming back
  /// online doesn't leave them staring at a stale error state.
  void _refetchAfterReconnect() {
    ref.invalidate(classSessionsProvider);
    ref.invalidate(weekSessionsProvider);
    ref.invalidate(upcomingBookingsProvider);
    ref.invalidate(announcementsProvider);
    ref.invalidate(inboxProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.valueOrNull == false;
      if (wasOffline && next.valueOrNull == true) _refetchAfterReconnect();
    });

    // Both fire from outside the widget tree, so they're deferred a frame to
    // avoid navigating or showing a snack bar mid-build.
    ref.listen(pushOpenIntentProvider, (_, intent) {
      if (intent == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handlePushIntent(intent);
      });
    });
    ref.listen(foregroundPushProvider, (_, push) {
      if (push == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showForegroundPush(push);
      });
    });

    final unread = ref.watch(unreadNotificationCountProvider);
    final session = ref.watch(authSessionProvider).value;
    final subscription = session == null
        ? null
        : ref.watch(memberSubscriptionProvider(session.user.id)).valueOrNull;
    final billingAlert = subscription?.requiresPaymentAction == true;
    final pages = [
      DashboardScreen(
        onBookClass: () => _goToTab(1),
        onViewBookings: () => _goToTab(2),
        onOpenCommunity: () => _goToTab(3),
      ),
      const ScheduleScreen(),
      BookingsScreen(onBrowseSchedule: () => _goToTab(1)),
      const CommunityScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: context.palette.surfaceMuted,
      extendBody: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            GravityAppHeader(onNotifications: _openInbox, unreadCount: unread),
            const GravityOfflineBanner(),
            if (billingAlert)
              _BillingAlertBanner(
                onTap: () => _goToTab(4),
                isPastDue: subscription!.isPastDue,
              ),
            Expanded(
              child: ClipRect(
                child: IndexedStack(index: _index, children: pages),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.surface,
          border: Border(top: BorderSide(color: context.palette.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarTheme.of(
              context,
            ).copyWith(height: 64 + 16 * context.textScale),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _goToTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: "Dashboard",
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: "Schedule",
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note_rounded),
                  label: "Bookings",
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: Icon(Icons.chat_bubble_rounded),
                  label: "Community",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BillingAlertBanner extends StatelessWidget {
  const _BillingAlertBanner({required this.onTap, this.isPastDue = false});

  final VoidCallback onTap;
  final bool isPastDue;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      button: true,
      label: isPastDue
          ? "Payment past due. Tap to update billing."
          : "Membership frozen. Tap to update billing.",
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          color: const Color(0xFFDC2626),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isPastDue
                      ? "Payment past due — tap to update your billing info."
                      : "Membership frozen — tap to update your billing info.",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
