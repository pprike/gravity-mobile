import "package:flutter/material.dart";

/// Gravity design tokens aligned with gravity-ui (globals.css + tailwind.config).
abstract final class GravityColors {
  static const primary50 = Color(0xFFF0FDFA);
  static const primary100 = Color(0xFFCCFBF1);
  static const primary500 = Color(0xFF14B8A6);
  static const primary600 = Color(0xFF0D9488);
  static const primary700 = Color(0xFF0F766E);

  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4);
  static const neutral500 = Color(0xFF737373);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);
  static const neutral900 = Color(0xFF171717);

  // Figma mobile palette (Tailwind gray scale used in designs)
  static const gray200 = Color(0xFFE5E7EB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray900 = Color(0xFF111827);
  static const mint100 = Color(0xFFD1FAE5);

  static const success600 = Color(0xFF16A34A);
  static const warning600 = Color(0xFFD97706);
  static const danger50 = Color(0xFFFEF2F2);
  static const danger600 = Color(0xFFDC2626);
  static const danger700 = Color(0xFFB91C1C);
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
