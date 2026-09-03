import "package:flutter/material.dart";

import "../theme/design_tokens.dart";
import "../theme/gravity_palette.dart";

class GravityInput extends StatelessWidget {
  const GravityInput({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.palette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          autofillHints: autofillHints,
          style: TextStyle(fontSize: 14, color: context.palette.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.palette.textMuted),
            filled: true,
            fillColor: context.palette.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GravityRadii.md),
              borderSide: BorderSide(color: context.palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GravityRadii.md),
              borderSide: BorderSide(
                color: error != null
                    ? context.palette.danger
                    : context.palette.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GravityRadii.md),
              borderSide: BorderSide(
                color: error != null
                    ? context.palette.danger
                    : context.palette.accent,
                width: 2,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(fontSize: 13, color: context.palette.danger),
          ),
        ],
      ],
    );
  }
}
