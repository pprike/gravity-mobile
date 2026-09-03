import "package:flutter/material.dart";

/// Upper bound on the OS font-size setting we honour.
///
/// 2x matches the largest accessibility step iOS and Android expose by default.
const double kMaxTextScale = 2.0;

extension GravityTextScaling on BuildContext {
  /// The effective text scale, normalised so 1.0 means "system default".
  double get textScale {
    final scaler = MediaQuery.textScalerOf(this);
    return (scaler.scale(16) / 16).clamp(1.0, kMaxTextScale);
  }

  /// Grows a fixed dimension from the design spec in step with the text scale.
  ///
  /// Fixed heights and widths are unavoidable for a few surfaces — heroes hold
  /// background images, carousels need a scroll extent, and gutter columns keep
  /// rows aligned. Scaling them lets the text inside reflow instead of clipping
  /// at large font sizes.
  double scaled(double base) => base * textScale;

  /// Grows photo wells slower than type so primary actions stay on screen.
  double scaledMedia(double base) => base * (0.65 + 0.35 * textScale);
}
