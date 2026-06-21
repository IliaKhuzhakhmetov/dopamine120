import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// One named icon token from the active [DopIcons] set.
class DopIconToken {
  /// Creates an icon token entry.
  const DopIconToken({required this.name, required this.icon});

  /// Stable token name used by code and the icon matrix.
  final String name;

  /// Material icon selected by the active theme.
  final IconData icon;
}

/// Icon tokens of the DOPAMINE120 design language.
///
/// Widgets should read icons through `context.icons` instead of hardcoding
/// Material icons when the symbol is part of the product language. Theme specs
/// can swap the icon set without changing consumer widgets.
class DopIcons extends ThemeExtension<DopIcons> {
  /// Creates the icon token set.
  const DopIcons({
    required this.tune,
    required this.drone,
    required this.rain,
    required this.pulse,
    required this.bell,
    required this.cicada,
    required this.birdsong,
    required this.groove,
    required this.muted,
    required this.unmuted,
  });

  /// The base calm icon set.
  const DopIcons.base()
    : tune = PhosphorIconsRegular.sliders,
      drone = PhosphorIconsRegular.waveform,
      rain = PhosphorIconsRegular.drop,
      pulse = PhosphorIconsRegular.pulse,
      bell = PhosphorIconsRegular.bell,
      cicada = PhosphorIconsRegular.broadcast,
      birdsong = PhosphorIconsRegular.bird,
      groove = PhosphorIconsRegular.musicNotes,
      muted = PhosphorIconsRegular.speakerSlash,
      unmuted = PhosphorIconsRegular.speakerHigh;

  /// `room` icon set: close, tactile, domestic.
  const DopIcons.room()
    : tune = PhosphorIconsRegular.sliders,
      drone = PhosphorIconsRegular.waveform,
      rain = PhosphorIconsRegular.drop,
      pulse = PhosphorIconsRegular.heartbeat,
      bell = PhosphorIconsRegular.bell,
      cicada = PhosphorIconsRegular.broadcast,
      birdsong = PhosphorIconsRegular.bird,
      groove = PhosphorIconsRegular.musicNotes,
      muted = PhosphorIconsRegular.speakerSlash,
      unmuted = PhosphorIconsRegular.speakerHigh;

  /// `cathedral` icon set: vertical, resonant, stone-like.
  const DopIcons.cathedral()
    : tune = PhosphorIconsLight.sliders,
      drone = PhosphorIconsLight.church,
      rain = PhosphorIconsLight.drop,
      pulse = PhosphorIconsLight.sparkle,
      bell = PhosphorIconsLight.bell,
      cicada = PhosphorIconsLight.broadcast,
      birdsong = PhosphorIconsLight.bird,
      groove = PhosphorIconsLight.musicNotes,
      muted = PhosphorIconsLight.speakerSlash,
      unmuted = PhosphorIconsLight.speakerHigh;

  /// `underwater` icon set: waves, sonar, muffled motion.
  const DopIcons.underwater()
    : tune = PhosphorIconsThin.sliders,
      drone = PhosphorIconsThin.waveform,
      rain = PhosphorIconsThin.drop,
      pulse = PhosphorIconsThin.pulse,
      bell = PhosphorIconsThin.bell,
      cicada = PhosphorIconsThin.broadcast,
      birdsong = PhosphorIconsThin.bird,
      groove = PhosphorIconsThin.musicNotes,
      muted = PhosphorIconsThin.speakerSlash,
      unmuted = PhosphorIconsThin.speakerHigh;

  /// `cosmos` icon set: orbit, signal, bright points.
  const DopIcons.cosmos()
    : tune = PhosphorIconsDuotone.sliders,
      drone = PhosphorIconsDuotone.waveform,
      rain = PhosphorIconsDuotone.sparkle,
      pulse = PhosphorIconsDuotone.pulse,
      bell = PhosphorIconsDuotone.bell,
      cicada = PhosphorIconsDuotone.broadcast,
      birdsong = PhosphorIconsDuotone.bird,
      groove = PhosphorIconsDuotone.musicNotes,
      muted = PhosphorIconsDuotone.speakerSlash,
      unmuted = PhosphorIconsDuotone.speakerHigh;

  /// `jungle` icon set: organic, humid, living.
  const DopIcons.jungle()
    : tune = PhosphorIconsRegular.tree,
      drone = PhosphorIconsRegular.tree,
      rain = PhosphorIconsRegular.drop,
      pulse = PhosphorIconsRegular.leaf,
      bell = PhosphorIconsRegular.bell,
      cicada = PhosphorIconsRegular.broadcast,
      birdsong = PhosphorIconsRegular.bird,
      groove = PhosphorIconsRegular.musicNotes,
      muted = PhosphorIconsRegular.speakerSlash,
      unmuted = PhosphorIconsRegular.speakerHigh;

  /// `cave` icon set: rough, mineral, echoing.
  const DopIcons.cave()
    : tune = PhosphorIconsBold.mountains,
      drone = PhosphorIconsBold.mountains,
      rain = PhosphorIconsBold.drop,
      pulse = PhosphorIconsBold.pulse,
      bell = PhosphorIconsBold.bell,
      cicada = PhosphorIconsBold.broadcast,
      birdsong = PhosphorIconsBold.bird,
      groove = PhosphorIconsBold.musicNotes,
      muted = PhosphorIconsBold.speakerSlash,
      unmuted = PhosphorIconsBold.speakerHigh;

  /// Generic fallback / controls icon.
  final IconData tune;

  /// Continuous low texture.
  final IconData drone;

  /// Rain or grain texture.
  final IconData rain;

  /// Repeating pulse.
  final IconData pulse;

  /// Bell or bright hit.
  final IconData bell;

  /// Cicada-like texture.
  final IconData cicada;

  /// Birdsong-like texture.
  final IconData birdsong;

  /// Groove-like texture.
  final IconData groove;

  /// Muted audio state.
  final IconData muted;

  /// Audible audio state.
  final IconData unmuted;

  /// Resolves a token by stable name, falling back to [tune].
  IconData byName(String name) {
    return switch (name) {
      'tune' => tune,
      'drone' => drone,
      'rain' => rain,
      'pulse' => pulse,
      'bell' => bell,
      'cicada' => cicada,
      'birdsong' => birdsong,
      'groove' => groove,
      'muted' => muted,
      'unmuted' => unmuted,
      _ => tune,
    };
  }

  /// Every icon token in matrix order.
  List<DopIconToken> get entries => [
    DopIconToken(name: 'tune', icon: tune),
    DopIconToken(name: 'drone', icon: drone),
    DopIconToken(name: 'rain', icon: rain),
    DopIconToken(name: 'pulse', icon: pulse),
    DopIconToken(name: 'bell', icon: bell),
    DopIconToken(name: 'cicada', icon: cicada),
    DopIconToken(name: 'birdsong', icon: birdsong),
    DopIconToken(name: 'groove', icon: groove),
    DopIconToken(name: 'muted', icon: muted),
    DopIconToken(name: 'unmuted', icon: unmuted),
  ];

  @override
  DopIcons copyWith({
    IconData? tune,
    IconData? drone,
    IconData? rain,
    IconData? pulse,
    IconData? bell,
    IconData? cicada,
    IconData? birdsong,
    IconData? groove,
    IconData? muted,
    IconData? unmuted,
  }) {
    return DopIcons(
      tune: tune ?? this.tune,
      drone: drone ?? this.drone,
      rain: rain ?? this.rain,
      pulse: pulse ?? this.pulse,
      bell: bell ?? this.bell,
      cicada: cicada ?? this.cicada,
      birdsong: birdsong ?? this.birdsong,
      groove: groove ?? this.groove,
      muted: muted ?? this.muted,
      unmuted: unmuted ?? this.unmuted,
    );
  }

  @override
  DopIcons lerp(DopIcons? other, double t) {
    if (other == null || t < 0.5) return this;
    return other;
  }
}
