import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_soloud/flutter_soloud.dart' show WaveForm;

import '../../../domain/entities/sound_layer.dart';
import '../../../domain/entities/voice_timbre.dart';
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
/// Strategy: each layer owns its own voice synthesis (driven by a [VoiceTimbre])
/// and its own `level → volume` curve, so adding a layer means adding a subclass
/// instead of editing a switch. The bell is *not* an [AmbientVoice] — it is
/// scheduled, not held open, so it lives in its own scheduler.
///
/// The base remembers the last mix level and pause state so it can re-render the
/// voice for a new dimension's timbre ([retimbre]) and bring the fresh voices
/// straight to the live mix, crossfading away the old ones.
abstract class AmbientVoice {
  /// The handles this voice currently owns, populated by [build]/[retimbre].
  final List<VoiceHandle> handles = [];

  final List<VoiceSource> _sources = [];
  double _level = 0;
  bool _paused = false;

  /// How long an old timbre is faded out for when swapping dimensions.
  static const Duration crossfade = Duration(milliseconds: 700);

  /// The domain layer this voice renders.
  SoundLayer get layer;

  /// Creates the looping voice(s) for [timbre]. Subclass hook.
  Future<List<LoopVoice>> create(VoiceBuildContext context, VoiceTimbre timbre);

  /// Pushes a `0..1` [level] onto the live voice(s). Subclass hook.
  void apply(AudioBackend backend, double level);

  /// Builds the voice's looping handles for [timbre].
  Future<void> build(
    VoiceBuildContext context, [
    VoiceTimbre timbre = VoiceTimbre.standard,
  ]) async {
    final voices = await create(context, timbre);
    handles
      ..clear()
      ..addAll(voices.map((voice) => voice.handle));
    _sources
      ..clear()
      ..addAll(voices.map((voice) => voice.source));
  }

  /// Re-renders the voice for [timbre], crossfading from the live voices to the
  /// new ones and disposing the old sources once they have faded out.
  Future<void> retimbre(
    VoiceBuildContext context,
    VoiceTimbre timbre,
    AudioBackend backend,
  ) async {
    final oldHandles = List<VoiceHandle>.of(handles);
    final oldSources = List<VoiceSource>.of(_sources);

    await build(context, timbre);
    setPaused(backend, _paused);
    applyLevel(backend, _level);

    for (final handle in oldHandles) {
      backend.fadeVolume(handle, 0, crossfade);
    }
    Future.delayed(crossfade + const Duration(milliseconds: 100), () {
      for (final source in oldSources) {
        backend.disposeSource(source);
      }
    });
  }

  /// Maps a `0..1` mix [level] onto the live voice(s), remembering it so a later
  /// [retimbre] can restore the mix.
  void applyLevel(AudioBackend backend, double level) {
    _level = level;
    apply(backend, level);
  }

  /// Pauses or resumes every handle this voice owns.
  void setPaused(AudioBackend backend, bool paused) {
    _paused = paused;
    for (final handle in handles) {
      backend.setPause(handle, paused);
    }
  }
}

/// Low triangle chord with a faintly detuned twin (110 vs 110.5) whose slow
/// beating gives the bed width, plus 55 Hz body felt on headphones. The whole
/// chord is shifted by the timbre's [VoiceTimbre.droneRatio].
class DroneVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.drone;

  @override
  Future<List<LoopVoice>> create(
    VoiceBuildContext context,
    VoiceTimbre timbre,
  ) async {
    final r = timbre.droneRatio;
    return [
      await context.player.oscillator(WaveForm.sin, 55 * r),
      await context.player.oscillator(WaveForm.triangle, 110 * r),
      await context.player.oscillator(WaveForm.triangle, 110.5 * r),
      await context.player.oscillator(WaveForm.sin, 165 * r),
      await context.player.oscillator(WaveForm.sin, 220 * r),
    ];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.15);
    }
  }
}

/// Softer pink noise in a low, wide band so it reads as depth, not midrange
/// hiss; the band's centre/Q come from the timbre, so each space rains
/// differently.
class RainVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.rain;

  @override
  Future<List<LoopVoice>> create(
    VoiceBuildContext context,
    VoiceTimbre timbre,
  ) async {
    final wav = context.synth.bandNoiseWav(
      centreHz: timbre.rainCentreHz,
      q: timbre.rainQ,
      pink: true,
      random: context.random,
    );
    return [await context.player.noise(wav)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.20);
    }
  }
}

/// Harmonic-rich tone (not a bare sine) so the breathing survives on speakers
/// that can't reproduce true sub-bass; mixed with a slow tremolo. The
/// fundamental and harmonics come from the timbre.
class PulseVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.pulse;

  @override
  Future<List<LoopVoice>> create(
    VoiceBuildContext context,
    VoiceTimbre timbre,
  ) async {
    final wav = context.synth.harmonicWav(
      fundamentalHz: timbre.pulseHz,
      harmonicGains: timbre.pulseHarmonics,
    );
    return [await context.player.noise(wav)];
  }

  @override
  void apply(AudioBackend backend, double level) {
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
/// and slow swell baked into the sample; the band's centre/Q come from the
/// timbre.
class CicadaVoice extends AmbientVoice {
  @override
  SoundLayer get layer => SoundLayer.cicada;

  @override
  Future<List<LoopVoice>> create(
    VoiceBuildContext context,
    VoiceTimbre timbre,
  ) async {
    final wav = context.synth.bandNoiseWav(
      centreHz: timbre.cicadaCentreHz,
      q: timbre.cicadaQ,
      amplitudeModulated: true,
      random: context.random,
    );
    return [await context.player.noise(wav)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.26);
    }
  }
}
