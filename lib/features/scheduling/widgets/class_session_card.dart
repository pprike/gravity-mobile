import "package:flutter/material.dart";

import "../../../core/theme/design_tokens.dart";
import "../models/scheduling_models.dart";
import "../scheduling_formatters.dart";

class ClassSessionCard extends StatelessWidget {
  const ClassSessionCard({
    super.key,
    required this.session,
    required this.onBook,
    this.isBooking = false,
  });

  final ClassSession session;
  final VoidCallback? onBook;
  final bool isBooking;

  @override
  Widget build(BuildContext context) {
    final isBooked = session.bookedByMe;
    final isFull = session.isFull && !isBooked;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            margin: const EdgeInsets.symmetric(horizontal: GravitySpacing.sm),
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
                  "Coach",
                  style: const TextStyle(
                    fontSize: 12,
                    color: GravityColors.gray600,
                  ),
                ),
                const SizedBox(height: 8),
                _SpotsTag(
                  isFull: isFull,
                  spotsLeft: session.spotsLeft,
                ),
              ],
            ),
          ),
          const SizedBox(width: GravitySpacing.sm),
          SizedBox(
            width: 76,
            child: _BookActionButton(
              isBooked: isBooked,
              isFull: isFull,
              isLoading: isBooking,
              onPressed: isBooked || isFull ? null : onBook,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotsTag extends StatelessWidget {
  const _SpotsTag({required this.isFull, required this.spotsLeft});

  final bool isFull;
  final int spotsLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFull ? GravityColors.danger50 : GravityColors.primary50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isFull ? "Fully Booked" : "$spotsLeft spots left",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isFull ? GravityColors.danger600 : GravityColors.primary600,
        ),
      ),
    );
  }
}

class _BookActionButton extends StatelessWidget {
  const _BookActionButton({
    required this.isBooked,
    required this.isFull,
    required this.isLoading,
    this.onPressed,
  });

  final bool isBooked;
  final bool isFull;
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

    final label = isBooked ? "Booked" : "Book";
    final enabled = onPressed != null;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor:
            enabled ? GravityColors.primary600 : GravityColors.neutral50,
        foregroundColor: enabled ? Colors.white : GravityColors.gray400,
        side: enabled ? null : const BorderSide(color: GravityColors.gray200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
