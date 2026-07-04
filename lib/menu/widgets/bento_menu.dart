import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ─── Left nav — rotary dial ───────────────────────────────────────────────────
// A circular / rotary selector (à la the reference "Huly Dial" menu): the nav
// entries ride an arc whose centre is pushed off the left edge of the card. The
// entry swung to the arc's rightmost point (the vertical centre) is the active
// section — enlarged and lit — while its neighbours curve back toward the edge,
// shrinking and fading out. Drag vertically to spin the dial, or tap any entry
// to swing it into the centre.

class _NavEntry {
  final IconData icon;
  final String label;
  final String key;
  const _NavEntry(this.icon, this.label, this.key);
}

const List<_NavEntry> _navEntries = [
  _NavEntry(Icons.bar_chart_rounded, 'STATS', 'STATS'),
  _NavEntry(Icons.map_rounded, 'MAP', 'MAP'),
  _NavEntry(Icons.home_rounded, 'HOME', 'HOME'),
  _NavEntry(Icons.star_rounded, 'FAV', 'FAV'),
  _NavEntry(Icons.settings_rounded, 'SET', 'SET'),
  _NavEntry(Icons.camera_alt_outlined, 'AR', 'AR'),
  _NavEntry(Icons.headphones_rounded, 'BT', 'BT'),
];

class _LeftNav extends StatefulWidget {
  final String activeNav;
  final ValueChanged<String> onNavChanged;

  const _LeftNav({required this.activeNav, required this.onNavChanged});

  @override
  State<_LeftNav> createState() => _LeftNavState();
}

class _LeftNavState extends State<_LeftNav>
    with SingleTickerProviderStateMixin {
  // Arc geometry — a large radius with the centre pushed off the left edge
  // yields a gentle rotary sweep inside the narrow nav column.
  static const double _radius = 120;
  static const double _step = 0.36; // radians between adjacent entries
  static const double _maxAngle = 1.18; // cull entries swung past this

  double get _pxPerItem => _radius * _step;

  // Fractional index parked at the arc centre; round(_p) is the active entry.
  late double _p = _indexOf(widget.activeNav).toDouble();

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..addListener(() {
      final a = _anim;
      if (a != null) setState(() => _p = a.value);
    });
  Animation<double>? _anim;

  int _indexOf(String key) {
    final i = _navEntries.indexWhere((e) => e.key == key);
    return i < 0 ? 0 : i;
  }

  void _animateTo(double target) {
    _anim = Tween<double>(begin: _p, end: target).animate(
      CurvedAnimation(parent: _settle, curve: Curves.easeOutCubic),
    );
    _settle.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _LeftNav old) {
    super.didUpdateWidget(old);
    // Keep the dial in sync when the active section is changed elsewhere
    // (e.g. the menu re-opening resets it to STATS).
    final target = _indexOf(widget.activeNav);
    if (target != _p.round()) _animateTo(target.toDouble());
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _settle.stop();
    setState(() {
      _p = (_p - d.delta.dy / _pxPerItem)
          .clamp(0.0, (_navEntries.length - 1).toDouble());
    });
  }

  void _onDragEnd(DragEndDetails d) => _select(_p.round());

  void _select(int index) {
    final i = index.clamp(0, _navEntries.length - 1);
    _animateTo(i.toDouble());
    final key = _navEntries[i].key;
    if (key != widget.activeNav) {
      HapticFeedback.selectionClick();
      widget.onNavChanged(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        children: [
          _profileChip(),
          const SizedBox(height: 6),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: _buildDial(c.maxWidth, c.maxHeight),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _rideButton(),
        ],
      ),
    );
  }

  Widget _buildDial(double w, double h) {
    final cx = w / 2 - _radius; // arc centre, off the left edge
    final cy = h / 2;

    final items = <Widget>[];
    for (int i = 0; i < _navEntries.length; i++) {
      final angle = (i - _p) * _step;
      if (angle.abs() > _maxAngle) continue;
      final x = cx + _radius * math.cos(angle);
      final y = cy + _radius * math.sin(angle);
      final t = (1 - angle.abs() / _maxAngle).clamp(0.0, 1.0);
      final active = angle.abs() < _step / 2;
      final e = _navEntries[i];
      items.add(Positioned(
        left: x - 30,
        top: y - 22,
        width: 60,
        height: 44,
        child: Opacity(
          opacity: (0.2 + 0.8 * t).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.7 + 0.34 * t,
            child: _NavIcon(
              icon: e.icon,
              label: e.label,
              active: active,
              onTap: () => _select(i),
            ),
          ),
        ),
      ));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _DialArcPainter(center: Offset(cx, cy), radius: _radius),
        ),
        ...items,
      ],
    );
  }

  Widget _profileChip() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
      ],
    );
  }

  Widget _rideButton() {
    return _NavIcon(
      icon: Icons.sports_motorsports_rounded,
      label: 'RIDE',
      active: false,
      onTap: () => widget.onNavChanged('RIDE'),
    );
  }
}

/// Draws the rotary guide: the concentric arc rails the entries ride on, plus a
/// soft glow node parked at the arc's rightmost point (the active slot).
class _DialArcPainter extends CustomPainter {
  final Offset center;
  final double radius;
  const _DialArcPainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const sweep = 2.4; // radians of arc kept visible
    const start = -sweep / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      Paint()
        ..color = HudColors.dimCyan.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 16),
      start,
      sweep,
      false,
      Paint()
        ..color = HudColors.dimCyan.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Active-slot glow at angle 0 (the arc's rightmost point).
    final node = Offset(center.dx + radius, center.dy);
    canvas.drawCircle(
      node,
      22,
      Paint()..color = HudColors.cyan.withValues(alpha: 0.06),
    );
  }

  @override
  bool shouldRepaint(_DialArcPainter old) =>
      old.center != center || old.radius != radius;
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
      physics: const AlwaysScrollableScrollPhysics(),
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
