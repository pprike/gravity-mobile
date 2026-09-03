import "package:flutter/material.dart";

import "../theme/design_tokens.dart";
import "../theme/gravity_palette.dart";
import "gravity_button.dart";

class GravityEmptyState extends StatelessWidget {
  const GravityEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: GravitySpacing.lg,
        vertical: GravitySpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        border: Border.all(
          color: context.palette.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.palette.accentSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.palette.accent, size: 28),
          ),
          const SizedBox(height: GravitySpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: GravitySpacing.sm),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: GravitySpacing.lg),
            GravityButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
