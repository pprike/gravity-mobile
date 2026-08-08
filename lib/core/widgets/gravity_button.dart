import "package:flutter/material.dart";

import "../theme/design_tokens.dart";

enum GravityButtonVariant { primary, secondary, tertiary, destructive }

class GravityButton extends StatelessWidget {
  const GravityButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GravityButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final GravityButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: GravitySpacing.sm),
              ],
              Text(label),
            ],
          );

    final style = switch (variant) {
      GravityButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: GravityColors.primary600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: GravityColors.primary600.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          elevation: 0,
        ),
      GravityButtonVariant.secondary => OutlinedButton.styleFrom(
          foregroundColor: GravityColors.neutral900,
          side: const BorderSide(color: GravityColors.neutral300),
          backgroundColor: Colors.white,
        ),
      GravityButtonVariant.tertiary => TextButton.styleFrom(
          foregroundColor: GravityColors.neutral700,
          backgroundColor: Colors.transparent,
        ),
      GravityButtonVariant.destructive => ElevatedButton.styleFrom(
          backgroundColor: GravityColors.danger600,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
    };

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GravityRadii.md),
    );

    final padding = const EdgeInsets.symmetric(
      horizontal: GravitySpacing.md,
      vertical: 12,
    );

    final button = switch (variant) {
      GravityButtonVariant.primary ||
      GravityButtonVariant.destructive =>
        ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: style.copyWith(
            padding: WidgetStateProperty.all(padding),
            shape: WidgetStateProperty.all(shape),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          child: child,
        ),
      GravityButtonVariant.secondary => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: style.copyWith(
            padding: WidgetStateProperty.all(padding),
            shape: WidgetStateProperty.all(shape),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          child: child,
        ),
      GravityButtonVariant.tertiary => TextButton(
          onPressed: enabled ? onPressed : null,
          style: style.copyWith(
            padding: WidgetStateProperty.all(padding),
            shape: WidgetStateProperty.all(shape),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          child: child,
        ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
