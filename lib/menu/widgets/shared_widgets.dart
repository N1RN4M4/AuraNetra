import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

class StatBadge extends StatelessWidget {
  final String label, value, unit;
  final Color color;

  const StatBadge({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: HudText.label.copyWith(
                color: HudColors.dimCyan, fontSize: 7, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: value,
                style: HudText.speedDigits.copyWith(
                    fontSize: 22,
                    color: color,
                    shadows: [
                      Shadow(color: color.withValues(alpha: 0.6), blurRadius: 8)
                    ])),
            if (unit.isNotEmpty)
              TextSpan(
                  text: unit,
                  style: HudText.label
                      .copyWith(color: color.withValues(alpha: 0.8), fontSize: 8)),
          ]),
        ),
      ],
    );
  }
}
