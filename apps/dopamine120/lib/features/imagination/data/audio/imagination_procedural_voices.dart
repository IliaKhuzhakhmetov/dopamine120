import 'dart:math' as math;

import 'package:dopamine120/gen/assets.gen.dart';
import 'package:sound_framework/sound_framework.dart';

import '../scenes/imagination_scene.dart';

List<ProceduralVoice> buildImaginationProceduralVoices() => [
  _ImaginationDroneVoice(),
  AssetLoopVoice(
    id: imaginationBlockAddSoundId,
    assetKey: Assets.sound.focus.bell1,
    pan: -0.18,
    gain: 0.24,
  ),
  AssetLoopVoice(
    id: imaginationBlockRemoveSoundId,
    assetKey: Assets.sound.focus.bell1,
    pan: 0.16,
    gain: 0.18,
  ),
  AssetLoopVoice(
    id: imaginationCompletionSoundId,
    assetKey: Assets.sound.focus.bell1,
    gain: 0.32,
  ),
];

class _ImaginationDroneVoice extends ProceduralVoice {
  @override
  String get id => imaginationDroneSoundId;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final wav = context.synth.harmonicWav(
      fundamentalHz: 48,
      harmonicGains: const [0.7, 0.35, 0.18, 0.08],
      seconds: 5,
      transform: _breathe,
      crossfadeSeconds: 0.6,
    );
    return [await context.player.noise(wav, pan: -0.04)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.42);
    }
  }
}

double _breathe(double sample, double timeSeconds) {
  final slow = 0.78 + 0.22 * math.sin(2 * math.pi * timeSeconds / 4.5);
  final shimmer = 0.94 + 0.06 * math.sin(2 * math.pi * timeSeconds * 0.43);
  return sample * slow * shimmer;
}
