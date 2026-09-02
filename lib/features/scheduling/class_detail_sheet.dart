import "package:flutter/material.dart";

import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_button.dart";
import "models/scheduling_models.dart";
import "scheduling_formatters.dart";

Future<void> showClassDetailSheet(
  BuildContext context, {
  required ClassSession session,
  required Future<void> Function() onBook,
  required Future<void> Function() onWaitlist,
  bool isBusy = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ClassDetailSheet(
      session: session,
      onBook: onBook,
      onWaitlist: onWaitlist,
      isBusy: isBusy,
    ),
  );
}

class ClassDetailSheet extends StatefulWidget {
  const ClassDetailSheet({
    super.key,
    required this.session,
    required this.onBook,
    required this.onWaitlist,
    this.isBusy = false,
  });

  final ClassSession session;
  final Future<void> Function() onBook;
  final Future<void> Function() onWaitlist;
  final bool isBusy;

  @override
  State<ClassDetailSheet> createState() => _ClassDetailSheetState();
}

class _ClassDetailSheetState extends State<ClassDetailSheet> {
  bool _working = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _working = true);
    try {
      await action();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final busy = _working || widget.isBusy;
    final canBook = !session.bookedByMe && !session.isFull && !session.isCancelled;
    final canWaitlist = !session.bookedByMe && (session.isFull || session.waitlistedByMe);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        GravitySpacing.lg,
        GravitySpacing.md,
        GravitySpacing.lg,
        MediaQuery.paddingOf(context).bottom + GravitySpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GravityColors.gray200,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          Text(
            session.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: GravityColors.gray900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${SchedulingFormatters.heroTimeLabel(session.startsAt)} · ${SchedulingFormatters.durationLabel(session.duration)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: GravityColors.gray600,
            ),
          ),
          const SizedBox(height: GravitySpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.person_rounded, label: session.coachLabel),
              _MetaChip(icon: Icons.place_outlined, label: session.locationLabel),
              _MetaChip(
                icon: Icons.groups_outlined,
                label: session.isFull
                    ? "Full · ${session.waitlistCount} waiting"
                    : "${session.spotsLeft} of ${session.capacity} spots left",
              ),
            ],
          ),
          if (session.description != null && session.description!.isNotEmpty) ...[
            const SizedBox(height: GravitySpacing.md),
            Text(
              session.description!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: GravityColors.gray600,
              ),
            ),
          ],
          const SizedBox(height: GravitySpacing.lg),
          if (session.bookedByMe)
            GravityButton(
              label: "You're booked",
              onPressed: null,
              fullWidth: true,
            )
          else if (session.isCancelled)
            GravityButton(
              label: "Class cancelled",
              onPressed: null,
              fullWidth: true,
            )
          else if (canBook)
            GravityButton(
              label: "Book this class",
              onPressed: busy ? null : () => _run(widget.onBook),
              isLoading: busy,
              fullWidth: true,
            )
          else if (canWaitlist)
            GravityButton(
              label: session.waitlistedByMe ? "Leave waitlist" : "Join waitlist",
              onPressed: busy ? null : () => _run(widget.onWaitlist),
              isLoading: busy,
              fullWidth: true,
              variant: session.waitlistedByMe
                  ? GravityButtonVariant.secondary
                  : GravityButtonVariant.primary,
            ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GravityColors.neutral50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GravityColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: GravityColors.primary700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GravityColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}
