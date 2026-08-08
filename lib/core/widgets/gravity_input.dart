import "package:flutter/material.dart";

import "../theme/design_tokens.dart";

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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: GravityColors.neutral800,
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
          style: const TextStyle(
            fontSize: 14,
            color: GravityColors.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: GravityColors.neutral500),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GravityRadii.md),
              borderSide: const BorderSide(color: GravityColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GravityRadii.md),
              borderSide: BorderSide(
                color: error != null
                    ? GravityColors.danger600
                    : GravityColors.neutral300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GravityRadii.md),
              borderSide: BorderSide(
                color: error != null
                    ? GravityColors.danger600
                    : GravityColors.primary500,
                width: 2,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: const TextStyle(
              fontSize: 13,
              color: GravityColors.danger600,
            ),
          ),
        ],
      ],
    );
  }
}
