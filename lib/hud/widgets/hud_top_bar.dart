import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

class HudTopBar extends StatelessWidget {
  final int speedLimit;
  final double cameraDistanceKm;

  const HudTopBar({
    super.key,
    this.speedLimit = 60,
    this.cameraDistanceKm = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Chip(label: 'LIMIT', value: '$speedLimit', unit: 'KM/H', color: HudColors.green),
        const _ScanlineTitle(),
        _Chip(
          label: 'CAM',
          value: cameraDistanceKm.toStringAsFixed(1),
          unit: 'KM',
          color: HudColors.amber,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value, unit;
  final Color color;

  const _Chip({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(label, style: HudText.label.copyWith(color: color.withValues(alpha: 0.65), fontSize: 9)),
          const SizedBox(width: 6),
          Text(value, style: HudText.label.copyWith(color: color, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(width: 3),
          Text(unit, style: HudText.label.copyWith(color: color.withValues(alpha: 0.65), fontSize: 9)),
        ],
      ),
    );
  }
}

class _ScanlineTitle extends StatefulWidget {
  const _ScanlineTitle();

  @override
  State<_ScanlineTitle> createState() => _ScanlineTitleState();
}

class _ScanlineTitleState extends State<_ScanlineTitle> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'JARVIS HUD',
          style: HudText.label.copyWith(fontSize: 9, letterSpacing: 5, color: HudColors.dimCyan),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 72,
          height: 2,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => CustomPaint(painter: _ScanPainter(_ctrl.value)),
          ),
        ),
      ],
    );
  }
}

class _ScanPainter extends CustomPainter {
  final double t;
  _ScanPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()..color = HudColors.dimCyan..strokeWidth = 1,
    );
    final x = t * size.width;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = HudColors.cyan
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.t != t;
}
