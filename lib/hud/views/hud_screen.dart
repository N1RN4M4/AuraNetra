import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/hud_theme.dart';
import '../../core/hud_state.dart';
import '../../core/hud_providers.dart';
import '../widgets/hud_compass_bar.dart';
import '../widgets/hud_edge_bars.dart';
import '../widgets/hud_bottom_bar.dart';
import '../../menu/widgets/bento_menu.dart';

const double _kCompassH = 50;
const double _kToggleH  = 30;

class HudScreen extends ConsumerStatefulWidget {
  const HudScreen({super.key});

  @override
  ConsumerState<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends ConsumerState<HudScreen> with TickerProviderStateMixin {
  CameraController? _cam;
  bool _camReady   = false;
  String? _camError;
  bool _showDetails = false;
  HudTab _activeTab = HudTab.hud;

  late final AnimationController _hudCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 440),
  );

  // Derived animations — entry curves for forward, exit for reverse
  late final Animation<double> _hudFade = CurvedAnimation(
    parent: _hudCtrl, curve: Curves.easeOut, reverseCurve: Curves.easeIn,
  );
  late final Animation<Offset> _bottomSlide = Tween<Offset>(
    begin: const Offset(0, 1.0), end: Offset.zero,
  ).animate(CurvedAnimation(parent: _hudCtrl, curve: Curves.easeOutCubic));
  late final Animation<Offset> _topSlide = Tween<Offset>(
    begin: const Offset(0, -1.0), end: Offset.zero,
  ).animate(CurvedAnimation(parent: _hudCtrl, curve: Curves.easeOutCubic));
  late final Animation<double> _topScale = Tween<double>(
    begin: 0.88, end: 1.0,
  ).animate(CurvedAnimation(parent: _hudCtrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _hudCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _cam?.dispose();
    _hudCtrl.dispose();
    super.dispose();
  }

  // ── Camera ────────────────────────────────────────────────────────────────

  Future<void> _enableAR() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _camError = 'Camera permission denied — grant in Settings');
      ref.read(arModeProvider.notifier).state = false;
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _camError = 'No camera available');
      ref.read(arModeProvider.notifier).state = false;
      return;
    }
    final cam = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final ctrl = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
    await ctrl.initialize();
    if (mounted) setState(() { _cam = ctrl; _camReady = true; _camError = null; });
  }

  Future<void> _disableAR() async {
    await _cam?.dispose();
    if (mounted) setState(() { _cam = null; _camReady = false; _camError = null; });
  }

  void _setTab(HudTab tab) {
    setState(() {
      _activeTab = tab;
      if (tab != HudTab.hud) _showDetails = false;
    });
    if (tab == HudTab.hud) {
      _hudCtrl.forward();
    } else {
      _hudCtrl.reverse();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(hudSettingsProvider);
    HudThemeState.apply(settings);
    final hud     = ref.watch(hudProvider);
    final arMode  = ref.watch(arModeProvider);
    final kBottomBarH = (MediaQuery.of(context).size.height * 0.52).clamp(165.0, 240.0);
    final panelOpen = _activeTab != HudTab.hud;

    return Scaffold(
      backgroundColor: HudColors.background,
      body: Stack(
        children: [

          // ── 0: World / camera background ──────────────────────────────────
          Positioned.fill(
            child: (arMode && _camReady && _cam != null)
                ? CameraPreview(_cam!)
                : const ColoredBox(color: HudColors.background),
          ),

          // ── 1: All HUD widgets — individual directional animations ──────────
          Positioned.fill(
            child: IgnorePointer(
              ignoring: panelOpen,
              child: Stack(
                children: [

                  // Blind-spot edge bars — left slides from left, right from right
                  HudEdgeBars(
                    leftThreat: hud.leftThreat,
                    rightThreat: hud.rightThreat,
                    hudAnimation: _hudCtrl,
                  ),

                  // Bottom bar — rises from below
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: kBottomBarH,
                    child: SlideTransition(
                      position: _bottomSlide,
                      child: FadeTransition(
                        opacity: _hudFade,
                        child: HudBottomBar(
                          speed: hud.speed, rpm: hud.rpm, leanAngle: hud.leanAngle,
                          navDir: hud.navDir, navDist: hud.navDist, navStreet: hud.navStreet,
                        ),
                      ),
                    ),
                  ),

                  // Details popup — fades with HUD
                  Positioned(
                    bottom: _kToggleH + 8, left: 0, right: 0,
                    child: FadeTransition(
                      opacity: _hudFade,
                      child: Center(
                        child: AnimatedSlide(
                          offset: _showDetails ? Offset.zero : const Offset(0, 1.2),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            opacity: _showDetails ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: IgnorePointer(
                              ignoring: !_showDetails,
                              child: const _DetailsPanel(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Toggle tab — fades with HUD
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: FadeTransition(
                      opacity: _hudFade,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _showDetails = !_showDetails),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 54, height: _kToggleH,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _showDetails
                                  ? HudColors.cyan.withValues(alpha: 0.15)
                                  : const Color(0xCC030D14),
                              border: Border.all(
                                color: HudColors.cyan.withValues(alpha: _showDetails ? 0.6 : 0.3),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft:  Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: AnimatedRotation(
                              turns: _showDetails ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: Icon(Icons.keyboard_arrow_up_rounded,
                                  color: HudColors.cyan, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dev: speed slider
                  Positioned(
                    bottom: kBottomBarH + 2, left: 100, right: 100,
                    child: Opacity(
                      opacity: 0.3,
                      child: Slider(
                        value: hud.speed, min: 0, max: 200,
                        onChanged: (v) => ref.read(hudProvider.notifier).setSpeed(v),
                        activeColor: HudColors.cyan,
                        inactiveColor: HudColors.dimCyan,
                      ),
                    ),
                  ),

                  // Dev: threat + AR toggles
                  Positioned(top: _kCompassH + 8, left: 10,
                    child: _DevButton(active: hud.leftThreat,  label: 'L',
                        onTap: () => ref.read(hudProvider.notifier).toggleLeftThreat())),
                  Positioned(top: _kCompassH + 8, right: 10,
                    child: _DevButton(active: hud.rightThreat, label: 'R',
                        onTap: () => ref.read(hudProvider.notifier).toggleRightThreat())),
                  Positioned(top: _kCompassH + 46, left: 10,
                    child: _DevButton(
                      active: arMode, label: 'AR', activeColor: HudColors.green,
                      onTap: () async {
                        if (!arMode) {
                          ref.read(arModeProvider.notifier).state = true;
                          await _enableAR();
                        } else {
                          ref.read(arModeProvider.notifier).state = false;
                          await _disableAR();
                        }
                      },
                    )),

                  if (_camError != null)
                    Positioned(
                      top: _kCompassH + 84, left: 60, right: 60,
                      child: Text(_camError!,
                          style: HudText.label.copyWith(color: HudColors.red, fontSize: 9),
                          textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
          ),

          // ── 2: Bento menu — full-screen fade ────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !panelOpen,
              child: AnimatedOpacity(
                opacity: panelOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 350),
                child: HudBentoMenu(
                  open: panelOpen,
                  onClose: () => _setTab(HudTab.hud),
                ),
              ),
            ),
          ),

          // ── 3: Top bar — slides from top with HUD, hidden in menu ───────
          Positioned(
            top: 0, left: 0, right: 0, height: _kCompassH,
            child: IgnorePointer(
              ignoring: panelOpen,
              child: SlideTransition(
                position: _topSlide,
                child: ScaleTransition(
                  scale: _topScale,
                  alignment: Alignment.topCenter,
                  child: FadeTransition(
                    opacity: _hudFade,
                    child: Container(
                      color: const Color(0xE8030D14),
                      child: HudCompassBar(
                        heading: hud.heading,
                        activeTab: _activeTab,
                        onTabChanged: _setTab,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─── Details popup ─────────────────────────────────────────────────────────────

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xE6030D14),
        border: Border.all(color: HudColors.panelBorder, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: HudColors.cyan.withValues(alpha: 0.08), blurRadius: 14)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _StatRow(
            left:  _StatCell(label: 'TRIP', value: '42.1 KM', color: HudColors.cyan),
            right: _StatCell(label: 'ETA',  value: '14:32',   color: HudColors.green),
          ),
          const SizedBox(height: 10),
          _StatRow(
            left:  _StatCell(label: 'TEMP', value: '24°C',   color: HudColors.green),
            right: _StatCell(label: 'WIND', value: '12 KPH', color: HudColors.dimCyan),
          ),
          const SizedBox(height: 10),
          _StatCell(label: 'FUEL', value: '68%', color: HudColors.amber),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final _StatCell left, right;
  const _StatRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [left, const SizedBox(width: 20), right]);
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: HudText.label.copyWith(color: HudColors.dimCyan, fontSize: 9)),
        Text(value, style: HudText.label.copyWith(color: color, fontSize: 13)),
      ],
    );
  }
}

// ─── Dev button ────────────────────────────────────────────────────────────────

class _DevButton extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;
  final Color? activeColor;

  const _DevButton({required this.active, required this.label, required this.onTap, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? HudColors.red) : HudColors.dimCyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 26, alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(label, style: HudText.label.copyWith(color: color, fontSize: 9)),
      ),
    );
  }
}
