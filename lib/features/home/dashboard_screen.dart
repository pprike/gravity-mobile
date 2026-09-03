import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/error_messages.dart";
import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/theme/text_scaling.dart";
import "../../core/theme/studio_imagery.dart";
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
    final avatarUrl = _resolveAvatar(
      ref,
      profile?.member?.avatarUrl,
      demo: session?.isDemo == true,
    );
    final bookingsAsync = ref.watch(upcomingBookingsProvider);
    final weekAsync = ref.watch(weekSessionsProvider);
    final announcementsAsync = ref.watch(announcementsProvider);
    final subscription = session == null
        ? null
        : ref.watch(memberSubscriptionProvider(session.user.id)).valueOrNull;
    final bookedCount = bookingsAsync.valueOrNull?.length ?? 0;

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        children: [
          _WelcomeRow(
            displayName: displayName,
            avatarUrl: avatarUrl,
            bookedCount: bookedCount,
            planName: subscription?.planName,
            onViewBookings: onViewBookings,
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 14),
          bookingsAsync.when(
            loading: () => const _HeroPlaceholder(),
            error: (error, _) => GravityEmptyState(
              icon: Icons.error_outline,
              title: "Couldn't load your next class",
              description: friendlyErrorMessage(error),
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
          GravitySectionHeader(
            title: "This week",
            actionLabel: "See All",
            onAction: onBookClass,
          ),
          const SizedBox(height: GravitySpacing.sm),
          weekAsync.when(
            loading: () => SizedBox(
              height: context.scaled(228),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => GravityEmptyState(
              icon: Icons.error_outline,
              title: "Couldn't load classes",
              description: friendlyErrorMessage(error),
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
                height: context.scaledMedia(200),
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
            title: "From the studio",
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
              description: friendlyErrorMessage(error),
              actionLabel: "Retry",
              onAction: () => ref.invalidate(announcementsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No studio updates right now.",
                    style: TextStyle(
                      fontSize: 13,
                      color: context.palette.textSecondary,
                    ),
                  ),
                );
              }
              final latest = items.first;
              return Semantics(
                button: true,
                label: "Studio update: ${latest.title}",
                child: Material(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(GravityRadii.lg),
                  child: InkWell(
                    onTap: onOpenCommunity,
                    borderRadius: BorderRadius.circular(GravityRadii.lg),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(GravityRadii.lg),
                        border: Border.all(color: context.palette.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 48,
                            decoration: BoxDecoration(
                              color: context.palette.accent,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  latest.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  latest.body,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: context.palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
      await GravityFeedback.showBookingConfirmed(
        context: context,
        className: session.name,
        onCheckIn: () => showCheckInSheet(context),
      );
    }
  }

  Future<void> _waitlist(
    BuildContext context,
    WidgetRef ref,
    ClassSession session,
  ) async {
    final repository = ref.read(schedulingRepositoryProvider);
    final leaving = session.waitlistedByMe;
    if (leaving) {
      await repository.leaveWaitlist(session.id);
    } else {
      await repository.joinWaitlist(session.id);
    }
    _invalidateSchedule(ref);
    if (context.mounted) {
      GravityFeedback.showSnack(
        context,
        message: leaving ? "Left the waitlist" : "You're on the waitlist",
      );
    }
  }

  void _invalidateSchedule(WidgetRef ref) {
    ref.invalidate(classSessionsProvider);
    ref.invalidate(upcomingBookingsProvider);
    ref.invalidate(weekSessionsProvider);
  }

  String _resolveAvatar(WidgetRef ref, String? avatarUrl, {bool demo = false}) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith("http")) return avatarUrl;
      return "${ref.read(appConfigProvider).apiBaseUrl}$avatarUrl";
    }
    return demo ? StudioImagery.memberAvatar : "";
  }
}

class _WelcomeRow extends StatelessWidget {
  const _WelcomeRow({
    required this.displayName,
    required this.avatarUrl,
    required this.bookedCount,
    required this.onViewBookings,
    this.planName,
  });

  final String displayName;
  final String avatarUrl;
  final int bookedCount;
  final String? planName;
  final VoidCallback onViewBookings;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = SchedulingFormatters.greeting(now);
    ImageProvider? image;
    if (avatarUrl.isNotEmpty) {
      image = avatarUrl.startsWith("assets/")
          ? AssetImage(avatarUrl)
          : NetworkImage(avatarUrl);
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: context.palette.accentSurface,
          backgroundImage: image,
          child: image == null
              ? Text(
                  displayName.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.palette.accentStrong,
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
                "$greeting,",
                style: TextStyle(
                  fontSize: 13,
                  color: context.palette.textSecondary,
                ),
              ),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                [
                  SchedulingFormatters.longDateLabel(now),
                  if (planName != null) planName,
                ].join(" · "),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: "$bookedCount classes booked. View bookings.",
          child: Material(
            color: context.palette.accentSurface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onViewBookings,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$bookedCount",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.palette.accentStrong,
                        ),
                      ),
                      Text(
                        "booked",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.palette.accentStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBookingCard extends StatelessWidget {
  const _HeroBookingCard({required this.booking, required this.onView});

  final UpcomingBooking booking;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          "Next class: ${booking.className}, "
          "${SchedulingFormatters.heroTimeLabel(booking.startsAt)}. "
          "View your bookings.",
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GravityRadii.xl),
        // A minimum rather than a fixed height: the text has to be able to
        // grow the card at large accessibility font sizes.
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.scaledMedia(220)),
          child: Stack(
            children: [
              Positioned.fill(
                child: _KenBurnsPhoto(
                  asset: StudioImagery.forClassName(booking.className),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66111827), Color(0xE6111827)],
                    ),
                  ),
                ),
              ),
              Padding(
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
                            color: context.palette.accent,
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            SchedulingFormatters.heroTimeLabel(
                              booking.startsAt,
                            ),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundImage: AssetImage(StudioImagery.coach),
                          backgroundColor: Colors.white24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.coachName ?? "Your class",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            booking.locationName ??
                                SchedulingFormatters.durationLabel(
                                  booking.duration,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: onView, child: const SizedBox.expand()),
                ),
              ),
            ],
          ),
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
    return Semantics(
      button: true,
      label: "Nothing booked yet. Browse the schedule.",
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GravityRadii.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.scaledMedia(188)),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  StudioImagery.hero,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: Color(0xFF0F766E)),
                ),
              ),
              const Positioned.fill(
                child: ColoredBox(color: Color(0x990F766E)),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nothing booked yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Pick a class from the schedule and reserve your spot in one tap.",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Browse schedule →",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onBookClass,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KenBurnsPhoto extends StatelessWidget {
  const _KenBurnsPhoto({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final photo = Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: Color(0xFF111827)),
    );
    if (MediaQuery.disableAnimationsOf(context)) return photo;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.08, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: photo,
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.scaledMedia(220),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
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
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? context.palette.accent : context.palette.surface,
        borderRadius: BorderRadius.circular(GravityRadii.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GravityRadii.button),
          child: Container(
            constraints: BoxConstraints(minHeight: context.scaled(48)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GravityRadii.button),
              border: filled ? null : Border.all(color: context.palette.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: filled
                      ? context.palette.onAccent
                      : context.palette.textPrimary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: filled
                          ? context.palette.onAccent
                          : context.palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
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
    return Semantics(
      button: true,
      label:
          "${session.name}, "
          "${SchedulingFormatters.popularClassMeta(session.startsAt, session.duration)}, "
          "${session.isFull ? "full, waitlist available" : "${session.spotsLeft} spots left"}",
      child: Container(
        width: context.scaled(228),
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: BorderRadius.circular(GravityRadii.lg),
          border: Border.all(color: context.palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 124,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        StudioImagery.forClassName(session.name),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(color: Color(0xFF111827)),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            session.isFull
                                ? "Waitlist"
                                : "${session.spotsLeft} spots",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            SchedulingFormatters.popularClassMeta(
                              session.startsAt,
                              session.duration,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap, child: const SizedBox.expand()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
