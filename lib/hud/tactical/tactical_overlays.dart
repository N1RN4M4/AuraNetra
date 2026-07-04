import 'package:flutter/material.dart';
import '../../core/hud_state.dart';
import 'tactical_theme.dart';

// ─── Peripheral warning zones ─────────────────────────────────────────────────

/// A side threat marker. Dim/grey when idle, flashing amber when [active].
/// Tapping toggles the threat (drives the demo state).
class TacticalWarningZone extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const TacticalWarningZone({
    super.key,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  State<TacticalWarningZone> createState() => _TacticalWarningZoneState();
}

class _TacticalWarningZoneState extends State<TacticalWarningZone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: widget.active
            ? Tween(begin: 0.3, end: 1.0).animate(_flash)
            : const AlwaysStoppedAnimation(0.55),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 34,
                color: widget.active
                    ? TacticalColors.warning
                    : TacticalColors.dim),
            const SizedBox(height: 6),
            Text(widget.label,
                style: TacticalText.label(size: 8, bold: true)),
          ],
        ),
      ),
    );
  }
}

// ─── Top angled module ────────────────────────────────────────────────────────

/// Decorative angled module drawn at the top-centre of the frame.
class TacticalTopModule extends StatelessWidget {
  const TacticalTopModule({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 200,
      height: 40,
      child: CustomPaint(painter: _TopModulePainter()),
    );
  }
}

class _TopModulePainter extends CustomPainter {
  const _TopModulePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final line = Paint()
      ..color = TacticalColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.2, h * 0.75)
      ..lineTo(w * 0.8, h * 0.75)
      ..lineTo(w, 0);
    canvas.drawPath(path, line);

    canvas.drawRect(
      Rect.fromLTWH(w * 0.425, h * 0.625, w * 0.15, h * 0.12),
      Paint()..color = TacticalColors.ink,
    );

    final dot = Paint()..color = TacticalColors.ink.withValues(alpha: 0.3);
    for (final dx in [0.4, 0.5, 0.6]) {
      canvas.drawCircle(Offset(w * dx, h * 0.12), 1, dot);
    }
  }

  @override
  bool shouldRepaint(_TopModulePainter oldDelegate) => false;
}

// ─── Top-centre map scale ─────────────────────────────────────────────────────

class TacticalMapScale extends StatelessWidget {
  const TacticalMapScale({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tick(double height) =>
        Container(width: 1, height: height, color: TacticalColors.ink);

    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0M', style: TacticalText.label(size: 8, bold: true, opacity: 0.6)),
              Text('500M', style: TacticalText.label(size: 8, bold: true, opacity: 0.6)),
              Text('1KM', style: TacticalText.label(size: 8, bold: true, opacity: 0.6)),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 6,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: tick(6),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: tick(6),
                ),
                Center(
                  child: Container(height: 1, color: TacticalColors.ink),
                ),
                Align(alignment: const Alignment(-0.5, 0), child: tick(4)),
                Align(alignment: Alignment.center, child: tick(6)),
                Align(alignment: const Alignment(0.5, 0), child: tick(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top-right tabs ───────────────────────────────────────────────────────────

/// HUD / MENU switch. [HudTab.hud] shows the instrument view; [HudTab.nav]
/// opens the bento menu.
class TacticalTopTabs extends StatelessWidget {
  final HudTab activeTab;
  final ValueChanged<HudTab> onTabChanged;

  const TacticalTopTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tab('HUD', HudTab.hud),
        Container(
          width: 1,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: TacticalColors.ink.withValues(alpha: 0.3),
        ),
        _tab('MENU', HudTab.nav),
      ],
    );
  }

  Widget _tab(String label, HudTab tab) {
    final active = tab == activeTab;
    return GestureDetector(
      onTap: () => onTabChanged(tab),
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TacticalText.label(
          size: 10,
          bold: true,
          opacity: active ? 1.0 : 0.55,
        ),
      ),
    );
  }
}

// ─── Corner readouts ──────────────────────────────────────────────────────────

class TacticalCornerReadout extends StatelessWidget {
  final String text;
  const TacticalCornerReadout(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TacticalText.label(size: 8, opacity: 0.5));
  }
}

// ─── Details toggle + panel ───────────────────────────────────────────────────

/// Bottom-centre chevron that expands the details panel.
class TacticalDetailsToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const TacticalDetailsToggle({
    super.key,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedRotation(
            turns: expanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(Icons.keyboard_arrow_up_rounded,
                size: 24, color: TacticalColors.ink),
          ),
          const SizedBox(height: 4),
          Container(width: 48, height: 1, color: TacticalColors.ink.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}

/// Compact stats strip revealed above the toggle.
class TacticalDetailsPanel extends StatelessWidget {
  const TacticalDetailsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: TacticalColors.bg,
        border: Border.all(color: TacticalColors.ink, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _Stat(label: 'TRIP', value: '42.1KM'),
          _StatDivider(),
          _Stat(label: 'ETA', value: '14:32'),
          _StatDivider(),
          _Stat(label: 'FUEL', value: '68%'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TacticalText.label(size: 7, color: TacticalColors.dim)),
        const SizedBox(height: 3),
        Text(value, style: TacticalText.label(size: 11, bold: true)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        color: TacticalColors.ink.withValues(alpha: 0.15),
      );
}
