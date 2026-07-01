import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';
import '../widgets/shared_widgets.dart';

class HomeBodyView extends StatelessWidget {
  const HomeBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: HudColors.green, size: 14),
            const SizedBox(width: 6),
            Text('HOME GARAGE',
                style: HudText.label
                    .copyWith(color: HudColors.green, fontSize: 9, letterSpacing: 2)),
            const Spacer(),
            Text('ETA  ',
                style: HudText.label.copyWith(color: HudColors.dimCyan, fontSize: 7)),
            Text('18:45',
                style: HudText.label.copyWith(color: HudColors.amber, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '12.4',
                style: HudText.speedDigits.copyWith(
                    fontSize: 42,
                    color: HudColors.cyan,
                    shadows: [
                      Shadow(color: HudColors.cyan.withValues(alpha: 0.5), blurRadius: 14)
                    ])),
            TextSpan(
                text: ' KM',
                style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    color: HudColors.dimCyan,
                    letterSpacing: 1)),
          ]),
        ),
        const SizedBox(height: 4),
        Text('VIA  HWY A1 → RING RD → HOME ST',
            style: HudText.label
                .copyWith(color: HudColors.dimCyan, fontSize: 7, letterSpacing: 1)),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ROUTE PROGRESS',
                    style: HudText.label
                        .copyWith(color: HudColors.dimCyan, fontSize: 7, letterSpacing: 1)),
                Text('68%',
                    style: HudText.label.copyWith(color: HudColors.cyan, fontSize: 8)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  Container(height: 5, color: HudColors.panelFill),
                  FractionallySizedBox(
                    widthFactor: 0.68,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: HudColors.cyan,
                        boxShadow: [
                          BoxShadow(
                              color: HudColors.cyan.withValues(alpha: 0.5),
                              blurRadius: 6)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatBadge(label: 'TIME LEFT', value: '24',   unit: 'MIN', color: HudColors.amber),
            StatBadge(label: 'REMAINING', value: '12.4', unit: 'KM',  color: HudColors.cyan),
            StatBadge(label: 'FUEL ETA',  value: '68',   unit: '%',   color: HudColors.green),
          ],
        ),
      ],
    );
  }
}
