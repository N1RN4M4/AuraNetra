import 'package:flutter/material.dart';
import '../../core/hud_theme.dart';

class HudEdgeBars extends StatefulWidget {
  final bool leftThreat;
  final bool rightThreat;
  final Animation<double>? hudAnimation;

  const HudEdgeBars({
    super.key,
    required this.leftThreat,
    required this.rightThreat,
    this.hudAnimation,
  });

  @override
  State<HudEdgeBars> createState() => _HudEdgeBarsState();
}

class _HudEdgeBarsState extends State<HudEdgeBars> with TickerProviderStateMixin {
  late final AnimationController _leftCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  late final AnimationController _rightCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _leftCtrl.dispose();
    _rightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = widget.hudAnimation;
    if (anim != null) {
      return AnimatedBuilder(
        animation: anim,
        builder: (context, _) {
          final t = anim.value.clamp(0.0, 1.0);
          return Stack(children: [
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(-(1 - t) * 20, 0),
                  child: _Bar(threat: widget.leftThreat, controller: _leftCtrl, isLeft: true),
                ),
              ),
            ),
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset((1 - t) * 20, 0),
                  child: _Bar(threat: widget.rightThreat, controller: _rightCtrl, isLeft: false),
                ),
              ),
            ),
          ]);
        },
      );
    }
    return Stack(
      children: [
        Positioned(left: 0, top: 0, bottom: 0,
          child: _Bar(threat: widget.leftThreat, controller: _leftCtrl, isLeft: true),
        ),
        Positioned(right: 0, top: 0, bottom: 0,
          child: _Bar(threat: widget.rightThreat, controller: _rightCtrl, isLeft: false),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final bool threat;
  final AnimationController controller;
  final bool isLeft;

  const _Bar({required this.threat, required this.controller, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final color = threat ? HudColors.red : HudColors.cyan;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final opacity = threat ? (0.35 + controller.value * 0.65) : 0.2;
        return Container(
          width: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [color.withValues(alpha: opacity), Colors.transparent],
            ),
          ),
          child: threat
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: color, size: 12),
                    const SizedBox(height: 4),
                    Text('!', style: HudText.label.copyWith(color: color, fontSize: 9)),
                  ],
                )
              : null,
        );
      },
    );
  }
}
