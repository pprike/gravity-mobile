import "package:flutter/material.dart";

import "../../core/api/error_messages.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/theme/studio_imagery.dart";
import "../../core/widgets/gravity_button.dart";
import "../check_in/check_in_sheet.dart";
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
    useSafeArea: true,
    backgroundColor: context.palette.surface,
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
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() => _error = friendlyErrorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final busy = _working || widget.isBusy;
    final canBook =
        !session.bookedByMe && !session.isFull && !session.isCancelled;
    final canWaitlist =
        !session.bookedByMe && (session.isFull || session.waitlistedByMe);

    return SingleChildScrollView(
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
                color: context.palette.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: GravitySpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(GravityRadii.lg),
            child: SizedBox(
              height: 148,
              width: double.infinity,
              child: Image.asset(
                StudioImagery.forClassName(session.name),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: Color(0xFF111827)),
              ),
            ),
          ),
          const SizedBox(height: GravitySpacing.md),
          Text(
            session.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.palette.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${SchedulingFormatters.heroTimeLabel(session.startsAt)} · ${SchedulingFormatters.durationLabel(session.duration)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: GravitySpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.person_rounded, label: session.coachLabel),
              _MetaChip(
                icon: Icons.place_outlined,
                label: session.locationLabel,
              ),
              _MetaChip(
                icon: Icons.groups_outlined,
                label: session.isFull
                    ? "Full · ${session.waitlistCount} waiting"
                    : "${session.spotsLeft} of ${session.capacity} spots left",
              ),
            ],
          ),
          if (session.description != null &&
              session.description!.isNotEmpty) ...[
            const SizedBox(height: GravitySpacing.md),
            Text(
              session.description!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: context.palette.textSecondary,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: GravitySpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.palette.dangerSurface,
                borderRadius: BorderRadius.circular(GravityRadii.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: context.palette.danger,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: context.palette.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: GravitySpacing.lg),
          if (session.bookedByMe) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                "You’re booked. Show this code at the desk when you arrive.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: context.palette.accentStrong,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GravityButton(
              label: "Show check-in code",
              icon: Icons.qr_code_2_rounded,
              onPressed: () => showCheckInSheet(context),
              fullWidth: true,
            ),
          ] else if (session.isCancelled)
            const GravityButton(
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
              label: session.waitlistedByMe
                  ? "Leave waitlist"
                  : "Join waitlist",
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
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.palette.accentStrong),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
