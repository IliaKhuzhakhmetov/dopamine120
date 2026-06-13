import 'dart:async';
import 'dart:math' as math;

import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';

class ImaginationIconAnimationController {
  ImaginationIconAnimationController();

  static const _frameCount = 4;
  static const _frameDuration = Duration(milliseconds: 750);

  final ValueNotifier<int> step = ValueNotifier<int>(0);
  Timer? _timer;

  void play() {
    _timer?.cancel();
    step.value = 1;

    _timer = Timer.periodic(_frameDuration, (timer) {
      final nextStep = step.value + 1;
      if (nextStep > _frameCount) {
        step.value = 0;
        timer.cancel();
        return;
      }

      step.value = nextStep;
    });
  }

  void dispose() {
    _timer?.cancel();
    step.dispose();
  }
}

class ImaginationIconAnimation extends StatelessWidget {
  const ImaginationIconAnimation({
    super.key,
    required this.controller,
    this.size = 62,
  });

  final ImaginationIconAnimationController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.step,
      builder: (context, step, _) {
        final asset = _assetForStep(step);
        final motion = _IconMotion.forStep(step);

        return SizedBox.square(
          dimension: size,
          child: TweenAnimationBuilder<double>(
            key: ValueKey('imagination-icon-motion-$step'),
            tween: Tween(begin: 0, end: 1),
            duration: step == 0
                ? const Duration(milliseconds: 360)
                : ImaginationIconAnimationController._frameDuration,
            curve: Curves.linear,
            builder: (context, value, _) {
              final phase = math.sin(value * math.pi);
              final outward = Curves.easeOutCubic.transform(value);
              final color = Color.lerp(
                context.colors.ink,
                context.colors.accent,
                motion.accent * phase,
              )!;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (step != 0)
                    Transform.scale(
                      scale: 0.7 + outward * 0.52,
                      child: Opacity(
                        opacity: motion.halo * (1 - outward),
                        child: Container(
                          width: size * 0.92,
                          height: size * 0.92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.accent.withValues(
                              alpha: 0.08,
                            ),
                            border: Border.all(
                              color: context.colors.accent.withValues(
                                alpha: 0.32,
                              ),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(
                      motion.drift * math.sin(value * math.pi * 2),
                      -motion.lift * phase,
                    ),
                    child: Transform.rotate(
                      angle: motion.turns * phase * math.pi,
                      child: Transform.scale(
                        scale: 1 + motion.scale * phase,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.88,
                                  end: 1,
                                ).animate(animation),
                                child: RotationTransition(
                                  turns: Tween<double>(
                                    begin: -0.018,
                                    end: 0,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: asset.svg(
                            key: ValueKey('imagination-icon-frame-$step'),
                            width: size,
                            height: size,
                            colorFilter: ColorFilter.mode(
                              color,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  SvgGenImage _assetForStep(int step) {
    return switch (step) {
      1 => Assets.icons.imagination.frame01,
      2 => Assets.icons.imagination.frame02,
      3 => Assets.icons.imagination.frame03,
      4 => Assets.icons.imagination.frame04,
      _ => Assets.icons.imaginationBlob,
    };
  }
}

class _IconMotion {
  const _IconMotion({
    required this.lift,
    required this.drift,
    required this.turns,
    required this.scale,
    required this.accent,
    required this.halo,
  });

  final double lift;
  final double drift;
  final double turns;
  final double scale;
  final double accent;
  final double halo;

  static _IconMotion forStep(int step) {
    return switch (step) {
      1 => const _IconMotion(
        lift: 5,
        drift: -1.5,
        turns: -0.035,
        scale: 0.08,
        accent: 0.28,
        halo: 0.18,
      ),
      2 => const _IconMotion(
        lift: 8,
        drift: 2.5,
        turns: 0.05,
        scale: 0.13,
        accent: 0.48,
        halo: 0.24,
      ),
      3 => const _IconMotion(
        lift: 6,
        drift: -2,
        turns: -0.04,
        scale: 0.1,
        accent: 0.4,
        halo: 0.2,
      ),
      4 => const _IconMotion(
        lift: 3,
        drift: 1,
        turns: 0.025,
        scale: 0.06,
        accent: 0.24,
        halo: 0.14,
      ),
      _ => const _IconMotion(
        lift: 0,
        drift: 0,
        turns: 0,
        scale: 0,
        accent: 0,
        halo: 0,
      ),
    };
  }
}
