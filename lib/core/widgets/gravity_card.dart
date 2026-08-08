import "package:flutter/material.dart";

import "../theme/design_tokens.dart";

class GravityCard extends StatelessWidget {
  const GravityCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GravitySpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        border: Border.all(color: GravityColors.neutral200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
