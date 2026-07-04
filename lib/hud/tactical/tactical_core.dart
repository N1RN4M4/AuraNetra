import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tactical_theme.dart';

/// The central instrument: a slowly rotating radar scanner behind a rotated
/// hex holding the compass cardinal, with scale markers and the numeric
/// heading beneath it.
class TacticalCore extends StatefulWidget {
  final double heading;
  final double size;

  const TacticalCore({super.key, required this.heading, this.size = 200});

  @override
  State<TacticalCore> createState() => _TacticalCoreState();
}

class _TacticalCoreState extends State<TacticalCore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final headingText = '${(((widget.heading % 360) + 360) % 360).toStringAsFixed(1)}°';

    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating radar rings
          Opacity(
            opacity: 0.2,
            child: RotationTransition(
              turns: _spin,
              child: CustomPaint(
                size: Size.square(s),
                painter: const _ScannerPainter(),
              ),
            ),
          ),

          // Hex + scale column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HexBadge(label: tacticalHeadingLabel(widget.heading)),
              const SizedBox(height: 14),
              const _ScaleMarkers(),
              const SizedBox(height: 6),
              Text(headingText,
                  style: TacticalText.label(size: 10, bold: true, spacing: 1.5)),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 1,
                height: s * 0.16,
                color: TacticalColors.ink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 45°-rotated square holding a single upright glyph.
class _HexBadge extends StatelessWidget {
  final String label;
  const _HexBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: TacticalColors.bg,
          border: Border.all(color: TacticalColors.ink, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Text(label, style: TacticalText.display(size: 22)),
          ),
        ),
      ),
    );
  }
}

/// The little ladder of alternating tick lines under the hex.
class _ScaleMarkers extends StatelessWidget {
  const _ScaleMarkers();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double opacity) => Container(
          width: width,
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: TacticalColors.ink.withValues(alpha: opacity),
        );

    return Column(
      children: [
        bar(48, 1),
        bar(32, 0.5),
        bar(48, 1),
        bar(32, 0.5),
      ],
    );
  }
}

class _ScannerPainter extends CustomPainter {
  const _ScannerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    // Dashed outer ring
    final ring = Paint()
      ..color = TacticalColors.ink.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const segments = 60;
    final rect = Rect.fromCircle(center: center, radius: r);
    for (int i = 0; i < segments; i++) {
      final a = (2 * math.pi / segments) * i;
      canvas.drawArc(rect, a, (2 * math.pi / segments) * 0.5, false, ring);
    }

    // Two opposing sweep arcs — the "scan"
    final sweep = Paint()
      ..color = TacticalColors.ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final inner = Rect.fromCircle(center: center, radius: r * 0.98);
    canvas.drawArc(inner, -math.pi / 2, math.pi / 2 * 0.85, false, sweep);
    canvas.drawArc(inner, math.pi / 2, math.pi / 2 * 0.85, false, sweep);

    // Inner reference circle
    canvas.drawCircle(
      center,
      r * 0.6,
      Paint()
        ..color = TacticalColors.ink.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  @override
  bool shouldRepaint(_ScannerPainter oldDelegate) => false;
}
