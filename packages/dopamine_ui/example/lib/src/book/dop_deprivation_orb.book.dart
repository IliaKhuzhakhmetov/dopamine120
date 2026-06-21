import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopDeprivationOrb].
WidgetbookComponent get dopDeprivationOrbBook => WidgetbookComponent(
  name: 'DopDeprivationOrb',
  useCases: [
    WidgetbookUseCase(
      name: 'Breathing particles',
      builder: (context) {
        final size = context.knobs.double.input(
          label: 'size',
          initialValue: 360,
        );
        final particleCount = context.knobs.int.slider(
          label: 'particles',
          initialValue: 360,
          min: 24,
          max: 2000,
          divisions: 247,
        );
        final particleSizeMin = context.knobs.double.slider(
          label: 'particle size min',
          initialValue: 1.2,
          min: 0.4,
          max: 6,
          divisions: 56,
        );
        final particleSizeMaxKnob = context.knobs.double.slider(
          label: 'particle size max',
          initialValue: 3.8,
          min: 0.4,
          max: 10,
          divisions: 62,
        );
        final particleSizeMax = particleSizeMaxKnob < particleSizeMin
            ? particleSizeMin
            : particleSizeMaxKnob;
        final opacity = context.knobs.double.slider(
          label: 'opacity',
          initialValue: 0.3,
          min: 0,
          max: 0.5,
          divisions: 50,
          precision: 2,
        );
        final breathingSpeed = context.knobs.double.slider(
          label: 'breathing speed',
          initialValue: 0.45,
          min: 0,
          max: 1.5,
          divisions: 60,
          precision: 2,
        );
        final rotationSpeed = context.knobs.double.slider(
          label: 'rotation speed',
          initialValue: 0.05,
          min: -0.5,
          max: 0.5,
          divisions: 80,
          precision: 2,
        );
        final drift = context.knobs.double.slider(
          label: 'drift',
          initialValue: 5,
          min: 0,
          max: 28,
          divisions: 56,
          precision: 1,
        );
        final spread = context.knobs.double.slider(
          label: 'spread',
          initialValue: 0.3,
          min: 0.08,
          max: 0.55,
          divisions: 47,
          precision: 2,
        );
        final animate = context.knobs.boolean(
          label: 'animate',
          initialValue: true,
        );
        final interactive = context.knobs.boolean(
          label: 'interactive',
          initialValue: true,
        );
        final repelRadius = context.knobs.double.slider(
          label: 'repel radius',
          initialValue: 140,
          min: 20,
          max: 320,
          divisions: 60,
          precision: 0,
        );
        final repelStrength = context.knobs.double.slider(
          label: 'repel strength',
          initialValue: 1850,
          min: 0,
          max: 4000,
          divisions: 80,
          precision: 0,
        );
        final swirlStrength = context.knobs.double.slider(
          label: 'swirl strength',
          initialValue: 620,
          min: 0,
          max: 2000,
          divisions: 80,
          precision: 0,
        );
        final spring = context.knobs.double.slider(
          label: 'spring',
          initialValue: 22,
          min: 4,
          max: 60,
          divisions: 56,
          precision: 0,
        );
        final damping = context.knobs.double.slider(
          label: 'damping',
          initialValue: 0.84,
          min: 0.5,
          max: 0.98,
          divisions: 48,
          precision: 2,
        );
        final glow = context.knobs.boolean(
          label: 'green glow',
          initialValue: false,
        );
        final seed = context.knobs.int.input(label: 'seed', initialValue: 120);

        return Theme(
          data: DopTheme.fromSpec(DopThemes.deprivation),
          child: Builder(
            builder: (context) => ColoredBox(
              color: context.colors.wall,
              child: SizedBox.square(
                dimension: size,
                child: DopDeprivationOrb(
                  size: size,
                  particleCount: particleCount,
                  particleSizeMin: particleSizeMin,
                  particleSizeMax: particleSizeMax,
                  opacity: opacity,
                  breathingSpeed: breathingSpeed,
                  rotationSpeed: rotationSpeed,
                  drift: drift,
                  spread: spread,
                  animate: animate,
                  seed: seed,
                  interactive: interactive,
                  repelRadius: repelRadius,
                  repelStrength: repelStrength,
                  swirlStrength: swirlStrength,
                  spring: spring,
                  damping: damping,
                  glowColor: glow ? const Color(0xFF3DDC97) : null,
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
