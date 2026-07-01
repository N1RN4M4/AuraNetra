import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'hud_settings.dart';
import 'hud_state.dart';

class HudStateNotifier extends StateNotifier<HudState> {
  HudStateNotifier() : super(const HudState()) {
    _startSensors();
    _startNavCycle();
    _startHeadingSimulation();
  }

  StreamSubscription<AccelerometerEvent>? _accelSub;
  Timer? _navTimer;
  Timer? _headingTimer;
  int _navIndex = 0;

  static const _navDemo = [
    (TurnDir.straight, 350, 'HIGHWAY A1'),
    (TurnDir.right, 200, 'MAIN ST'),
    (TurnDir.slightLeft, 80, 'BRIDGE RD'),
    (TurnDir.straight, 600, 'MOTORWAY M7'),
    (TurnDir.left, 120, 'PARK AVE'),
  ];

  void _startSensors() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((e) {
      final lean = (e.x / 9.8).clamp(-1.0, 1.0) * 45.0;
      state = state.copyWith(leanAngle: lean);
    });
  }

  void _startNavCycle() {
    _navTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _navIndex = (_navIndex + 1) % _navDemo.length;
      final (dir, dist, street) = _navDemo[_navIndex];
      state = state.copyWith(navDir: dir, navDist: dist, navStreet: street);
    });
  }

  // 0.5°/tick × 100ms = 5°/s → full rotation every 72 seconds
  void _startHeadingSimulation() {
    _headingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      state = state.copyWith(heading: (state.heading + 0.5) % 360.0);
    });
  }

  void setSpeed(double v) => state = state.copyWith(speed: v, rpm: v / 200.0);
  void toggleLeftThreat() => state = state.copyWith(leftThreat: !state.leftThreat);
  void toggleRightThreat() => state = state.copyWith(rightThreat: !state.rightThreat);

  @override
  void dispose() {
    _accelSub?.cancel();
    _navTimer?.cancel();
    _headingTimer?.cancel();
    super.dispose();
  }
}

final hudProvider = StateNotifierProvider<HudStateNotifier, HudState>((ref) {
  return HudStateNotifier();
});

final arModeProvider = StateProvider<bool>((ref) => false);

class HudSettingsNotifier extends StateNotifier<HudSettings> {
  HudSettingsNotifier() : super(const HudSettings());

  void setPrimaryFont(HudPrimaryFont f)     => state = state.copyWith(primaryFont: f);
  void setSecondaryFont(HudSecondaryFont f) => state = state.copyWith(secondaryFont: f);
  void setAccentColor(HudAccentColor c)     => state = state.copyWith(accentColor: c);
}

final hudSettingsProvider =
    StateNotifierProvider<HudSettingsNotifier, HudSettings>((ref) {
  return HudSettingsNotifier();
});
