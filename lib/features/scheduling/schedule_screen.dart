import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_exception.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "scheduling_formatters.dart";
import "scheduling_providers.dart";
import "widgets/class_session_card.dart";

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String? _bookingSessionId;
  String? _error;

  Future<void> _bookSession(String sessionId) async {
    setState(() {
      _bookingSessionId = sessionId;
      _error = null;
    });

    try {
      await ref.read(schedulingRepositoryProvider).bookSession(sessionId);
      ref.invalidate(classSessionsProvider);
      ref.invalidate(upcomingBookingsProvider);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _bookingSessionId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(scheduleDayProvider);
    final sessionsAsync = ref.watch(classSessionsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GravitySpacing.lg,
              GravitySpacing.lg,
              GravitySpacing.lg,
              GravitySpacing.sm,
            ),
            child: Text(
              "Schedule",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: GravityColors.gray900,
                    ),
                  ),
                ),
                const Text(
                  "All Studios",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GravityColors.gray600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, size: 16, color: GravityColors.gray600),
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
                      description: error.toString(),
                    ),
                  ],
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        GravityEmptyState(
                          icon: Icons.calendar_month_outlined,
                          title: "No classes scheduled",
                          description:
                              "Check another day or come back later for new sessions.",
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(GravitySpacing.lg),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: GravitySpacing.md),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ClassSessionCard(
                        session: session,
                        isBooking: _bookingSessionId == session.id,
                        onBook: () => _bookSession(session.id),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySlider extends StatelessWidget {
  const _DaySlider({
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final days = List.generate(7, (index) => start.add(Duration(days: index)));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: GravityColors.gray200)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: GravitySpacing.lg,
        vertical: GravitySpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final isSelected = _sameDay(day, selectedDay);
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? GravityColors.primary600 : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    SchedulingFormatters.weekdayShort(day)[0],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : GravityColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    SchedulingFormatters.dayNumber(day),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : GravityColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
