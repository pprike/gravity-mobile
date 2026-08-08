import "package:flutter/material.dart";

import "../theme/design_tokens.dart";

class GravityScreenHeader extends StatelessWidget {
  const GravityScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: GravityColors.primary600,
            ),
          ),
          const SizedBox(height: GravitySpacing.sm),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: GravityColors.neutral900,
                letterSpacing: -0.5,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: GravitySpacing.sm),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GravityColors.neutral600,
                  height: 1.5,
                ),
          ),
        ],
      ],
    );
  }
}
