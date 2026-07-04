import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

/// Palette for the tactical HUD.
///
/// The instrument line-art follows the app theme: [ink] (every stroke, tick and
/// glyph) tracks the user's selected accent — the "colour line" — while [bg]
/// sits on the shared dark HUD background. Fonts likewise come from
/// [HudThemeState] (see [TacticalText]), so the whole panel re-tints and
/// re-types the moment the accent, background or fonts change.
class TacticalColors {
  const TacticalColors._();

  /// Shared dark HUD background.
  static Color get bg => HudColors.background;

  /// The accent "colour line" — used for all strokes, ticks and text.
  static Color get ink => HudThemeState.accent;

  static Color get secondary => HudThemeState.accent.withValues(alpha: 0.7);
  static Color get dim => HudThemeState.accent.withValues(alpha: 0.4);
  static Color get grid => HudThemeState.accent.withValues(alpha: 0.12);

  /// Fixed semantic warning colour — stays legible regardless of accent.
  static Color get warning => HudColors.amber;
}

/// Text styles for the tactical HUD.
///
/// Fonts are inherited from the app's existing theme ([HudThemeState]) — only
/// sizing, spacing and weight are tuned here so the redesign stays consistent
/// with the rest of the product. Callers uppercase their own strings.
class TacticalText {
  const TacticalText._();

  /// Small caption used for the many micro labels around the frame.
  static TextStyle label({
    Color? color,
    double size = 9,
    bool bold = false,
    double spacing = 1.2,
    double? opacity,
  }) {
    final base = color ?? TacticalColors.ink;
    final c = opacity == null ? base : base.withValues(alpha: opacity);
    return HudThemeState.buildSecondary().copyWith(
      fontSize: size,
      color: c,
      letterSpacing: spacing,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      height: 1.15,
    );
  }

  /// Large numeric readout (speed / coordinates), uses the display font.
  static TextStyle display({
    Color? color,
    double size = 20,
    double spacing = 1,
  }) {
    return HudThemeState.buildPrimary().copyWith(
      fontSize: size,
      color: color ?? TacticalColors.ink,
      letterSpacing: spacing,
    );
  }
}

/// Desaturated, dark map style so the Google map content reads as part of the
/// dark instrument panel rather than a bright inset. Neutral greys (rather than
/// the accent) keep the map legible under any "colour line".
const String tacticalMapStyle = '''[
  {"elementType":"geometry","stylers":[{"saturation":-100},{"color":"#0a1218"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a949c"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#040a0f"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#243138"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#161f25"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2f3f48"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#050d12"}]},
  {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#0c161c"}]}
]''';

/// Cardinal / degree label for a 0–360° compass heading.
String tacticalHeadingLabel(double heading) {
  final n = ((heading % 360) + 360) % 360;
  if (n < 7 || n > 353) return 'N';
  if ((n - 45).abs() < 7) return 'NE';
  if ((n - 90).abs() < 7) return 'E';
  if ((n - 135).abs() < 7) return 'SE';
  if ((n - 180).abs() < 7) return 'S';
  if ((n - 225).abs() < 7) return 'SW';
  if ((n - 270).abs() < 7) return 'W';
  if ((n - 315).abs() < 7) return 'NW';
  return '${n.round()}°';
}
