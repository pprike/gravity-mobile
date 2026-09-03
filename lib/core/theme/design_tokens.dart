import "package:flutter/material.dart";

/// Gravity design tokens aligned with Figma and gravity-ui.
abstract final class GravityColors {
  static const primary50 = Color(0xFFF0FDFA);
  static const primary100 = Color(0xFFCCFBF1);
  static const primary500 = Color(0xFF14B8A6);
  static const primary600 = Color(0xFF0D9488);
  static const primary700 = Color(0xFF0F766E);
  static const primary800 = Color(0xFF115E59);

  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4);
  static const neutral500 = Color(0xFF737373);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);
  static const neutral900 = Color(0xFF171717);

  static const gray200 = Color(0xFFE5E7EB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray900 = Color(0xFF111827);
  static const mint100 = Color(0xFFD1FAE5);

  static const success50 = Color(0xFFECFDF5);
  static const success300 = Color(0xFF6EE7A7);
  static const success600 = Color(0xFF16A34A);
  static const warning50 = Color(0xFFFEF3C7);
  static const warning300 = Color(0xFFFCD34D);
  static const warning600 = Color(0xFFD97706);
  static const danger50 = Color(0xFFFEF2F2);
  static const danger300 = Color(0xFFFCA5A5);
  static const danger600 = Color(0xFFDC2626);
  static const danger700 = Color(0xFFB91C1C);

  // Dark surfaces are warm-neutral rather than pure black so the teal accent
  // and photography still read as the studio brand.
  static const darkCanvas = Color(0xFF0B0F0E);
  static const darkSurface = Color(0xFF15201E);
  static const darkSurfaceMuted = Color(0xFF1E2A28);
  static const darkBorder = Color(0xFF2C3A37);
  static const darkTextPrimary = Color(0xFFF3F5F4);
  static const darkTextSecondary = Color(0xFFB2BFBC);
  static const darkTextMuted = Color(0xFF7C8B88);
  static const darkAccentSurface = Color(0xFF15332F);
  static const darkDangerSurface = Color(0xFF3A1D1D);
  static const darkWarningSurface = Color(0xFF3A2E14);
  static const darkSuccessSurface = Color(0xFF14321F);
}

abstract final class GravitySpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class GravityRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const button = 14.0;
  static const logo = 18.0;
}
