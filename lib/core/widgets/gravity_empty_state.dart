import "package:flutter/material.dart";

import "../theme/design_tokens.dart";
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
        color: GravityColors.neutral50,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        border: Border.all(
          color: GravityColors.neutral300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: GravityColors.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: GravityColors.primary600, size: 28),
          ),
          const SizedBox(height: GravitySpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: GravityColors.neutral900,
                ),
          ),
          const SizedBox(height: GravitySpacing.sm),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GravityColors.neutral600,
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
