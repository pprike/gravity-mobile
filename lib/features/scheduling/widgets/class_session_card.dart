import "package:flutter/material.dart";

import "../../../core/theme/design_tokens.dart";
import "../models/scheduling_models.dart";
import "../scheduling_formatters.dart";

class ClassSessionCard extends StatelessWidget {
  const ClassSessionCard({
    super.key,
    required this.session,
    this.onBook,
    this.onWaitlist,
    this.onOpen,
    this.isBusy = false,
  });

  final ClassSession session;
  final VoidCallback? onBook;
  final VoidCallback? onWaitlist;
  final VoidCallback? onOpen;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final isBooked = session.bookedByMe;
    final isWaitlisted = session.waitlistedByMe;
    final isFull = session.isFull && !isBooked;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(GravityRadii.lg),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GravityRadii.lg),
            border: Border.all(color: GravityColors.gray200),
          ),
          padding: const EdgeInsets.all(GravitySpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SchedulingFormatters.timeOfDay(session.startsAt),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GravityColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      SchedulingFormatters.durationLabel(session.duration),
                      style: const TextStyle(
                        fontSize: 11,
                        color: GravityColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: GravityColors.gray200,
                margin: const EdgeInsets.symmetric(
                  horizontal: GravitySpacing.sm,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: GravityColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.coachLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: GravityColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SpotsTag(
                      isFull: isFull,
                      spotsLeft: session.spotsLeft,
                      waitlistCount: session.waitlistCount,
                      waitlisted: isWaitlisted,
                      cancelled: session.isCancelled,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GravitySpacing.sm),
              SizedBox(
                width: 82,
                child: _ActionButton(
                  isBooked: isBooked,
                  isFull: isFull,
                  isWaitlisted: isWaitlisted,
                  isCancelled: session.isCancelled,
                  isLoading: isBusy,
                  onPressed: session.isCancelled || isBooked
                      ? null
                      : isWaitlisted || isFull
                      ? onWaitlist
                      : onBook,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotsTag extends StatelessWidget {
  const _SpotsTag({
    required this.isFull,
    required this.spotsLeft,
    required this.waitlistCount,
    required this.waitlisted,
    required this.cancelled,
  });

  final bool isFull;
  final int spotsLeft;
  final int waitlistCount;
  final bool waitlisted;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final label = cancelled
        ? "Cancelled"
        : waitlisted
        ? "On waitlist"
        : isFull
        ? (waitlistCount > 0 ? "Waitlist ($waitlistCount)" : "Fully Booked")
        : "$spotsLeft spots left";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cancelled || (isFull && !waitlisted)
            ? GravityColors.danger50
            : GravityColors.primary50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: cancelled || (isFull && !waitlisted)
              ? GravityColors.danger600
              : GravityColors.primary600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isBooked,
    required this.isFull,
    required this.isWaitlisted,
    required this.isCancelled,
    required this.isLoading,
    this.onPressed,
  });

  final bool isBooked;
  final bool isFull;
  final bool isWaitlisted;
  final bool isCancelled;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final label = isCancelled
        ? "Closed"
        : isBooked
        ? "Booked"
        : isWaitlisted
        ? "Leave"
        : isFull
        ? "Waitlist"
        : "Book";
    final enabled = onPressed != null && !isBooked && !isCancelled;

    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        backgroundColor: enabled
            ? GravityColors.primary600
            : GravityColors.neutral50,
        foregroundColor: enabled ? Colors.white : GravityColors.gray400,
        disabledBackgroundColor: GravityColors.neutral50,
        disabledForegroundColor: GravityColors.gray400,
        side: enabled ? null : const BorderSide(color: GravityColors.gray200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
