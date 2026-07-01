import 'package:flutter/foundation.dart';

enum TurnDir { straight, left, right, slightLeft, slightRight }

enum HudTab { nav, hud, stats }

@immutable
class HudState {
  final double speed;
  final double rpm;
  final double leanAngle;
  final double heading; // 0–360 compass degrees
  final bool leftThreat;
  final bool rightThreat;
  final TurnDir navDir;
  final int navDist;
  final String navStreet;

  const HudState({
    this.speed = 0,
    this.rpm = 0,
    this.leanAngle = 0,
    this.heading = 90, // default facing East (matches wireframe)
    this.leftThreat = false,
    this.rightThreat = false,
    this.navDir = TurnDir.straight,
    this.navDist = 350,
    this.navStreet = 'MAIN ST',
  });

  double get peripheralOpacity {
    if (speed <= 40) return 1.0;
    if (speed >= 100) return 0.15;
    return 1.0 - ((speed - 40) / 60) * 0.85;
  }

  HudState copyWith({
    double? speed,
    double? rpm,
    double? leanAngle,
    double? heading,
    bool? leftThreat,
    bool? rightThreat,
    TurnDir? navDir,
    int? navDist,
    String? navStreet,
  }) =>
      HudState(
        speed: speed ?? this.speed,
        rpm: rpm ?? this.rpm,
        leanAngle: leanAngle ?? this.leanAngle,
        heading: heading ?? this.heading,
        leftThreat: leftThreat ?? this.leftThreat,
        rightThreat: rightThreat ?? this.rightThreat,
        navDir: navDir ?? this.navDir,
        navDist: navDist ?? this.navDist,
        navStreet: navStreet ?? this.navStreet,
      );
}
