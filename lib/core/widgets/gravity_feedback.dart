import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../theme/design_tokens.dart";
import "../theme/gravity_palette.dart";
import "gravity_button.dart";

abstract final class GravityFeedback {
  static void tap() {
    HapticFeedback.selectionClick();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }

  static void warn() {
    HapticFeedback.heavyImpact();
  }

  static void showSnack(
    BuildContext context, {
    required String message,
    bool error = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (error) {
      warn();
    } else {
      success();
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? context.palette.danger
              : context.palette.inverseSurface,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GravityRadii.md),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: error
                  ? context.palette.onAccent
                  : context.palette.onInverseSurface,
            ),
          ),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: error
                      ? context.palette.onAccent
                      : context.palette.onInverseSurface,
                  onPressed: onAction,
                ),
        ),
      );
  }

  static Future<void> showBookingConfirmed({
    required BuildContext context,
    required String className,
    VoidCallback? onCheckIn,
  }) {
    success();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.paddingOf(sheetContext).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetContext.palette.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: sheetContext.palette.successSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: sheetContext.palette.success,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You’re in",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: sheetContext.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$className is on your Bookings tab. Show your check-in code when you arrive.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: sheetContext.palette.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GravityButton(
                label: "Show check-in code",
                icon: Icons.qr_code_2_rounded,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  onCheckIn?.call();
                },
              ),
              const SizedBox(height: 8),
              GravityButton(
                label: "Done",
                variant: GravityButtonVariant.tertiary,
                fullWidth: true,
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = "Keep going",
    String confirmLabel = "Confirm",
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GravityRadii.xl),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.palette.textPrimary,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: context.palette.textSecondary,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textSecondary,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: destructive
                    ? context.palette.danger
                    : context.palette.accent,
                foregroundColor: context.palette.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GravityRadii.md),
                ),
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result == true;
  }
}
