import 'package:sound_framework/sound_framework.dart';

/// Dopamine120 onboarding UI sounds.
const onboardingSoundPack = SoundPackConfig(
  id: 'onboarding',
  sounds: [
    TriggerSoundConfig(
      id: 'onboarding.deprivation',
      assetKey: 'assets/sound/dopamine120_op1_pack/deprivation_op1.wav',
    ),
    TriggerSoundConfig(
      id: 'onboarding.imagination',
      assetKey: 'assets/sound/dopamine120_op1_pack/imagination_op1.wav',
    ),
    TriggerSoundConfig(
      id: 'onboarding.creation',
      assetKey: 'assets/sound/dopamine120_op1_pack/creation_op1.wav',
    ),
    TriggerSoundConfig(
      id: 'onboarding.reward',
      assetKey: 'assets/sound/dopamine120_op1_pack/reward_op1.wav',
    ),
    TriggerSoundConfig(
      id: 'reward.soft',
      assetKey: 'assets/sound/dopamine120_op1_pack/reward_op1.wav',
      volume: 0.75,
    ),
  ],
);
