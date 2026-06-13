import 'dart:math' as math;

import 'package:confetti/confetti.dart' as confetti;
import 'package:flutter/material.dart';

import '../theme/context_ext.dart';

/// UI-kit wrapper around the package-level confetti effect.
class DopConfettiController {
  DopConfettiController({Duration duration = const Duration(milliseconds: 480)})
    : _controller = confetti.ConfettiController(duration: duration);

  final confetti.ConfettiController _controller;

  void play() => _controller.play();

  void stop() => _controller.stop();

  void dispose() => _controller.dispose();
}

class DopConfetti extends StatelessWidget {
  const DopConfetti({
    super.key,
    required this.controller,
    required this.child,
    this.size = 92,
  });

  final DopConfettiController controller;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          child,
          IgnorePointer(
            child: confetti.ConfettiWidget(
              confettiController: controller._controller,
              blastDirection: -math.pi / 2,
              blastDirectionality: confetti.BlastDirectionality.explosive,
              emissionFrequency: 0.58,
              numberOfParticles: 9,
              maxBlastForce: 16,
              minBlastForce: 8,
              gravity: 0.08,
              particleDrag: 0.12,
              shouldLoop: false,
              colors: [colors.accent, colors.ink, colors.inkSoft, colors.paper],
            ),
          ),
        ],
      ),
    );
  }
}
