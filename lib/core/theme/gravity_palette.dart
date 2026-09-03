import "package:flutter/material.dart";

import "design_tokens.dart";

/// Semantic colour roles, resolved per brightness.
///
/// Screens should reach for these (via `context.palette`) instead of the raw
/// [GravityColors] ramp so light and dark stay in sync. The raw ramp remains
/// the source of truth for hues; this layer only assigns them meaning.
@immutable
class GravityPalette extends ThemeExtension<GravityPalette> {
  const GravityPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onAccent,
    required this.accent,
    required this.accentStrong,
    required this.accentSurface,
    required this.dangerSurface,
    required this.danger,
    required this.warningSurface,
    required this.warning,
    required this.successSurface,
    required this.success,
    required this.inverseSurface,
    required this.onInverseSurface,
  });

  /// Screen background behind cards.
  final Color canvas;

  /// Cards, sheets, and app bars.
  final Color surface;

  /// Inset areas inside a card: fields, chips, disabled buttons.
  final Color surfaceMuted;

  final Color border;

  final Color textPrimary;
  final Color textSecondary;

  /// De-emphasised text: unselected tabs, captions, placeholders.
  final Color textMuted;

  /// Text/icons drawn on top of [accent].
  final Color onAccent;

  final Color accent;

  /// A heavier accent for text on [accentSurface], where [accent] is too light.
  final Color accentStrong;
  final Color accentSurface;

  final Color dangerSurface;
  final Color danger;
  final Color warningSurface;
  final Color warning;
  final Color successSurface;
  final Color success;

  /// Snack bars and other surfaces that intentionally invert the theme.
  final Color inverseSurface;
  final Color onInverseSurface;

  static const light = GravityPalette(
    canvas: GravityColors.neutral50,
    surface: Colors.white,
    surfaceMuted: GravityColors.neutral50,
    border: GravityColors.gray200,
    textPrimary: GravityColors.gray900,
    textSecondary: GravityColors.gray600,
    textMuted: GravityColors.gray400,
    onAccent: Colors.white,
    accent: GravityColors.primary600,
    accentStrong: GravityColors.primary700,
    accentSurface: GravityColors.primary50,
    dangerSurface: GravityColors.danger50,
    danger: GravityColors.danger600,
    warningSurface: GravityColors.warning50,
    warning: GravityColors.warning600,
    successSurface: GravityColors.success50,
    success: GravityColors.success600,
    inverseSurface: GravityColors.gray900,
    onInverseSurface: Colors.white,
  );

  static const dark = GravityPalette(
    canvas: GravityColors.darkCanvas,
    surface: GravityColors.darkSurface,
    surfaceMuted: GravityColors.darkSurfaceMuted,
    border: GravityColors.darkBorder,
    textPrimary: GravityColors.darkTextPrimary,
    textSecondary: GravityColors.darkTextSecondary,
    textMuted: GravityColors.darkTextMuted,
    onAccent: GravityColors.darkCanvas,
    // The 600 accent lacks contrast on a dark canvas, so dark mode steps up.
    accent: GravityColors.primary500,
    accentStrong: GravityColors.primary100,
    accentSurface: GravityColors.darkAccentSurface,
    dangerSurface: GravityColors.darkDangerSurface,
    danger: GravityColors.danger300,
    warningSurface: GravityColors.darkWarningSurface,
    warning: GravityColors.warning300,
    successSurface: GravityColors.darkSuccessSurface,
    success: GravityColors.success300,
    inverseSurface: GravityColors.darkSurfaceMuted,
    onInverseSurface: GravityColors.darkTextPrimary,
  );

  @override
  GravityPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? onAccent,
    Color? accent,
    Color? accentStrong,
    Color? accentSurface,
    Color? dangerSurface,
    Color? danger,
    Color? warningSurface,
    Color? warning,
    Color? successSurface,
    Color? success,
    Color? inverseSurface,
    Color? onInverseSurface,
  }) {
    return GravityPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      onAccent: onAccent ?? this.onAccent,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentSurface: accentSurface ?? this.accentSurface,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      danger: danger ?? this.danger,
      warningSurface: warningSurface ?? this.warningSurface,
      warning: warning ?? this.warning,
      successSurface: successSurface ?? this.successSurface,
      success: success ?? this.success,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
    );
  }

  @override
  GravityPalette lerp(ThemeExtension<GravityPalette>? other, double t) {
    if (other is! GravityPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return GravityPalette(
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      onAccent: mix(onAccent, other.onAccent),
      accent: mix(accent, other.accent),
      accentStrong: mix(accentStrong, other.accentStrong),
      accentSurface: mix(accentSurface, other.accentSurface),
      dangerSurface: mix(dangerSurface, other.dangerSurface),
      danger: mix(danger, other.danger),
      warningSurface: mix(warningSurface, other.warningSurface),
      warning: mix(warning, other.warning),
      successSurface: mix(successSurface, other.successSurface),
      success: mix(success, other.success),
      inverseSurface: mix(inverseSurface, other.inverseSurface),
      onInverseSurface: mix(onInverseSurface, other.onInverseSurface),
    );
  }
}

extension GravityPaletteAccess on BuildContext {
  GravityPalette get palette =>
      Theme.of(this).extension<GravityPalette>() ?? GravityPalette.light;
}
