import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_app_header.dart";
import "../community/community_screen.dart";
import "../notifications/notification_providers.dart";
import "../notifications/notifications_inbox_screen.dart";
import "../profile/profile_screen.dart";
import "../scheduling/bookings_screen.dart";
import "../scheduling/schedule_screen.dart";
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationRepositoryProvider)
          .registerDevice(
            token: "gravity-device-${DateTime.now().millisecondsSinceEpoch}",
            platform: notificationPlatformLabel(),
          );
    });
  }

  void _goToTab(int index) => setState(() => _index = index);

  void _openInbox() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationsInboxScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final pages = [
      DashboardScreen(
        onBookClass: () => _goToTab(1),
        onViewBookings: () => _goToTab(2),
        onOpenCommunity: () => _goToTab(3),
      ),
      const ScheduleScreen(),
      const BookingsScreen(),
      const CommunityScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: GravityColors.neutral50,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            GravityAppHeader(
              onNotifications: _openInbox,
              unreadCount: unread,
            ),
            Expanded(
              child: IndexedStack(index: _index, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: GravityColors.gray200)),
        ),
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
    );
  }
}
