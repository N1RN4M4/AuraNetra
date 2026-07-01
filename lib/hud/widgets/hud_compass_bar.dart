import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';
import '../../core/hud_state.dart';

// Both the left spacer and right tab section share this width so the
// compass ruler is exactly centred between them.
const double _kTabsW = 114.0;

class HudCompassBar extends StatelessWidget {
  final double heading;
  final HudTab activeTab;
  final void Function(HudTab) onTabChanged;

  const HudCompassBar({
    super.key,
    required this.heading,
    required this.activeTab,
    required this.onTabChanged,
  });

  String _headingLabel() {
    final n = ((heading % 360) + 360) % 360;
    if (n < 7 || n > 353) return 'N';
    if ((n - 45).abs() < 7) return 'NE';
    if ((n - 90).abs() < 7) return 'E';
    if ((n - 135).abs() < 7) return 'SE';
    if ((n - 180).abs() < 7) return 'S';
    if ((n - 225).abs() < 7) return 'SW';
    if ((n - 270).abs() < 7) return 'W';
    if ((n - 315).abs() < 7) return 'NW';
    return '${n.round()}°';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          // Mirror spacer — keeps compass ruler centred
          const SizedBox(width: _kTabsW),

          // Compass ruler — centred in remaining space
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RulerPainter(heading: heading, accent: HudColors.cyan),
                  ),
                ),
                // Center indicator line
                Positioned(
                  top: 0, bottom: 18, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      width: 1.5,
                      decoration: BoxDecoration(
                        color: HudColors.cyan,
                        boxShadow: [BoxShadow(color: HudColors.cyan.withValues(alpha: 0.6), blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
                // Heading label
                Positioned(
                  bottom: 2, left: 0, right: 0,
                  child: Center(
                    child: Text(
                      _headingLabel(),
                      style: HudText.label.copyWith(color: HudColors.cyan, fontSize: 11, letterSpacing: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // NAV / HUD / STATS tab chips — same width as left spacer
          SizedBox(
            width: _kTabsW,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _TabChip(label: 'MENU', tab: HudTab.nav,  activeTab: activeTab, onTap: onTabChanged),
                  const SizedBox(width: 4),
                  _TabChip(label: 'HUD',  tab: HudTab.hud,  activeTab: activeTab, onTap: onTabChanged),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final HudTab tab;
  final HudTab activeTab;
  final void Function(HudTab) onTap;

  const _TabChip({
    required this.label,
    required this.tab,
    required this.activeTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tab == activeTab;
    return GestureDetector(
      onTap: () => onTap(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? HudColors.cyan.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: HudColors.cyan.withValues(alpha: isActive ? 0.65 : 0.22),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: HudText.label.copyWith(
            fontSize: 9,
            color: isActive ? HudColors.cyan : HudColors.dimCyan,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RulerPainter extends CustomPainter {
  final double heading;
  final Color accent;

  // 5.5 logical pixels per degree — on a 600px screen shows ≈109° range
  static const double _pxPerDeg = 5.5;

  static const _cardinals = {
    0: 'N', 45: 'NE', 90: 'E', 135: 'SE',
    180: 'S', 225: 'SW', 270: 'W', 315: 'NW',
  };

  // Instance getter — picks up dynamic accent color and secondary font
  TextStyle get _tickLabelStyle => HudThemeState.buildSecondary().copyWith(
    fontSize: 8,
    color: accent,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  const _RulerPainter({required this.heading, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height * 0.40;
    final cx = size.width / 2;
    final halfRange = (size.width / _pxPerDeg) / 2 + 5;

    canvas.drawLine(
      Offset(0, cy),
      Offset(size.width, cy),
      Paint()..color = accent.withValues(alpha: 0.25)..strokeWidth = 1,
    );

    for (double deg = heading - halfRange; deg <= heading + halfRange; deg++) {
      final x = cx + (deg - heading) * _pxPerDeg;
      if (x < -10 || x > size.width + 10) continue;

      final norm  = ((deg % 360) + 360) % 360;
      final normI = norm.round() % 360;

      final isCardinal = normI % 45 == 0;
      final isMajor    = normI % 10 == 0;
      final isMinor    = normI % 5  == 0;

      if (!isMinor) continue;

      final tickLen = isCardinal ? 17.0 : (isMajor ? 10.0 : 5.0);
      final strokeW = isCardinal ? 1.6  : (isMajor ?  1.0 : 0.7);
      final color   = isCardinal ? accent : accent.withValues(alpha: 0.25);

      canvas.drawLine(
        Offset(x, cy),
        Offset(x, cy - tickLen),
        Paint()..color = color..strokeWidth = strokeW,
      );

      if (isCardinal && _cardinals.containsKey(normI)) {
        final tp = TextPainter(
          text: TextSpan(text: _cardinals[normI], style: _tickLabelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, cy - tickLen - tp.height - 1));
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) => true;
}
