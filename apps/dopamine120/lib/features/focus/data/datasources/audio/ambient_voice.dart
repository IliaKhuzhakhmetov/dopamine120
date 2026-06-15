import 'dart:math' as math;

import 'package:flutter_soloud/flutter_soloud.dart' show WaveForm;

import '../../../domain/entities/sound_layer.dart';
import 'audio_backend.dart';
import 'loop_player.dart';
import 'sample_synth.dart';

/// Everything a voice needs to wire itself up, passed once at build time.
class VoiceBuildContext {
  /// Bundles the shared collaborators handed to each [AmbientVoice].
  const VoiceBuildContext({
    required this.player,
    required this.synth,
    required this.random,
  });

  /// Starts and keeps looping voices alive (platform-aware).
  final LoopPlayer player;

  /// Renders the procedural sample buffers.
  final SampleSynth synth;

  /// Shared RNG, seeded in tests for determinism.
  final math.Random random;
}

/// One continuously-looping ambient layer (drone, rain, pulse, cicada).
///
/// Strategy: each layer owns its own voice wiring and its own `level → volume`
/// curve, so adding a layer means adding a subclass instead of editing a switch.
/// The bell is *not* an [AmbientVoice] — it is scheduled, not held open, so it
/// lives in its own scheduler.
abstract class AmbientVoice {
  /// The handles this voice opened, populated by [build].
  final List<VoiceHandle> handles = [];

  /// The domain layer this voice renders.
  SoundLayer get layer;

  /// Creates the voice's looping handles via [context].
  Future<void> build(VoiceBuildContext context);

  /// Maps a `0..1` mix [level] onto the live voice(s) via [backend].
  void applyLevel(AudioBackend backend, double level);

  /// Pauses or resumes every handle this voice owns.
  void setPaused(AudioBackend backend, bool paused) {
    for (final handle in handles) {
      backend.setPause(handle, paused);
    }
  }
}

/// Low triangle chord with a faintly detuned twin (110 vs 110.5) whose slow
/// beating gives the bed width, plus 55 Hz body felt on headphones.
class DroneVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.drone;

  @override
  Future<void> build(VoiceBuildContext context) async {
    handles
      ..clear()
      ..add(await context.player.oscillator(WaveForm.sin, 55))
      ..add(await context.player.oscillator(WaveForm.triangle, 110))
      ..add(await context.player.oscillator(WaveForm.triangle, 110.5))
      ..add(await context.player.oscillator(WaveForm.sin, 165))
      ..add(await context.player.oscillator(WaveForm.sin, 220));
  }

  @override
  void applyLevel(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.15);
    }
  }
}

/// Softer pink noise in a low, wide band so it reads as depth, not midrange hiss.
class RainVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.rain;

  @override
  Future<void> build(VoiceBuildContext context) async {
    final wav = context.synth.bandNoiseWav(
      centreHz: 1050,
      q: 0.5,
      pink: true,
      random: context.random,
    );
    handles
      ..clear()
      ..add(await context.player.noise(wav));
  }

  @override
  void applyLevel(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.20);
    }
  }
}

/// Harmonic-rich 55 Hz tone (not a bare sine) so the breathing survives on
/// speakers that can't reproduce true sub-bass; mixed with a slow tremolo.
class PulseVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.pulse;

  @override
  Future<void> build(VoiceBuildContext context) async {
    final wav = context.synth.harmonicWav(
      fundamentalHz: 55,
      harmonicGains: const [0.35, 1.0, 0.65, 0.4, 0.2],
    );
    handles
      ..clear()
      ..add(await context.player.noise(wav));
  }

  @override
  void applyLevel(AudioBackend backend, double level) {
    for (final handle in handles) {
      if (level <= 0) {
        backend.setVolume(handle, 0);
      } else {
        // Slow tremolo around the pulse level, mirroring the reference LFO.
        backend.oscillateVolume(
          handle,
          level * 0.16,
          level * 0.46,
          const Duration(milliseconds: 1400),
        );
      }
    }
  }
}

/// Strange high-frequency chatter: a narrow band with the cicada's fast buzz
/// and slow swell baked into the sample.
class CicadaVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.cicada;

  @override
  Future<void> build(VoiceBuildContext context) async {
    final wav = context.synth.bandNoiseWav(
      centreHz: 4800,
      q: 9,
      amplitudeModulated: true,
      random: context.random,
    );
    handles
      ..clear()
      ..add(await context.player.noise(wav));
  }

  @override
  void applyLevel(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.26);
    }
  }
}
