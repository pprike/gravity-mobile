import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_exception.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_card.dart";
import "../../core/widgets/gravity_empty_state.dart";
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
  String? _error;

  Future<void> _cancelBooking(UpcomingBooking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel booking?"),
        content: Text(
          "Cancel your spot for ${booking.className} on "
          "${SchedulingFormatters.bookingDateLabel(booking.startsAt)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep booking"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Cancel booking"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _cancellingBookingId = booking.bookingId;
      _error = null;
    });

    try {
      await ref
          .read(schedulingRepositoryProvider)
          .cancelBooking(booking.bookingId);
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(classSessionsProvider);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = error.toString());
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GravitySpacing.lg,
            GravitySpacing.lg,
            GravitySpacing.lg,
            GravitySpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bookings",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: GravitySpacing.sm),
              Text(
                "View and manage your upcoming sessions.",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: GravityColors.gray600),
              ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GravitySpacing.lg),
            child: Text(
              _error!,
              style: const TextStyle(color: GravityColors.danger600),
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
                    final booking = bookings[index];
                    final isCancelledSession =
                        booking.sessionStatus == "cancelled";
                    return GravityCard(
                      padding: const EdgeInsets.all(GravitySpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.className,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${SchedulingFormatters.bookingDateLabel(booking.startsAt)} · "
                            "${SchedulingFormatters.timeOfDay(booking.startsAt)}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (isCancelledSession) ...[
                            const SizedBox(height: GravitySpacing.sm),
                            const Text(
                              "This class was cancelled by the studio.",
                              style: TextStyle(color: GravityColors.danger600),
                            ),
                          ],
                          const SizedBox(height: GravitySpacing.md),
                          GravityButton(
                            label: "Cancel booking",
                            variant: GravityButtonVariant.secondary,
                            isLoading:
                                _cancellingBookingId == booking.bookingId,
                            onPressed: isCancelledSession
                                ? null
                                : () => _cancelBooking(booking),
                            fullWidth: true,
                          ),
                        ],
                      ),
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
