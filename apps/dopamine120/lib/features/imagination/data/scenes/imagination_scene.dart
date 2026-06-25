import 'package:sound_framework/sound_framework.dart';

import '../../../focus/data/scenes/focus_scene.dart';

const imaginationDroneSoundId = 'imagination.drone';
const imaginationBlockAddSoundId = 'imagination.block.add';
const imaginationBlockRemoveSoundId = 'imagination.block.remove';
const imaginationCompletionSoundId = 'imagination.completion';

const imaginationDroneKnobId = 'drone';
const defaultImaginationDroneDb = -21.0;
const minImaginationDroneDb = -120.0;
const maxImaginationDroneDb = 0.0;
const defaultImaginationThemeId = 'room';

const _droneInitialValue =
    (defaultImaginationDroneDb - minImaginationDroneDb) /
    (maxImaginationDroneDb - minImaginationDroneDb);

final imaginationScene = SceneConfig(
  id: 'imagination',
  sounds: const [
    SceneSoundConfig(
      id: imaginationDroneSoundId,
      type: SceneSoundType.procedural,
    ),
    SceneSoundConfig(
      id: imaginationBlockAddSoundId,
      type: SceneSoundType.procedural,
    ),
    SceneSoundConfig(
      id: imaginationBlockRemoveSoundId,
      type: SceneSoundType.procedural,
    ),
    SceneSoundConfig(
      id: imaginationCompletionSoundId,
      type: SceneSoundType.procedural,
    ),
  ],
  knobs: const [
    KnobConfig(
      id: imaginationDroneKnobId,
      initialValue: _droneInitialValue,
      mappings: [
        SoundControlMapping(
          target: SoundMappingTarget.soundVolume,
          soundId: imaginationDroneSoundId,
          min: minImaginationDroneDb,
          max: maxImaginationDroneDb,
          scale: SoundMappingScale.decibelGain,
        ),
      ],
    ),
  ],
  filters: [
    ...focusScene.filters,
    const FilterConfig(
      id: 'deprivation',
      profile: AcousticProfile(
        filterShape: AcousticFilterShape.lowpass,
        cutoffHz: 2400,
        resonance: 0.16,
        reverbWet: 0.12,
        roomSize: 0.45,
        delaySeconds: 0.28,
        delayDecay: 0.08,
        delayWet: 0.03,
        masterGain: 0.46,
      ),
    ),
  ],
);
