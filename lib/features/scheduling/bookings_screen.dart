import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/error_messages.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/theme/studio_imagery.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../check_in/check_in_sheet.dart";
import "models/scheduling_models.dart";
import "scheduling_formatters.dart";
import "scheduling_providers.dart";

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key, this.onBrowseSchedule});

  final VoidCallback? onBrowseSchedule;

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String? _cancellingBookingId;

  Future<void> _cancelBooking(UpcomingBooking booking) async {
    final policy = ref.read(bookingPolicyProvider).valueOrNull;
    final lateCancel =
        policy != null && !policy.canCancelFreely(booking.startsAt);
    final confirmed = await GravityFeedback.confirm(
      context: context,
      title: "Cancel booking?",
      message: [
        "Cancel your spot for ${booking.className} on "
            "${SchedulingFormatters.bookingDateLabel(booking.startsAt)}?",
        if (lateCancel)
          "This is inside your studio’s "
              "${policy.cancellationWindowHours}-hour cancellation window, so "
              "it may count as a late cancellation."
        else if (policy != null)
          "Free to cancel up to ${policy.cancellationWindowHours} hours before "
              "the class starts.",
      ].join("\n\n"),
      cancelLabel: "Keep booking",
      confirmLabel: "Cancel booking",
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _cancellingBookingId = booking.bookingId);
    try {
      await ref
          .read(schedulingRepositoryProvider)
          .cancelBooking(booking.bookingId);
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(classSessionsProvider);
      ref.invalidate(weekSessionsProvider);
      ref.invalidate(bookingHistoryProvider);
      if (mounted) {
        GravityFeedback.showSnack(context, message: "Booking cancelled");
      }
    } catch (error) {
      if (mounted) {
        GravityFeedback.showSnack(
          context,
          message: friendlyErrorMessage(
            error,
            fallback: "Couldn’t cancel that booking. Please try again.",
          ),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _cancellingBookingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bookings",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your reserved classes and training history.",
                  style: TextStyle(
                    fontSize: 14,
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const _AttendanceStrip(),
          TabBar(
            labelColor: context.palette.accentStrong,
            unselectedLabelColor: context.palette.textMuted,
            indicatorColor: context.palette.accent,
            tabs: const [
              Tab(text: "Upcoming"),
              Tab(text: "History"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _UpcomingTab(
                  cancellingBookingId: _cancellingBookingId,
                  onCancel: _cancelBooking,
                  onBrowseSchedule: widget.onBrowseSchedule,
                ),
                const _HistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTab extends ConsumerWidget {
  const _UpcomingTab({
    required this.cancellingBookingId,
    required this.onCancel,
    this.onBrowseSchedule,
  });

  final String? cancellingBookingId;
  final Future<void> Function(UpcomingBooking) onCancel;
  final VoidCallback? onBrowseSchedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(upcomingBookingsProvider);
    final policy = ref.watch(bookingPolicyProvider).valueOrNull;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(upcomingBookingsProvider);
              await ref.read(upcomingBookingsProvider.future);
            },
            child: bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  GravityEmptyState(
                    icon: Icons.error_outline,
                    title: "Could not load bookings",
                    description: friendlyErrorMessage(error),
                    actionLabel: "Retry",
                    onAction: () => ref.invalidate(upcomingBookingsProvider),
                  ),
                ],
              ),
              data: (bookings) {
                if (bookings.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      GravityEmptyState(
                        icon: Icons.event_note_outlined,
                        title: "No bookings yet",
                        description:
                            "Browse the schedule to book your next class.",
                        actionLabel: onBrowseSchedule == null
                            ? null
                            : "Browse schedule",
                        onAction: onBrowseSchedule,
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    GravitySpacing.lg,
                    GravitySpacing.lg,
                    GravitySpacing.lg,
                    40,
                  ),
                  itemCount: bookings.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GravitySpacing.md),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _BookingCard(
                      booking: booking,
                      cancelling: cancellingBookingId == booking.bookingId,
                      lateCancel:
                          policy != null &&
                          !policy.canCancelFreely(booking.startsAt),
                      cancellationWindowHours: policy?.cancellationWindowHours,
                      onCancel: () => onCancel(booking),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceStrip extends ConsumerWidget {
  const _AttendanceStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(attendanceSummaryProvider).valueOrNull;
    if (summary == null || summary.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: context.palette.accentSurface,
          borderRadius: BorderRadius.circular(GravityRadii.lg),
        ),
        child: Row(
          children: [
            _Stat(value: "${summary.totalVisits}", label: "visits"),
            _Stat(value: "${summary.visitsThisMonth}", label: "this month"),
            _Stat(value: "${summary.averagePerWeek}", label: "per week"),
            _Stat(value: "${summary.longestStreakDays}", label: "best streak"),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: "$value $label",
        excludeSemantics: true,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.palette.accentStrong,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.palette.accentStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(bookingHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(bookingHistoryProvider);
        ref.invalidate(attendanceSummaryProvider);
        await ref.read(bookingHistoryProvider.future);
      },
      child: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            GravityEmptyState(
              icon: Icons.error_outline,
              title: "Could not load history",
              description: friendlyErrorMessage(error),
              actionLabel: "Retry",
              onAction: () => ref.invalidate(bookingHistoryProvider),
            ),
          ],
        ),
        data: (page) {
          // Upcoming bookings live on the other tab.
          final past = page.items
              .where((entry) => entry.isCompleted || entry.isCancelled)
              .toList();
          if (past.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                GravityEmptyState(
                  icon: Icons.history_rounded,
                  title: "No history yet",
                  description:
                      "Classes you attend will show up here so you can track "
                      "your training over time.",
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              GravitySpacing.lg,
              GravitySpacing.lg,
              GravitySpacing.lg,
              40,
            ),
            itemCount: past.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _HistoryRow(entry: past[index]),
          );
        },
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final BookingHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final cancelled = entry.isCancelled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cancelled
                  ? context.palette.dangerSurface
                  : context.palette.accentSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              cancelled ? Icons.close_rounded : Icons.check_rounded,
              size: 18,
              color: cancelled
                  ? context.palette.danger
                  : context.palette.accentStrong,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.className,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    SchedulingFormatters.bookingDateLabel(entry.startsAt),
                    SchedulingFormatters.timeOfDay(entry.startsAt),
                    ?entry.coachName,
                  ].join(" · "),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            cancelled ? "Cancelled" : "Attended",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cancelled
                  ? context.palette.danger
                  : context.palette.accentStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.cancelling,
    required this.onCancel,
    this.lateCancel = false,
    this.cancellationWindowHours,
  });

  final UpcomingBooking booking;
  final bool cancelling;
  final VoidCallback onCancel;
  final bool lateCancel;
  final int? cancellationWindowHours;

  @override
  Widget build(BuildContext context) {
    final cancelled = booking.isCancelledSession;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.asset(
                    StudioImagery.forClassName(booking.className),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: Color(0xFF111827)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.className,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.palette.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cancelled
                                ? context.palette.dangerSurface
                                : context.palette.accentSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cancelled ? "Cancelled" : "Confirmed",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cancelled
                                  ? context.palette.danger
                                  : context.palette.accentStrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${SchedulingFormatters.bookingDateLabel(booking.startsAt)} · "
                      "${SchedulingFormatters.timeOfDay(booking.startsAt)} · "
                      "${SchedulingFormatters.durationLabel(booking.duration)}",
                      style: TextStyle(
                        fontSize: 13,
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (booking.coachName != null) booking.coachName,
                        if (booking.locationName != null) booking.locationName,
                      ].join(" · "),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (cancelled) ...[
            const SizedBox(height: GravitySpacing.sm),
            Text(
              "This class was cancelled by the studio.",
              style: TextStyle(color: context.palette.danger, fontSize: 13),
            ),
          ] else if (lateCancel && cancellationWindowHours != null) ...[
            const SizedBox(height: GravitySpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: context.palette.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Inside the ${cancellationWindowHours}h cancellation window.",
                    style: TextStyle(
                      fontSize: 12,
                      color: context.palette.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: GravitySpacing.md),
          Row(
            children: [
              Expanded(
                child: GravityButton(
                  label: "Check in",
                  icon: Icons.qr_code_2_rounded,
                  variant: GravityButtonVariant.secondary,
                  onPressed: cancelled ? null : () => showCheckInSheet(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GravityButton(
                  label: "Cancel",
                  variant: GravityButtonVariant.destructive,
                  isLoading: cancelling,
                  onPressed: cancelled ? null : onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
