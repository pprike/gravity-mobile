import "package:flutter/material.dart";

import "../theme/design_tokens.dart";

abstract final class GravityFeedback {
  static void showSnack(
    BuildContext context, {
    required String message,
    bool error = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? GravityColors.danger700
              : GravityColors.gray900,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GravityRadii.md),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: GravityColors.gray900,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: GravityColors.gray600,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: GravityColors.gray600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: destructive
                    ? GravityColors.danger600
                    : GravityColors.primary600,
                foregroundColor: Colors.white,
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
