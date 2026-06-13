import 'dart:async';
import 'dart:math' as math;

import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';

class CreationIconAnimationController {
  CreationIconAnimationController();

  static const _frameCount = 4;
  static const _frameDuration = Duration(milliseconds: 360);

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

class CreationIconAnimation extends StatelessWidget {
  const CreationIconAnimation({
    super.key,
    required this.controller,
    this.size = 62,
  });

  final CreationIconAnimationController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.step,
      builder: (context, step, _) {
        final motion = _CreationMotion.forStep(step);
        final asset = Assets.icons.creationSpark;

        return SizedBox.square(
          dimension: size,
          child: TweenAnimationBuilder<double>(
            key: ValueKey('creation-icon-motion-$step'),
            tween: Tween(begin: 0, end: 1),
            duration: step == 0
                ? const Duration(milliseconds: 400)
                : CreationIconAnimationController._frameDuration,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              final phase = math.sin(value * math.pi);
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
                      scale: 0.68 + value * 0.44,
                      child: Opacity(
                        opacity: 0.22 * (1 - value),
                        child: Container(
                          width: size * 0.86,
                          height: size * 0.86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.accent.withValues(
                                alpha: 0.36,
                              ),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(motion.drift * phase, -motion.lift * phase),
                    child: Transform.rotate(
                      angle: motion.turns * phase * math.pi,
                      child: Transform.scale(
                        scale: 1 + motion.scale * phase,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 120),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          child: asset.svg(
                            key: ValueKey('creation-icon-frame-$step'),
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
}

class _CreationMotion {
  const _CreationMotion({
    required this.lift,
    required this.drift,
    required this.turns,
    required this.scale,
    required this.accent,
  });

  final double lift;
  final double drift;
  final double turns;
  final double scale;
  final double accent;

  static _CreationMotion forStep(int step) {
    return switch (step) {
      1 => const _CreationMotion(
        lift: 7,
        drift: -4,
        turns: -0.12,
        scale: 0.16,
        accent: 0.42,
      ),
      2 => const _CreationMotion(
        lift: 11,
        drift: 3,
        turns: 0.16,
        scale: 0.2,
        accent: 0.62,
      ),
      3 => const _CreationMotion(
        lift: 6,
        drift: -2,
        turns: -0.08,
        scale: 0.14,
        accent: 0.5,
      ),
      4 => const _CreationMotion(
        lift: 3,
        drift: 1,
        turns: 0.04,
        scale: 0.08,
        accent: 0.28,
      ),
      _ => const _CreationMotion(
        lift: 0,
        drift: 0,
        turns: 0,
        scale: 0,
        accent: 0,
      ),
    };
  }
}
