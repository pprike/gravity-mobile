import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../../core/widgets/gravity_section_header.dart";
import "../announcements/announcement_providers.dart";
import "../check_in/check_in_sheet.dart";
import "../profile/profile_controller.dart";
import "../scheduling/class_detail_sheet.dart";
import "../scheduling/models/scheduling_models.dart";
import "../scheduling/scheduling_formatters.dart";
import "../scheduling/scheduling_providers.dart";

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.onBookClass,
    required this.onViewBookings,
    required this.onOpenCommunity,
  });

  final VoidCallback onBookClass;
  final VoidCallback onViewBookings;
  final VoidCallback onOpenCommunity;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(upcomingBookingsProvider);
    ref.invalidate(weekSessionsProvider);
    ref.invalidate(announcementsProvider);
    final session = ref.read(authSessionProvider).value;
    if (session != null) {
      ref.invalidate(memberSubscriptionProvider(session.user.id));
    }
    await Future.wait([
      ref.read(upcomingBookingsProvider.future),
      ref.read(weekSessionsProvider.future),
      ref.read(announcementsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    final displayName = session?.user.displayName.split(" ").first ?? "there";
    final profile = session == null
        ? null
        : ref.watch(profileControllerProvider(session.user.id)).valueOrNull;
    final avatarUrl = _resolveAvatar(ref, profile?.member?.avatarUrl);
    final bookingsAsync = ref.watch(upcomingBookingsProvider);
    final weekAsync = ref.watch(weekSessionsProvider);
    final announcementsAsync = ref.watch(announcementsProvider);
    final subscription = session == null
        ? null
        : ref.watch(memberSubscriptionProvider(session.user.id)).valueOrNull;
    final streak = bookingsAsync.valueOrNull?.length ?? 0;

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        children: [
          _WelcomeRow(
            displayName: displayName,
            avatarUrl: avatarUrl,
            streak: streak,
          ),
          const SizedBox(height: GravitySpacing.md),
          bookingsAsync.when(
            loading: () => const _HeroPlaceholder(),
            error: (error, _) => GravityEmptyState(
              icon: Icons.error_outline,
              title: "Couldn't load your next class",
              description: error.toString(),
              actionLabel: "Retry",
              onAction: () => ref.invalidate(upcomingBookingsProvider),
            ),
            data: (bookings) {
              if (bookings.isEmpty) {
                return _EmptyHero(onBookClass: onBookClass);
              }
              return _HeroBookingCard(
                booking: bookings.first,
                onView: onViewBookings,
              );
            },
          ),
          const SizedBox(height: GravitySpacing.lg),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_rounded,
                  label: "Book class",
                  filled: true,
                  onTap: onBookClass,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.qr_code_2_rounded,
                  label: "Check in",
                  filled: false,
                  onTap: () => showCheckInSheet(context),
                ),
              ),
            ],
          ),
          if (subscription?.planName != null) ...[
            const SizedBox(height: GravitySpacing.lg),
            _MembershipCard(
              planName: subscription!.planName!,
              status: subscription.status ?? "active",
              renewalLabel: subscription.renewalLabel,
            ),
          ],
          const SizedBox(height: GravitySpacing.lg),
          GravitySectionHeader(
            title: "Popular Classes This Week",
            actionLabel: "See All",
            onAction: onBookClass,
          ),
          const SizedBox(height: GravitySpacing.sm),
          weekAsync.when(
            loading: () => const SizedBox(
              height: 196,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => GravityEmptyState(
              icon: Icons.error_outline,
              title: "Couldn't load classes",
              description: error.toString(),
              actionLabel: "Retry",
              onAction: () => ref.invalidate(weekSessionsProvider),
            ),
            data: (sessions) {
              final upcoming = sessions
                  .where(
                    (item) =>
                        item.startsAt.isAfter(DateTime.now()) &&
                        !item.isCancelled,
                  )
                  .take(8)
                  .toList();
              if (upcoming.isEmpty) {
                return GravityEmptyState(
                  icon: Icons.fitness_center_outlined,
                  title: "No classes this week",
                  description:
                      "New sessions will appear here as they’re scheduled.",
                  actionLabel: "Browse schedule",
                  onAction: onBookClass,
                );
              }
              return SizedBox(
                height: 208,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcoming.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = upcoming[index];
                    return _PopularClassCard(
                      session: item,
                      onTap: () => _openSession(context, ref, item),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: GravitySpacing.lg),
          GravitySectionHeader(
            title: "Studio updates",
            actionLabel: "See all",
            onAction: onOpenCommunity,
          ),
          const SizedBox(height: GravitySpacing.sm),
          announcementsAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => GravityEmptyState(
              icon: Icons.error_outline,
              title: "Couldn't load updates",
              description: error.toString(),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const GravityEmptyState(
                  icon: Icons.campaign_outlined,
                  title: "You're all caught up",
                  description: "Announcements from your studio will show here.",
                );
              }
              final latest = items.first;
              return GestureDetector(
                onTap: onOpenCommunity,
                child: Container(
                  padding: const EdgeInsets.all(GravitySpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(GravityRadii.lg),
                    border: Border.all(color: GravityColors.gray200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: GravityColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        latest.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: GravityColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openSession(
    BuildContext context,
    WidgetRef ref,
    ClassSession session,
  ) async {
    await showClassDetailSheet(
      context,
      session: session,
      onBook: () => _book(context, ref, session),
      onWaitlist: () => _waitlist(context, ref, session),
    );
  }

  Future<void> _book(
    BuildContext context,
    WidgetRef ref,
    ClassSession session,
  ) async {
    await ref.read(schedulingRepositoryProvider).bookSession(session.id);
    _invalidateSchedule(ref);
    if (context.mounted) {
      GravityFeedback.showSnack(
        context,
        message: "You're booked for ${session.name}",
      );
    }
  }

  Future<void> _waitlist(
    BuildContext context,
    WidgetRef ref,
    ClassSession session,
  ) async {
    final repository = ref.read(schedulingRepositoryProvider);
    if (session.waitlistedByMe) {
      await repository.leaveWaitlist(session.id);
      if (context.mounted) {
        GravityFeedback.showSnack(context, message: "Left the waitlist");
      }
    } else {
      await repository.joinWaitlist(session.id);
      if (context.mounted) {
        GravityFeedback.showSnack(context, message: "You're on the waitlist");
      }
    }
    _invalidateSchedule(ref);
  }

  void _invalidateSchedule(WidgetRef ref) {
    ref.invalidate(classSessionsProvider);
    ref.invalidate(upcomingBookingsProvider);
    ref.invalidate(weekSessionsProvider);
  }

  String _resolveAvatar(WidgetRef ref, String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return "";
    if (avatarUrl.startsWith("http")) return avatarUrl;
    return "${ref.read(appConfigProvider).apiBaseUrl}$avatarUrl";
  }
}

class _WelcomeRow extends StatelessWidget {
  const _WelcomeRow({
    required this.displayName,
    required this.avatarUrl,
    required this.streak,
  });

  final String displayName;
  final String avatarUrl;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: GravityColors.primary50,
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl.isEmpty
              ? Text(
                  displayName.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: GravityColors.primary700,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $displayName",
                style: const TextStyle(
                  fontSize: 14,
                  color: GravityColors.gray600,
                ),
              ),
              const Text(
                "Peak Level Performance",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GravityColors.gray900,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: GravityColors.primary50,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 16,
                color: GravityColors.primary600,
              ),
              const SizedBox(width: 4),
              Text(
                "$streak",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GravityColors.primary600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.planName,
    required this.status,
    this.renewalLabel,
  });

  final String planName;
  final String status;
  final String? renewalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        border: Border.all(color: GravityColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: GravityColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: GravityColors.primary700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: GravityColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    status[0].toUpperCase() + status.substring(1),
                    if (renewalLabel != null) renewalLabel,
                  ].join(" · "),
                  style: const TextStyle(
                    fontSize: 12,
                    color: GravityColors.gray500,
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

class _HeroBookingCard extends StatelessWidget {
  const _HeroBookingCard({required this.booking, required this.onView});

  final UpcomingBooking booking;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GravityRadii.xl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF111827)],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: GravityColors.primary600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "CONFIRMED",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  SchedulingFormatters.heroTimeLabel(booking.startsAt),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              booking.className,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.coachName ?? "Your class",
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
                Text(
                  booking.locationName ??
                      SchedulingFormatters.durationLabel(booking.duration),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GravityColors.mint100,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero({required this.onBookClass});

  final VoidCallback onBookClass;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBookClass,
      child: Container(
        height: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GravityRadii.xl),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF115E59)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your next class is waiting",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Browse the schedule and reserve a spot in one tap.",
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        color: GravityColors.gray200,
        borderRadius: BorderRadius.circular(GravityRadii.xl),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? GravityColors.primary600 : Colors.white,
      borderRadius: BorderRadius.circular(GravityRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GravityRadii.button),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GravityRadii.button),
            border: filled ? null : Border.all(color: GravityColors.gray200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: filled ? Colors.white : GravityColors.gray900,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : GravityColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularClassCard extends StatelessWidget {
  const _PopularClassCard({required this.session, required this.onTap});

  final ClassSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GravityRadii.lg),
          border: Border.all(color: GravityColors.gray200),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 104,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    GravityColors.primary600.withValues(alpha: 0.85),
                    const Color(0xFF111827),
                  ],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(10),
              child: Text(
                session.isFull ? "Waitlist" : "${session.spotsLeft} spots",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              session.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: GravityColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              SchedulingFormatters.popularClassMeta(
                session.startsAt,
                session.duration,
              ),
              style: const TextStyle(
                fontSize: 12,
                color: GravityColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
