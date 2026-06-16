import '../../audio/audio_backend.dart';
import '../../models/acoustic_profile.dart';

/// Type of sound a scene can run.
enum SceneSoundType {
  /// A looping asset.
  loop,

  /// A one-shot asset that starts with the scene.
  oneShot,

  /// A one-shot asset scheduled repeatedly with random delay.
  randomOneShot,

  /// Reserved for generated textures.
  texture,

  /// Placeholder sound that intentionally produces no output.
  silence,

  /// Reserved for streamed sources.
  stream,

  /// Reserved for procedural sources.
  procedural,
}

/// Target kind for a configured control mapping.
enum SoundMappingTarget {
  /// Controls a scene sound voice volume.
  soundVolume,

  /// Controls a random scene sound density.
  soundDensity,

  /// Controls a bus volume.
  busVolume,

  /// Controls a backend parameter.
  effectParam,
}

/// Top-level scene configuration.
class SceneConfig {
  /// Creates a scene config.
  const SceneConfig({
    required this.id,
    this.buses = const [],
    this.sounds = const [],
    this.knobs = const [],
    this.filters = const [],
  });

  /// Stable scene id.
  final String id;

  /// Scene buses.
  final List<BusConfig> buses;

  /// Scene sounds.
  final List<SceneSoundConfig> sounds;

  /// User-facing knobs.
  final List<KnobConfig> knobs;

  /// Scene filters/acoustic spaces.
  final List<FilterConfig> filters;
}

/// A logical bus in a scene.
class BusConfig {
  /// Creates a bus config.
  const BusConfig({required this.id, this.volume = 1});

  /// Stable bus id.
  final String id;

  /// Initial bus volume.
  final double volume;
}

/// A single sound in a scene.
class SceneSoundConfig {
  /// Creates a sound config.
  const SceneSoundConfig({
    required this.id,
    required this.type,
    this.busId,
    this.assetKey,
    this.volume = 1,
    this.pan = 0,
    this.minDelay = const Duration(seconds: 4),
    this.maxDelay = const Duration(seconds: 12),
    this.loadModePolicy = LoadModePolicy.memory,
  });

  /// Stable sound id.
  final String id;

  /// Sound behavior.
  final SceneSoundType type;

  /// Optional target bus.
  final String? busId;

  /// Optional app asset key.
  final String? assetKey;

  /// Base volume.
  final double volume;

  /// Base pan.
  final double pan;

  /// Minimum delay for [SceneSoundType.randomOneShot].
  final Duration minDelay;

  /// Maximum delay for [SceneSoundType.randomOneShot].
  final Duration maxDelay;

  /// Asset load policy.
  final LoadModePolicy loadModePolicy;
}

/// User-facing knob configuration.
class KnobConfig {
  /// Creates a knob config.
  const KnobConfig({
    required this.id,
    this.initialValue = 0,
    this.mappings = const [],
  });

  /// Stable knob id.
  final String id;

  /// Initial normalized value.
  final double initialValue;

  /// Configured effects.
  final List<SoundControlMapping> mappings;
}

/// Filter/acoustic-space configuration.
class FilterConfig {
  /// Creates a filter config.
  const FilterConfig({
    required this.id,
    this.initialValue = 0,
    this.mappings = const [],
    this.profile,
  });

  /// Stable filter id.
  final String id;

  /// Initial normalized value.
  final double initialValue;

  /// Configured effects.
  final List<SoundControlMapping> mappings;

  /// Optional acoustic profile for scene implementations that support one.
  final AcousticProfile? profile;
}

/// A configured effect from a knob or filter to scene/backend state.
class SoundControlMapping {
  /// Creates a control mapping.
  const SoundControlMapping({
    required this.target,
    this.soundId,
    this.busId,
    this.param,
    this.min = 0,
    this.max = 1,
  });

  /// Target kind.
  final SoundMappingTarget target;

  /// Optional target sound.
  final String? soundId;

  /// Optional target bus.
  final String? busId;

  /// Optional backend param name.
  final String? param;

  /// Output value at normalized 0.
  final double min;

  /// Output value at normalized 1.
  final double max;

  /// Resolves [input] to the configured range.
  double resolve(double input) {
    final value = input.clamp(0.0, 1.0).toDouble();
    return min + (max - min) * value;
  }
}

/// A named pack of short sounds.
class SoundPackConfig {
  /// Creates a sound pack.
  const SoundPackConfig({required this.id, this.sounds = const []});

  /// Stable pack id.
  final String id;

  /// Triggerable sounds.
  final List<TriggerSoundConfig> sounds;
}

/// A triggerable one-shot sound.
class TriggerSoundConfig {
  /// Creates a trigger config.
  const TriggerSoundConfig({
    required this.id,
    required this.assetKey,
    this.volume = 1,
    this.pan = 0,
    this.loadModePolicy = LoadModePolicy.memory,
  });

  /// Stable trigger id.
  final String id;

  /// App asset key.
  final String assetKey;

  /// Playback volume.
  final double volume;

  /// Playback pan.
  final double pan;

  /// Asset load policy.
  final LoadModePolicy loadModePolicy;
}
