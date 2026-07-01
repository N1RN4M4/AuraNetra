import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

class FavBodyView extends StatelessWidget {
  const FavBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (name: 'RIDERS CAFÉ',  dist: '3.2',  time: '8',  color: HudColors.cyan),
      (name: 'VIEWPOINT A1', dist: '7.1',  time: '11', color: HudColors.green),
      (name: 'HOME GARAGE',  dist: '18.7', time: '24', color: HudColors.amber),
      (name: 'COASTAL HWY',  dist: '32.0', time: '38', color: HudColors.dimCyan),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FavItem(
                    name: item.name,
                    dist: item.dist,
                    time: item.time,
                    color: item.color),
              ))
          .toList(),
    );
  }
}

class _FavItem extends StatelessWidget {
  final String name, dist, time;
  final Color color;

  const _FavItem(
      {required this.name,
      required this.dist,
      required this.time,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HudColors.panelFill,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: color, size: 13,
              shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6)]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                style: HudText.label
                    .copyWith(color: color, fontSize: 9, letterSpacing: 1.5)),
          ),
          Text('$dist KM',
              style: HudText.label.copyWith(color: HudColors.dimCyan, fontSize: 8)),
          const SizedBox(width: 8),
          Text('$time MIN',
              style: HudText.label.copyWith(color: HudColors.dimCyan, fontSize: 8)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: HudColors.dimCyan.withValues(alpha: 0.5), size: 14),
        ],
      ),
    );
  }
}
