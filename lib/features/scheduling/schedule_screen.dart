import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/error_messages.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../check_in/check_in_sheet.dart";
import "class_detail_sheet.dart";
import "models/scheduling_models.dart";
import "scheduling_formatters.dart";
import "scheduling_providers.dart";
import "widgets/class_session_card.dart";

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String? _busySessionId;

  Future<void> _bookSession(ClassSession session) async {
    setState(() => _busySessionId = session.id);
    try {
      await ref.read(schedulingRepositoryProvider).bookSession(session.id);
      _invalidate();
      if (mounted) {
        await GravityFeedback.showBookingConfirmed(
          context: context,
          className: session.name,
          onCheckIn: () => showCheckInSheet(context),
        );
      }
    } catch (error) {
      if (mounted) {
        GravityFeedback.showSnack(
          context,
          message: friendlyErrorMessage(
            error,
            fallback: "Couldn’t book that class. Please try again.",
          ),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busySessionId = null);
    }
  }

  Future<void> _toggleWaitlist(ClassSession session) async {
    setState(() => _busySessionId = session.id);
    try {
      final repository = ref.read(schedulingRepositoryProvider);
      if (session.waitlistedByMe) {
        await repository.leaveWaitlist(session.id);
        if (mounted) {
          GravityFeedback.showSnack(context, message: "Left the waitlist");
        }
      } else {
        await repository.joinWaitlist(session.id);
        if (mounted) {
          GravityFeedback.showSnack(
            context,
            message: "You're on the waitlist for ${session.name}",
          );
        }
      }
      _invalidate();
    } catch (error) {
      if (mounted) {
        GravityFeedback.showSnack(
          context,
          message: friendlyErrorMessage(
            error,
            fallback: "Couldn’t update the waitlist. Please try again.",
          ),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busySessionId = null);
    }
  }

  void _invalidate() {
    ref.invalidate(classSessionsProvider);
    ref.invalidate(upcomingBookingsProvider);
    ref.invalidate(weekSessionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(scheduleDayProvider);
    final sessionsAsync = ref.watch(classSessionsProvider);
    final locations =
        ref.watch(studioLocationsProvider).valueOrNull ?? const [];
    final selectedLocationId = ref.watch(scheduleLocationIdProvider);
    final selectedLocationName = selectedLocationId == null
        ? "All Studios"
        : locations
              .where((item) => item.id == selectedLocationId)
              .map((item) => item.name)
              .firstWhere((_) => true, orElse: () => "All Studios");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DaySlider(
          selectedDay: selectedDay,
          onDaySelected: (day) =>
              ref.read(scheduleDayProvider.notifier).state = day,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GravitySpacing.lg,
            GravitySpacing.md,
            GravitySpacing.lg,
            GravitySpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  SchedulingFormatters.daySectionTitle(selectedDay),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.palette.textPrimary,
                  ),
                ),
              ),
              if (locations.isNotEmpty)
                PopupMenuButton<String?>(
                  onSelected: (value) =>
                      ref.read(scheduleLocationIdProvider.notifier).state =
                          value,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text("All Studios"),
                    ),
                    for (final location in locations)
                      PopupMenuItem(
                        value: location.id,
                        child: Text(location.name),
                      ),
                  ],
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      minWidth: 44,
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedLocationName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.palette.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.expand_more,
                          size: 16,
                          color: context.palette.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(classSessionsProvider);
              await ref.read(classSessionsProvider.future);
            },
            child: sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  GravityEmptyState(
                    icon: Icons.error_outline,
                    title: "Could not load schedule",
                    description: friendlyErrorMessage(error),
                    actionLabel: "Retry",
                    onAction: () => ref.invalidate(classSessionsProvider),
                  ),
                ],
              ),
              data: (sessions) {
                if (sessions.isEmpty) {
                  final now = DateTime.now();
                  final isToday =
                      selectedDay.year == now.year &&
                      selectedDay.month == now.month &&
                      selectedDay.day == now.day;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      GravityEmptyState(
                        icon: Icons.calendar_month_outlined,
                        title: isToday
                            ? "No classes scheduled"
                            : "Nothing on this day",
                        description: isToday
                            ? "Check another day or come back later for new sessions."
                            : "Try another day — today might still have spots.",
                        actionLabel: isToday ? null : "Jump to today",
                        onAction: isToday
                            ? null
                            : () {
                                ref.read(scheduleDayProvider.notifier).state =
                                    DateTime(now.year, now.month, now.day);
                              },
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
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: GravitySpacing.md),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return ClassSessionCard(
                      session: session,
                      isBusy: _busySessionId == session.id,
                      onBook: () => _bookSession(session),
                      onWaitlist: () => _toggleWaitlist(session),
                      onOpen: () => showClassDetailSheet(
                        context,
                        session: session,
                        isBusy: _busySessionId == session.id,
                        onBook: () => _bookSession(session),
                        onWaitlist: () => _toggleWaitlist(session),
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

class _DaySlider extends StatelessWidget {
  const _DaySlider({required this.selectedDay, required this.onDaySelected});

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final days = List.generate(7, (index) => start.add(Duration(days: index)));

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(bottom: BorderSide(color: context.palette.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: GravitySpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GravitySpacing.md),
        child: Row(
          children: days.map((day) {
            final isSelected = _sameDay(day, selectedDay);
            return Semantics(
              button: true,
              selected: isSelected,
              label: SchedulingFormatters.daySectionTitle(day),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: isSelected
                      ? context.palette.accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onDaySelected(day),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            SchedulingFormatters.weekdayShort(day),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? context.palette.onAccent
                                  : context.palette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            SchedulingFormatters.dayNumber(day),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? context.palette.onAccent
                                  : context.palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: 4,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _sameDay(day, start) && !isSelected
                                    ? context.palette.accent
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
