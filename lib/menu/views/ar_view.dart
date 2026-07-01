import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

class ArBodyView extends StatelessWidget {
  const ArBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ArItem(label: 'SPEED OVERLAY', status: 'ACTIVE', color: HudColors.green),
        const SizedBox(height: 8),
        _ArItem(label: 'TURN ARROWS',   status: 'ACTIVE', color: HudColors.green),
        const SizedBox(height: 8),
        _ArItem(label: 'HAZARD ALERTS', status: 'ACTIVE', color: HudColors.green),
        const SizedBox(height: 8),
        _ArItem(label: 'LANE GUIDE',    status: 'OFF',    color: HudColors.dimCyan),
        const SizedBox(height: 8),
        _ArItem(label: 'NIGHT VISION',  status: 'OFF',    color: HudColors.dimCyan),
        const SizedBox(height: 8),
        _ArItem(label: 'RADAR SWEEP',   status: 'ACTIVE', color: HudColors.amber),
      ],
    );
  }
}

class _ArItem extends StatelessWidget {
  final String label, status;
  final Color color;

  const _ArItem({required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: HudText.label
                  .copyWith(color: HudColors.dimCyan, fontSize: 9, letterSpacing: 1.5)),
        ),
        Text(status,
            style: HudText.label.copyWith(color: color, fontSize: 8, letterSpacing: 1)),
      ],
    );
  }
}
