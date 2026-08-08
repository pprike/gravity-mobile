import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_card.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../profile/profile_screen.dart";

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).value;
    final displayName = session?.user.displayName ?? "Member";

    final pages = [
      _DashboardTab(displayName: displayName),
      const _ScheduleTab(),
      const _BookingsTab(),
      const _CommunityTab(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: "Home",
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
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: "Community",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(GravitySpacing.lg),
        children: [
          Text(
            "Welcome back",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: GravitySpacing.xs),
          Text(
            displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GravityColors.neutral600,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          Row(
            children: [
              Expanded(
                child: GravityButton(
                  label: "Book class",
                  icon: Icons.add_rounded,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: GravitySpacing.sm),
              Expanded(
                child: GravityButton(
                  label: "Check in",
                  icon: Icons.qr_code_rounded,
                  variant: GravityButtonVariant.secondary,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: GravitySpacing.lg),
          _SectionHeader(title: "Upcoming bookings"),
          const SizedBox(height: GravitySpacing.sm),
          const GravityEmptyState(
            icon: Icons.event_available_outlined,
            title: "No upcoming bookings",
            description:
                "Browse the schedule to book your next class.",
          ),
          const SizedBox(height: GravitySpacing.lg),
          _SectionHeader(title: "Membership"),
          const SizedBox(height: GravitySpacing.sm),
          GravityCard(
            padding: const EdgeInsets.all(GravitySpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: GravityColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.card_membership_outlined,
                    color: GravityColors.primary600,
                  ),
                ),
                const SizedBox(width: GravitySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Active membership",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Plan details will appear here once connected.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          _SectionHeader(title: "Notifications"),
          const SizedBox(height: GravitySpacing.sm),
          GravityCard(
            padding: const EdgeInsets.all(GravitySpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: GravityColors.neutral500,
                ),
                const SizedBox(width: GravitySpacing.md),
                Expanded(
                  child: Text(
                    "You're all caught up. Announcements will show here.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: GravityColors.neutral800,
          ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(GravitySpacing.lg),
        children: [
          Text("Schedule", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: GravitySpacing.sm),
          Text(
            "Browse classes and book your next session.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GravityColors.neutral600,
                ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          const GravityEmptyState(
            icon: Icons.calendar_month_outlined,
            title: "Class schedule coming soon",
            description:
                "The calendar view will list available classes with capacity and waitlist status.",
          ),
        ],
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(GravitySpacing.lg),
        children: [
          Text("Bookings", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: GravitySpacing.sm),
          Text(
            "View and manage your upcoming sessions.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GravityColors.neutral600,
                ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          const GravityEmptyState(
            icon: Icons.event_note_outlined,
            title: "No bookings yet",
            description:
                "Confirmed classes and waitlist entries will appear here.",
          ),
        ],
      ),
    );
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(GravitySpacing.lg),
        children: [
          Text("Community", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: GravitySpacing.sm),
          Text(
            "Chat groups and announcements from your gym.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GravityColors.neutral600,
                ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          const GravityEmptyState(
            icon: Icons.forum_outlined,
            title: "Community feed coming soon",
            description:
                "Group chats and announcements will be available in a future update.",
          ),
        ],
      ),
    );
  }
}
