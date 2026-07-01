import 'package:flutter/material.dart';

enum HudPrimaryFont {
  bangers,
  stalistOne,
  atomicAge,
  cevicheOne;

  String get displayName => switch (this) {
    HudPrimaryFont.cevicheOne => 'CEVICHE ONE',
    HudPrimaryFont.bangers => 'BANGERS',
    HudPrimaryFont.stalistOne => 'STALINIST',
    HudPrimaryFont.atomicAge => 'ATOMIC AGE',
  };
}

enum HudSecondaryFont {
  textMeOne,
  sunflower,
  supermercadoOne,
  contrailOne;

  String get displayName => switch (this) {
    HudSecondaryFont.contrailOne => 'CONTRAIL',
    HudSecondaryFont.textMeOne => 'TEXT ME',
    HudSecondaryFont.sunflower => 'SUNFLOWER',
    HudSecondaryFont.supermercadoOne => 'SUPERMERCADO',
  };
}

enum HudAccentColor {
  cyan(Color(0xFF00FFFF), 'CYAN'),
  green(Color(0xFF00FF7F), 'GREEN'),
  amber(Color(0xFFFFAA00), 'AMBER'),
  red(Color(0xFFFF2244), 'RED'),
  blue(Color(0xFF0088FF), 'BLUE'),
  purple(Color(0xFFBB44FF), 'PURPLE');

  const HudAccentColor(this.color, this.label);
  final Color color;
  final String label;
}

@immutable
class HudSettings {
  final HudPrimaryFont primaryFont;
  final HudSecondaryFont secondaryFont;
  final HudAccentColor accentColor;

  const HudSettings({
    this.primaryFont = HudPrimaryFont.bangers,
    this.secondaryFont = HudSecondaryFont.textMeOne,
    this.accentColor = HudAccentColor.cyan,
  });

  HudSettings copyWith({
    HudPrimaryFont? primaryFont,
    HudSecondaryFont? secondaryFont,
    HudAccentColor? accentColor,
  }) => HudSettings(
    primaryFont: primaryFont ?? this.primaryFont,
    secondaryFont: secondaryFont ?? this.secondaryFont,
    accentColor: accentColor ?? this.accentColor,
  );
}
