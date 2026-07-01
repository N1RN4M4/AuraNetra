import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hud_theme.dart';
import '../../core/hud_settings.dart';
import '../../core/hud_providers.dart';

class SettingsBodyView extends ConsumerWidget {
  const SettingsBodyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(hudSettingsProvider);
    final notifier = ref.read(hudSettingsProvider.notifier);

    const sectionStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 7,
      letterSpacing: 2,
      color: Color(0x9900FFFF),
    );

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRIMARY FONT', style: sectionStyle.copyWith(color: HudColors.dimCyan)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: HudPrimaryFont.values
                .map((f) => _SettingChip(
                      label: f.displayName,
                      active: settings.primaryFont == f,
                      previewStyle: HudThemeState.buildPrimaryFor(f),
                      onTap: () => notifier.setPrimaryFont(f),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Text('SECONDARY FONT', style: sectionStyle.copyWith(color: HudColors.dimCyan)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: HudSecondaryFont.values
                .map((f) => _SettingChip(
                      label: f.displayName,
                      active: settings.secondaryFont == f,
                      previewStyle: HudThemeState.buildSecondaryFor(f),
                      onTap: () => notifier.setSecondaryFont(f),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Text('COLOR THEME', style: sectionStyle.copyWith(color: HudColors.dimCyan)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: HudAccentColor.values
                .map((c) => _ColorDot(
                      color: c.color,
                      label: c.label,
                      active: settings.accentColor == c,
                      onTap: () => notifier.setAccentColor(c),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  final String label;
  final bool active;
  final TextStyle previewStyle;
  final VoidCallback onTap;

  const _SettingChip({
    required this.label,
    required this.active,
    required this.previewStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? HudColors.cyan : HudColors.dimCyan;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? HudColors.cyan.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: active
                ? HudColors.cyan.withValues(alpha: 0.5)
                : HudColors.dimCyan.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: previewStyle.copyWith(fontSize: 9, color: color, letterSpacing: 1)),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: active ? 0.9 : 0.25),
              border: Border.all(color: color, width: active ? 2 : 1),
              boxShadow: active
                  ? [BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 8)]
                  : null,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 6,
              letterSpacing: 0.5,
              color: active ? color : HudColors.dimCyan,
            ),
          ),
        ],
      ),
    );
  }
}
