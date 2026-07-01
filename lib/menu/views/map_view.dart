import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/hud_theme.dart';
import '../widgets/shared_widgets.dart';

class MapBodyView extends StatefulWidget {
  const MapBodyView({super.key});

  @override
  State<MapBodyView> createState() => _MapBodyViewState();
}

class _MapBodyViewState extends State<MapBodyView> {
  GoogleMapController? _ctrl;
  bool _locationGranted = false;
  StreamSubscription<Position>? _posSub;
  LatLng? _position;

  static const _kInitialCamera = CameraPosition(
    target: LatLng(51.5074, -0.1278),
    zoom: 14,
  );

  CameraPosition _camera = _kInitialCamera;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    final granted =
        perm == LocationPermission.whileInUse || perm == LocationPermission.always;
    if (!mounted) return;
    setState(() => _locationGranted = granted);
    if (!granted) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      final ll = LatLng(pos.latitude, pos.longitude);
      _position = ll;
      _ctrl?.animateCamera(CameraUpdate.newLatLng(ll));
    } catch (_) {}

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      final ll = LatLng(pos.latitude, pos.longitude);
      _position = ll;
      _ctrl?.animateCamera(CameraUpdate.newLatLng(ll));
    });
  }

  void _onMapCreated(GoogleMapController ctrl) {
    _ctrl = ctrl;
    if (_position != null) {
      _ctrl?.animateCamera(CameraUpdate.newLatLng(_position!));
    }
  }

  void _onCameraMove(CameraPosition pos) {
    setState(() => _camera = pos);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lat     = _camera.target.latitude;
    final lon     = _camera.target.longitude;
    final zoom    = _camera.zoom;
    final bearing = _camera.bearing;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: _kInitialCamera,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            style: hudMapStyle,
            mapType: MapType.normal,
            compassEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: _locationGranted,
            myLocationButtonEnabled: _locationGranted,
          ),
          Positioned(
            top: 8, right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MapBadge(label: 'ZOOM',    value: '${zoom.toStringAsFixed(0)}×'),
                const SizedBox(height: 4),
                _MapBadge(label: 'BEARING', value: '${bearing.toStringAsFixed(0)}°'),
              ],
            ),
          ),
          Positioned(
            bottom: 8, left: 10, right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatBadge(
                  label: 'LAT', unit: lat >= 0 ? '°N' : '°S',
                  value: lat.abs().toStringAsFixed(4), color: HudColors.cyan,
                ),
                StatBadge(
                  label: 'LON', unit: lon >= 0 ? '°E' : '°W',
                  value: lon.abs().toStringAsFixed(4), color: HudColors.dimCyan,
                ),
                StatBadge(
                  label: 'ZOOM', unit: 'LVL',
                  value: zoom.toStringAsFixed(1), color: HudColors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  final String label, value;
  const _MapBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xCC030D14),
        border: Border.all(color: HudColors.panelBorder, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: '$label  ',
              style: HudText.label.copyWith(color: HudColors.dimCyan, fontSize: 7)),
          TextSpan(text: value,
              style: HudText.label.copyWith(color: HudColors.cyan, fontSize: 8)),
        ]),
      ),
    );
  }
}
