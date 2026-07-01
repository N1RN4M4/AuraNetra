import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

class SpeedometerArc extends StatelessWidget {
  final double speed;
  final double rpm;
  final double leanAngle;
  final double size;

  const SpeedometerArc({
    super.key,
    required this.speed,
    required this.rpm,
    required this.leanAngle,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final tilt = (leanAngle / 45.0) * (5 * math.pi / 180);
    return Transform.rotate(
      angle: tilt,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ArcPainter(speed: speed, rpm: rpm, accent: HudColors.cyan),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  speed.toStringAsFixed(0),
                  style: HudText.speedDigits.copyWith(
                    fontSize: size * 0.34,
                    shadows: [
                      Shadow(color: HudColors.cyan.withValues(alpha: 0.8), blurRadius: 12),
                    ],
                  ),
                ),
                Text(
                  'KM/H',
                  style: HudText.label.copyWith(fontSize: size * 0.09, letterSpacing: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double speed;
  final double rpm;
  final Color accent;

  static const double _start = 135 * math.pi / 180;
  static const double _sweep = 270 * math.pi / 180;
  static const double _maxSpeed = 200;

  const _ArcPainter({required this.speed, required this.rpm, required this.accent});

  Color get _speedColor {
    if (speed < 60) return accent;
    if (speed < 100) return HudColors.green;
    if (speed < 150) return HudColors.amber;
    return HudColors.red;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    final progress = (speed / _maxSpeed).clamp(0.0, 1.0);
    final fill = _sweep * progress;
    final color = _speedColor;

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      _start, _sweep, false,
      Paint()
        ..color = accent.withValues(alpha: 0.25).withValues(alpha: 0.18)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        _start, fill, false,
        Paint()
          ..color = color.withValues(alpha: 0.28)
          ..strokeWidth = 16
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        _start, fill, false,
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    final ri = r - 14;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: ri),
      _start, _sweep, false,
      Paint()
        ..color = accent.withValues(alpha: 0.25).withValues(alpha: 0.1)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    if (rpm > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: ri),
        _start, _sweep * rpm, false,
        Paint()
          ..color = HudColors.green.withValues(alpha: 0.7)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    final tickPaint = Paint()
      ..color = accent.withValues(alpha: 0.25).withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    for (int i = 0; i <= 4; i++) {
      final a = _start + _sweep * i / 4;
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * (r - 8), c.dy + math.sin(a) * (r - 8)),
        Offset(c.dx + math.cos(a) * (r + 6), c.dy + math.sin(a) * (r + 6)),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => true;
}
