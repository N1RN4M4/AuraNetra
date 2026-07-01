import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';
import '../views/map_view.dart';
import '../views/home_view.dart';
import '../views/fav_view.dart';
import '../views/settings_view.dart';
import '../views/ar_view.dart';
import '../views/bt_view.dart';
import 'shared_widgets.dart';

class HudBentoMenu extends StatefulWidget {
  final bool open;
  final VoidCallback onClose;

  const HudBentoMenu({super.key, required this.open, required this.onClose});

  @override
  State<HudBentoMenu> createState() => _HudBentoMenuState();
}

class _HudBentoMenuState extends State<HudBentoMenu> with TickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final AnimationController _exitCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  bool _isExiting = false;
  String _activeNav = 'STATS';

  Animation<Offset> _slide(double start, Offset from) => Tween<Offset>(
        begin: from,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, (start + 0.6).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));

  @override
  void initState() {
    super.initState();
    if (widget.open) _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant HudBentoMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      if (widget.open) {
        _isExiting = false;
        _exitCtrl.value = 0;
        _ctrl.forward(from: 0);
        setState(() => _activeNav = 'STATS');
      } else {
        _isExiting = true;
        _exitCtrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Widget _slide_(Widget child, double stagger, Offset from) {
    return SlideTransition(
      position: _slide(stagger, from),
      child: child,
    );
  }

  Widget _panelSlide(Widget child, double stagger, Offset enterFrom, Offset exitTo) {
    if (_isExiting) {
      return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: exitTo).animate(
          CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic),
        ),
        child: child,
      );
    }
    return _slide_(child, stagger, enterFrom);
  }

  void _handleNavTap(String nav) {
    if (nav == 'RIDE') {
      widget.onClose();
    } else {
      setState(() => _activeNav = nav);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF2030D14),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: LayoutBuilder(builder: (context, cs) {
        final leftW  = (cs.maxWidth * 0.11).clamp(78.0, 100.0);
        final rightW = (cs.maxWidth * 0.21).clamp(145.0, 185.0);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _panelSlide(
              SizedBox(
                  width: leftW,
                  child: _LeftNav(activeNav: _activeNav, onNavChanged: _handleNavTap)),
              0.00, const Offset(-0.15, 0), const Offset(-1.5, 0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _panelSlide(
                _HeroCard(onClose: widget.onClose, activeNav: _activeNav),
                0.10, const Offset(0, -0.06), const Offset(0, -1.5),
              ),
            ),
            const SizedBox(width: 10),
            _panelSlide(
              SizedBox(width: rightW, child: _RightColumn()),
              0.20, const Offset(0.15, 0), const Offset(1.5, 0),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Shared bento card ────────────────────────────────────────────────────────

class _BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? glowColor;

  const _BentoCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF07101A),
        border: Border.all(color: HudColors.panelBorder, width: 1),
        borderRadius: BorderRadius.circular(18),
        boxShadow: glowColor != null
            ? [BoxShadow(
                color: glowColor!.withValues(alpha: 0.07),
                blurRadius: 14,
                spreadRadius: 1)]
            : null,
      ),
      child: child,
    );
  }
}

// ─── Left nav ────────────────────────────────────────────────────────────────

class _LeftNav extends StatelessWidget {
  final String activeNav;
  final ValueChanged<String> onNavChanged;

  const _LeftNav({required this.activeNav, required this.onNavChanged});

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavIcon(icon: Icons.bar_chart_rounded, label: 'STATS',
                active: activeNav == 'STATS', onTap: () => onNavChanged('STATS')),
            const SizedBox(height: 4),
            _NavIcon(icon: Icons.map_rounded, label: 'MAP',
                active: activeNav == 'MAP', onTap: () => onNavChanged('MAP')),
            const SizedBox(height: 4),
            _NavIcon(icon: Icons.home_rounded, label: 'HOME',
                active: activeNav == 'HOME', onTap: () => onNavChanged('HOME')),
            const SizedBox(height: 4),
            _NavIcon(icon: Icons.star_rounded, label: 'FAV',
                active: activeNav == 'FAV', onTap: () => onNavChanged('FAV')),
            const SizedBox(height: 4),
            _NavIcon(icon: Icons.settings_rounded, label: 'SET',
                active: activeNav == 'SET', onTap: () => onNavChanged('SET')),
            const SizedBox(height: 14),
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: HudColors.panelBorder, width: 1.5),
                color: HudColors.panelFill,
              ),
              child: Icon(Icons.person_rounded, color: HudColors.dimCyan, size: 20),
            ),
            const SizedBox(height: 4),
            Text('RIDER',
                style: HudText.label
                    .copyWith(fontSize: 7, letterSpacing: 2, color: HudColors.dimCyan)),
            const SizedBox(height: 14),
            _NavIcon(icon: Icons.camera_alt_outlined, label: 'AR',
                active: activeNav == 'AR', onTap: () => onNavChanged('AR')),
            const SizedBox(height: 4),
            _NavIcon(icon: Icons.headphones_rounded, label: 'BT',
                active: activeNav == 'BT', onTap: () => onNavChanged('BT')),
            const SizedBox(height: 4),
            _NavIcon(icon: Icons.sports_motorsports_rounded, label: 'RIDE',
                active: false, onTap: () => onNavChanged('RIDE')),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? HudColors.cyan : HudColors.dimCyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: active
            ? BoxDecoration(
                color: HudColors.cyan.withValues(alpha: 0.1),
                border: Border.all(
                    color: HudColors.cyan.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18,
                shadows: active
                    ? [Shadow(
                        color: HudColors.cyan.withValues(alpha: 0.8), blurRadius: 8)]
                    : null),
            const SizedBox(height: 2),
            Text(label,
                style: HudText.label.copyWith(
                    color: color, fontSize: 6, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

// ─── Center hero card ─────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final VoidCallback onClose;
  final String activeNav;

  const _HeroCard({required this.onClose, required this.activeNav});

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      glowColor: HudColors.cyan,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          Expanded(child: _buildBody()),
          if (activeNav == 'STATS') ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatBadge(label: 'AVG SPEED', value: '87',   unit: 'KM/H', color: HudColors.cyan),
                StatBadge(label: 'DISTANCE',  value: '42.1', unit: 'KM',   color: HudColors.green),
                StatBadge(label: 'ETA',       value: '14:32',unit: '',     color: HudColors.amber),
                StatBadge(label: 'FUEL',      value: '68',   unit: '%',    color: HudColors.amber),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    switch (activeNav) {
      case 'MAP':
        return _SectionHeader(title: 'MAP EXPLORER', icon: Icons.map_rounded);
      case 'HOME':
        return _SectionHeader(title: 'HOME BASE', icon: Icons.home_rounded);
      case 'FAV':
        return _SectionHeader(title: 'FAVORITES', icon: Icons.star_rounded);
      case 'SET':
        return _SectionHeader(title: 'SETTINGS', icon: Icons.settings_rounded);
      case 'AR':
        return _SectionHeader(title: 'AR OVERLAY', icon: Icons.camera_alt_outlined);
      case 'BT':
        return _SectionHeader(title: 'BLUETOOTH', icon: Icons.headphones_rounded);
      case 'STATS':
        return Row(
          children: [
            Text('TRIP STATS',
                style: HudText.label
                    .copyWith(color: HudColors.cyan, fontSize: 9, letterSpacing: 3)),
            const Spacer(),
            const _Tab(label: 'ROUTE', active: true),
            const SizedBox(width: 6),
            _Tab(label: 'HUD', onTap: onClose),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBody() {
    switch (activeNav) {
      case 'MAP':    return const MapBodyView();
      case 'HOME':   return const HomeBodyView();
      case 'FAV':    return const FavBodyView();
      case 'SET':    return const SettingsBodyView();
      case 'AR':     return const ArBodyView();
      case 'BT':     return const BluetoothBodyView();
      case 'STATS':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
              painter: const _RoutePainter(), child: const SizedBox.expand()),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: HudColors.cyan, size: 14,
            shadows: [Shadow(color: HudColors.cyan, blurRadius: 8)]),
        const SizedBox(width: 6),
        Text(title,
            style: HudText.label
                .copyWith(color: HudColors.cyan, fontSize: 9, letterSpacing: 3)),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _Tab({required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: active
            ? BoxDecoration(
                color: HudColors.cyan.withValues(alpha: 0.12),
                border: Border.all(
                    color: HudColors.cyan.withValues(alpha: 0.4), width: 1),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Text(label,
            style: HudText.label.copyWith(
                color: active ? HudColors.cyan : HudColors.dimCyan,
                fontSize: 8,
                letterSpacing: 1)),
      ),
    );
  }
}

// ─── Route painter ────────────────────────────────────────────────────────────

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF040D16));

    final g = Paint()
      ..color = HudColors.dimCyan.withValues(alpha: 0.07)
      ..strokeWidth = 0.5;
    for (int i = 1; i < 7; i++) {
      canvas.drawLine(Offset(size.width * i / 6, 0),
          Offset(size.width * i / 6, size.height), g);
      canvas.drawLine(Offset(0, size.height * i / 6),
          Offset(size.width, size.height * i / 6), g);
    }

    final route = Path()
      ..moveTo(size.width * 0.08, size.height * 0.92)
      ..cubicTo(size.width * 0.18, size.height * 0.62,
          size.width * 0.38, size.height * 0.72,
          size.width * 0.48, size.height * 0.42)
      ..cubicTo(size.width * 0.58, size.height * 0.14,
          size.width * 0.74, size.height * 0.30,
          size.width * 0.92, size.height * 0.10);

    canvas.drawPath(
        route,
        Paint()
          ..color = HudColors.cyan.withValues(alpha: 0.18)
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawPath(
        route,
        Paint()
          ..color = HudColors.dimCyan.withValues(alpha: 0.4)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    final done = Path()
      ..moveTo(size.width * 0.08, size.height * 0.92)
      ..cubicTo(size.width * 0.18, size.height * 0.62,
          size.width * 0.38, size.height * 0.72,
          size.width * 0.48, size.height * 0.42);
    canvas.drawPath(
        done,
        Paint()
          ..color = HudColors.green
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.92), 5,
        Paint()..color = HudColors.green);

    final pos = Offset(size.width * 0.48, size.height * 0.42);
    canvas.drawCircle(pos, 10, Paint()..color = HudColors.cyan.withValues(alpha: 0.2));
    canvas.drawCircle(pos, 4.5, Paint()..color = HudColors.cyan);
    canvas.drawCircle(
        pos,
        10,
        Paint()
          ..color = HudColors.cyan.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    final dest = Offset(size.width * 0.92, size.height * 0.10);
    canvas.drawCircle(dest, 10, Paint()..color = HudColors.amber.withValues(alpha: 0.2));
    canvas.drawCircle(dest, 5, Paint()..color = HudColors.amber);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => true;
}

// ─── Right column ─────────────────────────────────────────────────────────────

class _RightColumn extends StatelessWidget {
  const _RightColumn();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 145,
            child: _BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEXT STOP',
                      style: HudText.label.copyWith(
                          fontSize: 8, letterSpacing: 2, color: HudColors.dimCyan)),
                  const Spacer(),
                  Text('8',
                      style: HudText.speedDigits.copyWith(
                          fontSize: 52,
                          color: HudColors.cyan,
                          shadows: [
                            Shadow(
                                color: HudColors.cyan.withValues(alpha: 0.5),
                                blurRadius: 18)
                          ])),
                  Text('KILOMETERS',
                      style: HudText.label
                          .copyWith(fontSize: 7, color: HudColors.dimCyan)),
                  const SizedBox(height: 4),
                  Text('HWY A1 → MAIN ST',
                      style: HudText.label
                          .copyWith(fontSize: 7, color: HudColors.green),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: _BentoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_rounded, color: HudColors.cyan, size: 26,
                      shadows: [Shadow(color: HudColors.cyan, blurRadius: 12)]),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SENA MESH',
                          style: HudText.label
                              .copyWith(color: HudColors.cyan, fontSize: 10)),
                      const SizedBox(height: 3),
                      Text('CONNECTED',
                          style: HudText.label.copyWith(
                              color: HudColors.green,
                              fontSize: 7,
                              letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: _BentoCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(
                    painter: const _RoutePainter(),
                    child: const SizedBox.expand()),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: _BentoCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.music_note_rounded,
                        color: HudColors.dimCyan, size: 11),
                    const SizedBox(width: 4),
                    Text('NOW PLAYING',
                        style: HudText.label.copyWith(
                            color: HudColors.dimCyan,
                            fontSize: 7,
                            letterSpacing: 1)),
                  ]),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riding in Style',
                          style: HudText.label
                              .copyWith(color: HudColors.cyan, fontSize: 11)),
                      Text('The Riders',
                          style: HudText.label
                              .copyWith(color: HudColors.dimCyan, fontSize: 8)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.skip_previous_rounded,
                          color: HudColors.dimCyan, size: 18),
                      const SizedBox(width: 10),
                      Icon(Icons.pause_circle_filled_rounded,
                          color: HudColors.cyan, size: 26),
                      const SizedBox(width: 10),
                      Icon(Icons.skip_next_rounded,
                          color: HudColors.dimCyan, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings re-export (ConsumerWidget needs riverpod) ───────────────────────
// SettingsBodyView is in settings_view.dart — imported above for use in _HeroCard.
