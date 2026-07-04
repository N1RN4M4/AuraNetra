import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  HudSettingsNotifier() : super(const HudSettings()) {
    _load();
  }

  static const _kPrimary = 'hud_primary_font';
  static const _kSecondary = 'hud_secondary_font';
  static const _kAccent = 'hud_accent_color';

  // Restore the last-saved configuration; falls back to defaults when unset.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = HudSettings(
      primaryFont: _enumByName(
          HudPrimaryFont.values, prefs.getString(_kPrimary), state.primaryFont),
      secondaryFont: _enumByName(
          HudSecondaryFont.values, prefs.getString(_kSecondary), state.secondaryFont),
      accentColor: _enumByName(
          HudAccentColor.values, prefs.getString(_kAccent), state.accentColor),
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrimary, state.primaryFont.name);
    await prefs.setString(_kSecondary, state.secondaryFont.name);
    await prefs.setString(_kAccent, state.accentColor.name);
  }

  static T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) =>
      values.firstWhere((e) => e.name == name, orElse: () => fallback);

  void setPrimaryFont(HudPrimaryFont f) {
    state = state.copyWith(primaryFont: f);
    _persist();
  }

  void setSecondaryFont(HudSecondaryFont f) {
    state = state.copyWith(secondaryFont: f);
    _persist();
  }

  void setAccentColor(HudAccentColor c) {
    state = state.copyWith(accentColor: c);
    _persist();
  }
}

final hudSettingsProvider =
    StateNotifierProvider<HudSettingsNotifier, HudSettings>((ref) {
  return HudSettingsNotifier();
});
