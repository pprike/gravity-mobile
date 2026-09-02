import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_exception.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../check_in/check_in_sheet.dart";
import "models/scheduling_models.dart";
import "scheduling_formatters.dart";
import "scheduling_providers.dart";

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String? _cancellingBookingId;

  Future<void> _cancelBooking(UpcomingBooking booking) async {
    final confirmed = await GravityFeedback.confirm(
      context: context,
      title: "Cancel booking?",
      message:
          "Cancel your spot for ${booking.className} on "
          "${SchedulingFormatters.bookingDateLabel(booking.startsAt)}?",
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
      if (mounted) {
        GravityFeedback.showSnack(context, message: "Booking cancelled");
      }
    } on ApiException catch (error) {
      if (mounted) {
        GravityFeedback.showSnack(context, message: error.message, error: true);
      }
    } catch (error) {
      if (mounted) {
        GravityFeedback.showSnack(
          context,
          message: error.toString(),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _cancellingBookingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(upcomingBookingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bookings",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: GravityColors.gray900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Upcoming sessions you’ve reserved.",
                style: TextStyle(fontSize: 14, color: GravityColors.gray600),
              ),
            ],
          ),
        ),
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
                    description: error.toString(),
                    actionLabel: "Retry",
                    onAction: () => ref.invalidate(upcomingBookingsProvider),
                  ),
                ],
              ),
              data: (bookings) {
                if (bookings.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      GravityEmptyState(
                        icon: Icons.event_note_outlined,
                        title: "No bookings yet",
                        description:
                            "Browse the schedule to book your next class.",
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(GravitySpacing.lg),
                  itemCount: bookings.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GravitySpacing.md),
                  itemBuilder: (context, index) {
                    return _BookingCard(
                      booking: bookings[index],
                      cancelling:
                          _cancellingBookingId == bookings[index].bookingId,
                      onCancel: () => _cancelBooking(bookings[index]),
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.cancelling,
    required this.onCancel,
  });

  final UpcomingBooking booking;
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final cancelled = booking.isCancelledSession;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        border: Border.all(color: GravityColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.className,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GravityColors.gray900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cancelled
                      ? GravityColors.danger50
                      : GravityColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cancelled ? "Cancelled" : "Confirmed",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cancelled
                        ? GravityColors.danger600
                        : GravityColors.primary700,
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
            style: const TextStyle(fontSize: 13, color: GravityColors.gray600),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (booking.coachName != null) booking.coachName,
              if (booking.locationName != null) booking.locationName,
            ].join(" · "),
            style: const TextStyle(fontSize: 13, color: GravityColors.gray500),
          ),
          if (cancelled) ...[
            const SizedBox(height: GravitySpacing.sm),
            const Text(
              "This class was cancelled by the studio.",
              style: TextStyle(color: GravityColors.danger600, fontSize: 13),
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
