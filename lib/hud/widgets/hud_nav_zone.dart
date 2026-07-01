import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';
import '../../core/hud_state.dart';

class HudNavZone extends StatelessWidget {
  final TurnDir direction;
  final int distanceMeters;
  final String streetName;

  const HudNavZone({
    super.key,
    this.direction = TurnDir.straight,
    this.distanceMeters = 350,
    this.streetName = 'MAIN ST',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TurnArrow(direction: direction),
          const SizedBox(height: 6),
          Text(
            '${distanceMeters}M',
            style: HudText.navDistance.copyWith(
              shadows: [Shadow(color: HudColors.cyan.withValues(alpha: 0.8), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 3),
          Text(streetName, style: HudText.label),
        ],
      ),
    );
  }
}

class _TurnArrow extends StatelessWidget {
  final TurnDir direction;
  const _TurnArrow({required this.direction});

  IconData get _icon => switch (direction) {
        TurnDir.left => Icons.turn_left_rounded,
        TurnDir.right => Icons.turn_right_rounded,
        TurnDir.slightLeft => Icons.turn_slight_left_rounded,
        TurnDir.slightRight => Icons.turn_slight_right_rounded,
        TurnDir.straight => Icons.straight_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(_icon, size: 58, color: HudColors.cyan.withValues(alpha: 0.25)),
        Icon(
          _icon,
          size: 52,
          color: HudColors.cyan,
          shadows: [Shadow(color: HudColors.cyan, blurRadius: 18)],
        ),
      ],
    );
  }
}
