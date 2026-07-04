import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hud_theme.dart';
import '../../core/hud_state.dart';
import '../../core/hud_providers.dart';
import '../../menu/widgets/bento_menu.dart';
import '../tactical/tactical_theme.dart';
import '../tactical/tactical_frame.dart';
import '../tactical/tactical_core.dart';
import '../tactical/tactical_speedometer.dart';
import '../tactical/tactical_mini_map.dart';
import '../tactical/tactical_overlays.dart';

/// Simulated helmet micro-display canvas. Commercial motorcycle HUD modules
/// (e.g. EyeRide, CrossHelmet) project a small 4:3 / 16:9 panel a metre or two
/// in front of the eye, so the live UI is constrained to that ratio instead of
/// stretching to a phone's tall aspect. The letterboxed remainder of the phone
/// screen is free space for dev/debug controls. Switch to `4 / 3` for the
/// traditional VGA-style framing.
const double kHudAspectRatio = 16 / 9;

/// Draw a faint boundary around the canvas during development.
const bool kShowHudCanvasBorder = true;

/// The tactical HUD page. Composes the fixed frame, the instrument overlays and
/// the bento menu into a single stack. All instrument widgets live under
/// `lib/hud/tactical/`; this screen only wires state and layout.
class HudScreen extends ConsumerStatefulWidget {
  const HudScreen({super.key});

  @override
  ConsumerState<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends ConsumerState<HudScreen>
    with SingleTickerProviderStateMixin {
  HudTab _activeTab = HudTab.hud;
  bool _showDetails = false;

  // Drives the cross-fade between the HUD instruments and the bento menu.
  late final AnimationController _hudCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 1.0,
  );
  late final Animation<double> _hudFade = CurvedAnimation(
    parent: _hudCtrl,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  @override
  void dispose() {
    _hudCtrl.dispose();
    super.dispose();
  }

  void _setTab(HudTab tab) {
    setState(() {
      _activeTab = tab;
      if (tab != HudTab.hud) _showDetails = false;
    });
    tab == HudTab.hud ? _hudCtrl.forward() : _hudCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(hudSettingsProvider);
    HudThemeState.apply(settings);

    final hud = ref.watch(hudProvider);
    final panelOpen = _activeTab != HudTab.hud;

    return Scaffold(
      backgroundColor: TacticalColors.bg,
      // Constrain the live HUD to a helmet micro-display ratio (16:9 / 4:3);
      // the phone's extra screen area is letterboxed as dev dead-space.
      body: Center(
        child: AspectRatio(
          aspectRatio: kHudAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: kShowHudCanvasBorder
                  ? Border.all(
                      color: TacticalColors.ink.withValues(alpha: 0.25),
                    )
                  : null,
            ),
            child: ClipRect(
              child: Stack(
                children: [
                  // ── 0: Frame + dotted background ──────────────────────────────────
                  const Positioned.fill(
                    child: IgnorePointer(child: TacticalFrame()),
                  ),

                  // ── 1: Instrument overlays — fade out while the menu is open ──────
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: panelOpen,
                      child: FadeTransition(
                        opacity: _hudFade,
                        child: _InstrumentLayer(
                          hud: hud,
                          activeTab: _activeTab,
                          showDetails: _showDetails,
                          onTab: _setTab,
                          onToggleDetails: () =>
                              setState(() => _showDetails = !_showDetails),
                          onSpeed: (v) =>
                              ref.read(hudProvider.notifier).setSpeed(v),
                          onToggleLeft: () =>
                              ref.read(hudProvider.notifier).toggleLeftThreat(),
                          onToggleRight: () => ref
                              .read(hudProvider.notifier)
                              .toggleRightThreat(),
                        ),
                      ),
                    ),
                  ),

                  // ── 2: Bento menu overlay ─────────────────────────────────────────
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Positions every tactical instrument inside the frame. Stateless — all state
/// arrives via constructor, all interaction leaves via callbacks.
class _InstrumentLayer extends StatelessWidget {
  final HudState hud;
  final HudTab activeTab;
  final bool showDetails;
  final ValueChanged<HudTab> onTab;
  final VoidCallback onToggleDetails;
  final ValueChanged<double> onSpeed;
  final VoidCallback onToggleLeft;
  final VoidCallback onToggleRight;

  const _InstrumentLayer({
    required this.hud,
    required this.activeTab,
    required this.showDetails,
    required this.onTab,
    required this.onToggleDetails,
    required this.onSpeed,
    required this.onToggleLeft,
    required this.onToggleRight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Central core
        Center(child: TacticalCore(heading: hud.heading)),

        // Top-centre angled module + map scale
        const Align(alignment: Alignment(0, -0.92), child: TacticalTopModule()),
        const Align(alignment: Alignment(0, -0.66), child: TacticalMapScale()),

        // Top-right tabs
        Positioned(
          top: 18,
          right: 44,
          child: TacticalTopTabs(activeTab: activeTab, onTabChanged: onTab),
        ),

        // Peripheral warning zones (tap to toggle threat). Raised above the
        // vertical centre so they don't overlap the bottom-corner mini-map and
        // speedometer.
        Align(
          alignment: const Alignment(-0.92, -0.34),
          child: TacticalWarningZone(
            label: 'INCOMING_DANGER',
            active: hud.leftThreat,
            onTap: onToggleLeft,
          ),
        ),
        Align(
          alignment: const Alignment(0.92, -0.34),
          child: TacticalWarningZone(
            label: 'ZONE_PERIMETER',
            active: hud.rightThreat,
            onTap: onToggleRight,
          ),
        ),

        // Bottom-left mini map
        Positioned(
          left: 44,
          bottom: 52,
          child: TacticalMiniMap(heading: hud.heading),
        ),

        // Bottom-right speedometer
        Positioned(
          right: 44,
          bottom: 52,
          child: TacticalSpeedometer(speed: hud.speed),
        ),

        // Bottom-centre details toggle + panel
        Align(
          alignment: const Alignment(0, 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: showDetails
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: TacticalDetailsPanel(),
                      )
                    : const SizedBox.shrink(),
              ),
              TacticalDetailsToggle(
                expanded: showDetails,
                onTap: onToggleDetails,
              ),
            ],
          ),
        ),

        // Bottom corner readouts
        const Positioned(
          left: 36,
          bottom: 20,
          child: TacticalCornerReadout('SYS_READY // LINK_ESTABLISHED'),
        ),
        const Positioned(
          right: 36,
          bottom: 20,
          child: TacticalCornerReadout('LAT: 34.0522 N | LNG: 118.2437 W'),
        ),

        // Dev: thin speed control along the bottom edge
        Positioned(
          left: 200,
          right: 200,
          bottom: 4,
          child: Opacity(
            opacity: 0.35,
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 1.5,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: hud.speed,
                min: 0,
                max: 200,
                activeColor: TacticalColors.ink,
                inactiveColor: TacticalColors.dim,
                thumbColor: TacticalColors.ink,
                onChanged: onSpeed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
