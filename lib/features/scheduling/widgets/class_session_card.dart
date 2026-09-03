import "package:flutter/material.dart";

import "../../../core/theme/design_tokens.dart";
import "../../../core/theme/gravity_palette.dart";
import "../../../core/theme/text_scaling.dart";
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
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(GravityRadii.lg),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GravityRadii.lg),
            border: Border.all(color: context.palette.border),
          ),
          padding: const EdgeInsets.all(GravitySpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: context.scaled(70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SchedulingFormatters.timeOfDay(session.startsAt),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      SchedulingFormatters.durationLabel(session.duration),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: context.scaled(48),
                color: context.palette.border,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.coachLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.textSecondary,
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
                width: context.scaled(82),
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
            ? context.palette.dangerSurface
            : context.palette.accentSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: cancelled || (isFull && !waitlisted)
              ? context.palette.danger
              : context.palette.accentStrong,
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
            ? context.palette.accent
            : context.palette.surfaceMuted,
        foregroundColor: enabled
            ? context.palette.onAccent
            : context.palette.textMuted,
        disabledBackgroundColor: context.palette.surfaceMuted,
        disabledForegroundColor: context.palette.textMuted,
        side: enabled ? null : BorderSide(color: context.palette.border),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
