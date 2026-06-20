import 'dart:math' as math;

import 'package:sound_framework/sound_framework.dart';

const deprivationWhiteSoundId = 'deprivation.white';
const deprivationPinkSoundId = 'deprivation.pink';
const deprivationBrownSoundId = 'deprivation.brown';
const deprivationRainSoundId = 'deprivation.rain';

List<ProceduralVoice> buildDeprivationProceduralVoices() => [
  _DeprivationNoiseVoice(
    id: deprivationWhiteSoundId,
    color: NoiseColor.white,
    centerHz: 2600,
    q: 0.2,
    pan: 0,
  ),
  _DeprivationNoiseVoice(
    id: deprivationPinkSoundId,
    color: NoiseColor.pink,
    centerHz: 520,
    q: 0.34,
    pan: -0.04,
  ),
  _DeprivationNoiseVoice(
    id: deprivationBrownSoundId,
    color: NoiseColor.brown,
    centerHz: 140,
    q: 0.28,
    pan: 0.02,
  ),
  _DeprivationNoiseVoice(
    id: deprivationRainSoundId,
    color: NoiseColor.pink,
    centerHz: 1300,
    q: 0.72,
    pan: 0.06,
    transform: _rainPulse,
  ),
];

class _DeprivationNoiseVoice extends ProceduralVoice {
  _DeprivationNoiseVoice({
    required this.id,
    required this.color,
    required this.centerHz,
    required this.q,
    required this.pan,
    this.transform,
  });

  @override
  final String id;

  final NoiseColor color;
  final double centerHz;
  final double q;
  final double pan;
  final SampleTransform? transform;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final wav = context.synth.bandNoiseWav(
      centerHz: centerHz,
      q: q,
      color: color,
      seconds: 7,
      random: context.random,
      transform: transform,
      crossfadeSeconds: 0.55,
    );
    return [await context.player.noise(wav, pan: pan)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level);
    }
  }
}

double _rainPulse(double sample, double timeSeconds) {
  final drift = 0.82 + 0.18 * math.sin(2 * math.pi * timeSeconds / 5.5);
  return sample * drift;
}
