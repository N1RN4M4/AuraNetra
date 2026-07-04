import 'package:flutter/material.dart';
import 'tactical_theme.dart';

/// Full-screen background for the tactical HUD: white fill, dotted grid, the
/// angled border frame, corner accents and the top / bottom notches.
///
/// Everything is drawn from a fixed 1000×562 design space and scaled to the
/// real screen, so the proportions match the reference layout at any size.
class TacticalFrame extends StatelessWidget {
  const TacticalFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _FramePainter(),
      child: SizedBox.expand(),
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter();

  static const double _vw = 1000;
  static const double _vh = 562;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = TacticalColors.bg);

    final sx = size.width / _vw;
    final sy = size.height / _vh;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    _paintDotGrid(canvas, p);
    _paintBorder(canvas, p);
    _paintCornerAccents(canvas, p);
    _paintNotches(canvas, p);
  }

  void _paintDotGrid(Canvas canvas, Offset Function(double, double) p) {
    final dot = Paint()..color = TacticalColors.grid;
    const step = 40.0;
    for (double x = 2; x <= _vw; x += step) {
      for (double y = 2; y <= _vh; y += step) {
        canvas.drawCircle(p(x, y), 0.8, dot);
      }
    }
  }

  void _paintBorder(Canvas canvas, Offset Function(double, double) p) {
    final path = Path()
      ..moveTo(p(50, 20).dx, p(50, 20).dy)
      ..lineTo(p(320, 20).dx, p(320, 20).dy)
      ..lineTo(p(340, 40).dx, p(340, 40).dy)
      ..lineTo(p(660, 40).dx, p(660, 40).dy)
      ..lineTo(p(680, 20).dx, p(680, 20).dy)
      ..lineTo(p(950, 20).dx, p(950, 20).dy)
      ..lineTo(p(980, 50).dx, p(980, 50).dy)
      ..lineTo(p(980, 512).dx, p(980, 512).dy)
      ..lineTo(p(950, 542).dx, p(950, 542).dy)
      ..lineTo(p(680, 542).dx, p(680, 542).dy)
      ..lineTo(p(660, 522).dx, p(660, 522).dy)
      ..lineTo(p(340, 522).dx, p(340, 522).dy)
      ..lineTo(p(320, 542).dx, p(320, 542).dy)
      ..lineTo(p(50, 542).dx, p(50, 542).dy)
      ..lineTo(p(20, 512).dx, p(20, 512).dy)
      ..lineTo(p(20, 50).dx, p(20, 50).dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = TacticalColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _paintCornerAccents(Canvas canvas, Offset Function(double, double) p) {
    final accent = Paint()
      ..color = TacticalColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.miter;

    void bracket(List<Offset> pts) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, accent);
    }

    bracket([p(20, 120), p(40, 120), p(40, 180)]);
    bracket([p(980, 120), p(960, 120), p(960, 180)]);
    bracket([p(20, 442), p(40, 442), p(40, 382)]);
    bracket([p(980, 442), p(960, 442), p(960, 382)]);
  }

  void _paintNotches(Canvas canvas, Offset Function(double, double) p) {
    final fill = Paint()..color = TacticalColors.ink;
    canvas.drawRect(Rect.fromPoints(p(440, 20), p(560, 30)), fill);
    canvas.drawRect(Rect.fromPoints(p(440, 532), p(560, 542)), fill);
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => false;
}
