import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'tactical_theme.dart';

/// Bottom-left tactical mini-map. Shows live Google Map content, framed as a
/// rounded square with a black border to match the instrument panel.
///
/// Navigation-style framing: tight zoom + tilt give a 3D "driver" view that
/// rotates to the travel heading, like Google Maps turn-by-turn.
class TacticalMiniMap extends StatefulWidget {
  final double size;

  /// Compass heading (degrees) the map rotates to. Fed from the HUD's
  /// simulated heading so the view rotates even while the device is stationary.
  final double heading;

  const TacticalMiniMap({super.key, this.size = 132, this.heading = 0});

  @override
  State<TacticalMiniMap> createState() => _TacticalMiniMapState();
}

class _TacticalMiniMapState extends State<TacticalMiniMap> {
  GoogleMapController? _ctrl;
  StreamSubscription<Position>? _posSub;
  bool _locationGranted = false;
  bool _streamAttached = false;

  // Navigation-style framing: tight zoom + tilt for a 3D "driver" view.
  static const double _kNavZoom = 17.5;
  static const double _kNavTilt = 55.0;

  static const _kInitial = CameraPosition(
    target: LatLng(51.5074, -0.1278),
    zoom: _kNavZoom,
    tilt: _kNavTilt,
  );

  // Last known location; the map re-centres here while rotating to `heading`.
  LatLng _target = const LatLng(51.5074, -0.1278);

  // Heading last pushed to the native map. The HUD ticks heading ~10×/s, but
  // we only issue a camera move once it has turned enough to be visible — this
  // keeps platform-channel traffic (and jank) down.
  double _appliedHeading = 0;
  static const double _kHeadingEpsilon = 2.0; // degrees

  CameraPosition get _cam => CameraPosition(
        target: _target,
        zoom: _kNavZoom,
        tilt: _kNavTilt,
        bearing: widget.heading,
      );

  void _moveTo(CameraPosition cam) {
    _appliedHeading = widget.heading;
    _ctrl?.moveCamera(CameraUpdate.newCameraPosition(cam));
  }

  bool get _headingTurnedEnough {
    final d = (widget.heading - _appliedHeading).abs() % 360;
    final diff = d > 180 ? 360 - d : d;
    return diff >= _kHeadingEpsilon;
  }

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
    final granted = perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
    if (!mounted || !granted) return;
    setState(() => _locationGranted = true);
    _maybeAttachStream();
  }

  Future<void> _maybeAttachStream() async {
    if (_streamAttached || _ctrl == null || !_locationGranted) return;
    _streamAttached = true;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      _target = LatLng(pos.latitude, pos.longitude);
      _moveTo(_cam);
    } catch (_) {}

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      _target = LatLng(pos.latitude, pos.longitude);
      _moveTo(_cam);
    });
  }

  void _onMapCreated(GoogleMapController ctrl) {
    _ctrl = ctrl;
    _moveTo(_cam);
    _maybeAttachStream();
  }

  @override
  void didUpdateWidget(covariant TacticalMiniMap old) {
    super.didUpdateWidget(old);
    // Rotate to the latest heading, but only once it has turned enough to see.
    if (old.heading != widget.heading && _headingTurnedEnough) {
      _moveTo(_cam);
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    const radius = 14.0;
    // Extra height rendered below the visible frame so the Google logo /
    // attribution (anchored to the map's bottom edge) is clipped off.
    const logoStrip = 26.0;

    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: s,
              maxWidth: s,
              minHeight: s + logoStrip,
              maxHeight: s + logoStrip,
              child: GoogleMap(
                initialCameraPosition: _kInitial,
                onMapCreated: _onMapCreated,
                style: tacticalMapStyle,
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

          // Black frame ring drawn above the platform view
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: const _FramePainter(radius: radius)),
            ),
          ),

          Positioned(
            top: 6,
            left: 8,
            child: Text('MAP_V2.0',
                style: TacticalText.label(size: 8, bold: true)),
          ),
        ],
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final double radius;
  const _FramePainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()
        ..color = TacticalColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => oldDelegate.radius != radius;
}
