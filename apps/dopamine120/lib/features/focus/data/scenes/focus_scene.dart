import 'package:sound_framework/sound_framework.dart';

/// Dopamine120 focus scene config.
///
/// The framework only knows about scene sounds, filters and mappings. These
/// concrete ids and acoustic choices belong to the app.
const focusScene = SceneConfig(
  id: 'focus',
  sounds: [
    SceneSoundConfig(id: 'drone', type: SceneSoundType.procedural),
    SceneSoundConfig(id: 'rain', type: SceneSoundType.procedural),
    SceneSoundConfig(id: 'pulse', type: SceneSoundType.procedural),
    SceneSoundConfig(id: 'bell', type: SceneSoundType.procedural),
    SceneSoundConfig(id: 'cicada', type: SceneSoundType.procedural),
    SceneSoundConfig(id: 'birdsong', type: SceneSoundType.procedural),
    SceneSoundConfig(id: 'bamboo', type: SceneSoundType.procedural),
  ],
  knobs: [
    KnobConfig(
      id: 'drone',
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: 'drone',
          min: 0,
          max: 1,
        ),
      ],
    ),
    KnobConfig(
      id: 'rain',
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: 'rain',
          min: 0,
          max: 1,
        ),
      ],
    ),
    KnobConfig(
      id: 'pulse',
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: 'pulse',
          min: 0,
          max: 1,
        ),
        SoundControlMapping(
          target: SoundMappingTarget.effectParam,
          soundId: 'pulse',
          param: 'frequencyHz',
          min: 45,
          max: 65,
        ),
      ],
    ),
    KnobConfig(
      id: 'bell',
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: 'bell',
          min: 0,
          max: 1,
        ),
        SoundControlMapping(
          target: SoundMappingTarget.effectParam,
          soundId: 'bell',
          param: 'frequencyMultiplier',
          min: 0.75,
          max: 1.35,
        ),
      ],
    ),
    KnobConfig(
      id: 'cicada',
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: 'cicada',
          min: 0,
          max: 1,
        ),
      ],
    ),
    KnobConfig(
      id: 'birdsong',
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: 'birdsong',
          min: 0,
          max: 1,
        ),
      ],
    ),
    KnobConfig(
      id: 'bamboo',
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: 'bamboo',
          min: 0,
          max: 1,
        ),
      ],
    ),
  ],
  filters: [
    FilterConfig(
      id: 'room',
      initialValue: 1,
      profile: AcousticProfile(
        filterShape: AcousticFilterShape.lowpass,
        cutoffHz: 16000,
        resonance: 0.1,
        reverbWet: 0.07,
        roomSize: 0.4,
        delaySeconds: 0.30,
        delayDecay: 0,
        delayWet: 0,
        masterGain: 0.55,
      ),
    ),
    FilterConfig(
      id: 'cathedral',
      profile: AcousticProfile(
        filterShape: AcousticFilterShape.lowpass,
        cutoffHz: 9000,
        resonance: 0.1,
        reverbWet: 0.55,
        roomSize: 0.9,
        delaySeconds: 0.34,
        delayDecay: 0.25,
        delayWet: 0.06,
        masterGain: 0.5,
      ),
    ),
    FilterConfig(
      id: 'underwater',
      profile: AcousticProfile(
        filterShape: AcousticFilterShape.lowpass,
        cutoffHz: 680,
        resonance: 1.2,
        reverbWet: 0.2,
        roomSize: 0.6,
        delaySeconds: 0.30,
        delayDecay: 0,
        delayWet: 0,
        masterGain: 0.62,
      ),
    ),
    FilterConfig(
      id: 'cosmos',
      profile: AcousticProfile(
        filterShape: AcousticFilterShape.lowpass,
        cutoffHz: 14000,
        resonance: 0.1,
        reverbWet: 0.4,
        roomSize: 0.85,
        delaySeconds: 0.52,
        delayDecay: 0.55,
        delayWet: 0.34,
        masterGain: 0.5,
      ),
    ),
    FilterConfig(
      id: 'jungle',
      profile: AcousticProfile(
        filterShape: AcousticFilterShape.bandpass,
        cutoffHz: 2100,
        resonance: 0.8,
        reverbWet: 0.18,
        roomSize: 0.5,
        delaySeconds: 0.22,
        delayDecay: 0.3,
        delayWet: 0.12,
        masterGain: 0.55,
      ),
    ),
    FilterConfig(
      id: 'cave',
      profile: AcousticProfile(
        filterShape: AcousticFilterShape.lowpass,
        cutoffHz: 5200,
        resonance: 0.1,
        reverbWet: 0.3,
        roomSize: 0.7,
        delaySeconds: 0.27,
        delayDecay: 0.45,
        delayWet: 0.3,
        masterGain: 0.52,
      ),
    ),
  ],
);
