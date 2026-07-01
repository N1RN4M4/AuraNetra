import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_hud_lite/core/hud_settings.dart';

// Static mutable singleton. HudScreen calls apply() before building —
// all child widgets reading these getters then see the updated values.
class HudThemeState {
  static Color _accent = const Color(0xFF00FFFF);
  static HudPrimaryFont _primaryFont = HudPrimaryFont.cevicheOne;
  static HudSecondaryFont _secondaryFont = HudSecondaryFont.contrailOne;

  static void apply(HudSettings s) {
    _accent = s.accentColor.color;
    _primaryFont = s.primaryFont;
    _secondaryFont = s.secondaryFont;
  }

  static Color get accent => _accent;
  static HudPrimaryFont get primaryFont => _primaryFont;
  static HudSecondaryFont get secondaryFont => _secondaryFont;

  static TextStyle buildPrimary() => _resolveP(_primaryFont);
  static TextStyle buildSecondary() => _resolveS(_secondaryFont);

  // Used by settings UI to preview each font option
  static TextStyle buildPrimaryFor(HudPrimaryFont f) => _resolveP(f);
  static TextStyle buildSecondaryFor(HudSecondaryFont f) => _resolveS(f);

  static TextStyle _resolveP(HudPrimaryFont f) => switch (f) {
    HudPrimaryFont.cevicheOne => GoogleFonts.cevicheOne(),
    HudPrimaryFont.bangers => GoogleFonts.bangers(),
    HudPrimaryFont.stalistOne => GoogleFonts.stalinistOne(),
    HudPrimaryFont.atomicAge => GoogleFonts.atomicAge(),
  };

  static TextStyle _resolveS(HudSecondaryFont f) => switch (f) {
    HudSecondaryFont.contrailOne => GoogleFonts.contrailOne(),
    HudSecondaryFont.textMeOne => GoogleFonts.textMeOne(),
    HudSecondaryFont.sunflower => GoogleFonts.sunflower(),
    HudSecondaryFont.supermercadoOne => GoogleFonts.supermercadoOne(),
  };
}

// Shared dark map style — import this wherever GoogleMap is used
const String hudMapStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#0a1520"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#4a8fa8"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#040d16"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a3048"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#0d2035"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#6d9aae"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#1d4060"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#89c4db"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#030d14"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#1a4a6a"}]},
  {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#0d1e2e"}]}
]''';

class HudColors {
  static const background = Color(0xFF030D14);
  // Fixed semantic colors used for speed/status bands — not affected by theme
  static const green = Color(0xFF00FF7F);
  static const amber = Color(0xFFFFAA00);
  static const red = Color(0xFFFF2244);

  // Dynamic: change with accent color
  static Color get cyan => HudThemeState.accent;
  static Color get dimCyan => HudThemeState.accent.withValues(alpha: 0.25);
  static Color get panelBorder => HudThemeState.accent.withValues(alpha: 0.13);
  static Color get panelFill => HudThemeState.accent.withValues(alpha: 0.04);
}

class HudText {
  static TextStyle get speedDigits => HudThemeState.buildPrimary().copyWith(
    color: HudColors.cyan,
    letterSpacing: 2,
  );

  static TextStyle get navDistance => HudThemeState.buildPrimary().copyWith(
    fontSize: 22,
    color: HudColors.cyan,
    letterSpacing: 1,
  );

  static TextStyle get label => HudThemeState.buildSecondary().copyWith(
    fontSize: 15,
    color: HudColors.dimCyan,
  );
}
