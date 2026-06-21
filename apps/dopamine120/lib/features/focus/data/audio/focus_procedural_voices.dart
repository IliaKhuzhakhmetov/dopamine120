import 'dart:math' as math;

import 'package:dopamine120/gen/assets.gen.dart';
import 'package:sound_framework/sound_framework.dart';

/// Builds the concrete procedural voices used by the Dopamine120 focus scene.
List<ProceduralVoice> buildFocusProceduralVoices() => [
  FocusDroneVoice(),
  AssetLoopVoice(id: 'rain', assetKey: Assets.sound.focus.rain1),
  FocusPulseVoice(),
  AssetLoopVoice(id: 'bell', assetKey: Assets.sound.focus.bell1),
  AssetLoopVoice(id: 'cicada', assetKey: Assets.sound.focus.cicades1),
  AssetLoopVoice(id: 'birdsong', assetKey: Assets.sound.focus.birdsong1),
  ShuffledAssetLoopVoice(
    id: 'groove',
    assetKeys: [
      Assets.sound.focus.groove.ambientGroove1,
      Assets.sound.focus.groove.ambientGroove2,
      Assets.sound.focus.groove.ambientGroove3,
      Assets.sound.focus.groove.ambientGroove4,
    ],
  ),
];

/// Low chord with a faintly detuned body; `frequencyRatio` shifts the chord.
class FocusDroneVoice extends ProceduralVoice {
  @override
  String get id => 'drone';

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final r = params['frequencyRatio'] ?? 1.0;
    return [
      await context.player.oscillator(WaveFormType.sin, 55 * r, pan: -0.18),
      await context.player.oscillator(WaveFormType.sin, 55.08 * r, pan: 0.18),
      await context.player.oscillator(
        WaveFormType.triangle,
        110 * r,
        pan: -0.10,
      ),
      await context.player.oscillator(
        WaveFormType.triangle,
        109.63 * r,
        pan: 0.12,
      ),
      await context.player.oscillator(WaveFormType.sin, 164.72 * r, pan: 0.04),
      await context.player.oscillator(
        WaveFormType.triangle,
        219.41 * r,
        pan: -0.06,
      ),
    ];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (var i = 0; i < handles.length; i++) {
      final gain = switch (i) {
        0 => 0.13,
        1 => 0.055,
        2 => 0.070,
        3 => 0.050,
        4 => 0.028,
        _ => 0.020,
      };
      backend.setVolume(handles[i], level * gain);
    }
  }
}

/// Harmonic-rich pulse mixed with a slow tremolo.
class FocusPulseVoice extends ProceduralVoice {
  @override
  String get id => 'pulse';

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final wav = context.synth.harmonicWav(
      fundamentalHz: params['frequencyHz'] ?? 52,
      harmonicGains: const [0.70, 1.0, 0.42, 0.25, 0.11, 0.045],
      seconds: 2.5,
      transform: _pulseBody,
      crossfadeSeconds: 0.35,
    );
    return [await context.player.noise(wav, pan: 0.04)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      if (level <= 0) {
        backend.setVolume(handle, 0);
      } else {
        backend.oscillateVolume(
          handle,
          level * 0.10,
          level * 0.34,
          const Duration(milliseconds: 1850),
        );
      }
    }
  }
}

double _pulseBody(double sample, double timeSeconds) {
  final tremolo =
      0.62 +
      0.25 * math.sin(2 * math.pi * 0.58 * timeSeconds) +
      0.13 * math.sin(2 * math.pi * 1.16 * timeSeconds + 1.2);
  final bloom = 0.86 + 0.14 * math.sin(2 * math.pi * 0.19 * timeSeconds + 0.4);
  return sample * tremolo * bloom;
}
