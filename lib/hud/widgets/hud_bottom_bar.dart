import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/hud_theme.dart';
import '../../core/hud_state.dart';
import 'speedometer_arc.dart';

class HudBottomBar extends StatelessWidget {
  final double speed;
  final double rpm;
  final double leanAngle;
  final TurnDir navDir;
  final int navDist;
  final String navStreet;

  const HudBottomBar({
    super.key,
    required this.speed,
    required this.rpm,
    required this.leanAngle,
    required this.navDir,
    required this.navDist,
    required this.navStreet,
  });

  @override
  Widget build(BuildContext context) {
    const double padTop = 10;
    const double padBottom = 36; // space for the drawer-handle toggle tab
    const double padH = padTop + padBottom;

    return LayoutBuilder(builder: (context, cs) {
      // All sizes are derived from the actual available height so nothing
      // overflows regardless of device screen size or orientation.
      final innerH = cs.maxHeight - padH;

      final speedoSize    = (innerH * 0.72).clamp(70.0, 140.0);
      final mapSize       = (innerH * 0.68).clamp(68.0, 130.0);
      final navIconSize   = (speedoSize * 0.17).clamp(14.0, 22.0);
      final navDistFont   = (speedoSize * 0.10).clamp(10.0, 14.0);
      final navStreetFont = (speedoSize * 0.065).clamp(7.0, 10.0);
      final navGap        = (innerH * 0.025).clamp(3.0, 8.0);
      final roadFont      = (mapSize * 0.11).clamp(8.0, 12.0);

      return Padding(
        padding: const EdgeInsets.fromLTRB(14, padTop, 14, padBottom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MapRow(mapSize: mapSize, roadFont: roadFont),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CompactNav(
                  direction: navDir,
                  distanceMeters: navDist,
                  streetName: navStreet,
                  iconSize: navIconSize,
                  distFontSize: navDistFont,
                  streetFontSize: navStreetFont,
                ),
                SizedBox(height: navGap),
                SpeedometerArc(
                  speed: speed,
                  rpm: rpm,
                  leanAngle: leanAngle,
                  size: speedoSize,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─── Left: map circle + road label ────────────────────────────────────────────

class _MapRow extends StatelessWidget {
  final double mapSize;
  final double roadFont;

  const _MapRow({required this.mapSize, required this.roadFont});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        HudMiniMap(size: mapSize),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ROAD', style: HudText.label.copyWith(color: HudColors.dimCyan, fontSize: roadFont * 0.82)),
            Text('DRY',  style: HudText.label.copyWith(color: HudColors.green,   fontSize: roadFont)),
          ],
        ),
      ],
    );
  }
}

class HudMiniMap extends StatefulWidget {
  final double size;
  const HudMiniMap({super.key, required this.size});

  @override
  State<HudMiniMap> createState() => _HudMiniMapState();
}

class _HudMiniMapState extends State<HudMiniMap> {
  GoogleMapController? _ctrl;
  StreamSubscription<Position>? _posSub;
  bool _locationGranted = false;
  bool _streamAttached = false;

  static const _kInitial = CameraPosition(
    target: LatLng(51.5074, -0.1278),
    zoom: 16,
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    final granted =
        perm == LocationPermission.whileInUse || perm == LocationPermission.always;
    if (!mounted) return;
    if (granted) {
      setState(() => _locationGranted = true);
      _maybeAttachStream();
    }
  }

  Future<void> _maybeAttachStream() async {
    if (_streamAttached || _ctrl == null || !_locationGranted) return;
    _streamAttached = true;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      _ctrl?.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
    } catch (_) {}

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      _ctrl?.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
    });
  }

  void _onMapCreated(GoogleMapController ctrl) {
    _ctrl = ctrl;
    _maybeAttachStream();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = widget.size;
    return SizedBox(
      width: sz, height: sz,
      child: Stack(
        children: [
          ClipOval(
            child: SizedBox(
              width: sz, height: sz,
              child: GoogleMap(
                initialCameraPosition: _kInitial,
                onMapCreated: _onMapCreated,
                style: hudMapStyle,
                compassEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                myLocationEnabled: _locationGranted,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          // Border ring — drawn in Flutter canvas above the platform view
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _RingPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width / 2 - 0.75, Paint()
      ..color = HudColors.panelBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}

// ─── Right: compact nav indicator ─────────────────────────────────────────────

class _CompactNav extends StatelessWidget {
  final TurnDir direction;
  final int distanceMeters;
  final String streetName;
  final double iconSize;
  final double distFontSize;
  final double streetFontSize;

  const _CompactNav({
    required this.direction,
    required this.distanceMeters,
    required this.streetName,
    required this.iconSize,
    required this.distFontSize,
    required this.streetFontSize,
  });

  IconData get _icon => switch (direction) {
        TurnDir.left       => Icons.turn_left_rounded,
        TurnDir.right      => Icons.turn_right_rounded,
        TurnDir.slightLeft => Icons.turn_slight_left_rounded,
        TurnDir.slightRight=> Icons.turn_slight_right_rounded,
        TurnDir.straight   => Icons.straight_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          _icon,
          color: HudColors.cyan,
          size: iconSize,
          shadows: [Shadow(color: HudColors.cyan, blurRadius: 10)],
        ),
        SizedBox(width: iconSize * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${distanceMeters}M',
              style: HudText.navDistance.copyWith(
                fontSize: distFontSize,
                shadows: [Shadow(color: HudColors.cyan.withValues(alpha: 0.7), blurRadius: 6)],
              ),
            ),
            Text(streetName, style: HudText.label.copyWith(fontSize: streetFontSize)),
          ],
        ),
      ],
    );
  }
}
