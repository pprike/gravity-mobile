import "package:flutter/material.dart";

import "../theme/design_tokens.dart";
import "../theme/gravity_palette.dart";

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
    // Material (not a plain Container) so ListTile/Switch descendants can paint
    // their ink and resolve a background colour.
    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(GravityRadii.lg),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GravityRadii.lg),
          border: Border.all(color: context.palette.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
