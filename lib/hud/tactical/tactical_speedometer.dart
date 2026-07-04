import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tactical_theme.dart';

/// Bottom-right round velocity gauge: a 270° track with a filled progress arc,
/// a needle and the numeric speed at the hub.
class TacticalSpeedometer extends StatelessWidget {
  final double speed;
  final double maxSpeed;
  final double size;

  const TacticalSpeedometer({
    super.key,
    required this.speed,
    this.maxSpeed = 200,
    this.size = 128,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (speed / maxSpeed).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('VELOCITY_KPH',
            style: TacticalText.label(
                size: 8, bold: true, color: TacticalColors.dim)),
        const SizedBox(height: 4),
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GaugePainter(fraction: fraction),
                ),
              ),
              // Numeric readout sits at the top-left, outside the dial's arc
              // (the hub stays empty), showing one decimal place.
              Positioned(
                top: -6,
                left: -8,
                child: Text(speed.toStringAsFixed(1),
                    style: TacticalText.display(size: 26)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;

  // 270° sweep with the gap centred at the bottom of the dial.
  static const double _start = math.pi * 0.75; // 135°
  static const double _sweep = math.pi * 1.5; // 270°

  const _GaugePainter({required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: r);

    // Track
    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..color = TacticalColors.ink.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Progress
    canvas.drawArc(
      rect,
      _start,
      _sweep * fraction,
      false,
      Paint()
        ..color = TacticalColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Needle
    final angle = _start + _sweep * fraction;
    final tip = center + Offset(math.cos(angle), math.sin(angle)) * (r * 0.78);
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = TacticalColors.ink
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Hub
    canvas.drawCircle(center, 3.5, Paint()..color = TacticalColors.ink);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
