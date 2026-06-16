import 'dart:async';
import 'dart:math' as math;

import 'audio_backend.dart';
import 'loop_player.dart';
import 'sample_synth.dart';
import '../models/procedural_sound_event.dart';

/// Everything a procedural voice needs to wire itself up at build time.
class ProceduralVoiceBuildContext {
  /// Bundles the shared collaborators handed to each [ProceduralVoice].
  const ProceduralVoiceBuildContext({
    required this.backend,
    required this.player,
    required this.synth,
    required this.random,
    required this.emit,
  });

  /// Concrete backend for voices that need direct one-shot or source control.
  final AudioBackend backend;

  /// Starts and keeps looping voices alive.
  final LoopPlayer player;

  /// Renders procedural sample buffers.
  final SampleSynth synth;

  /// Shared RNG, seeded in tests for determinism.
  final math.Random random;

  /// Emits a generic procedural sound event to the owning engine.
  final void Function(ProceduralSoundEvent event) emit;
}

/// One continuously looping procedural sound.
///
/// Framework code owns lifecycle, retuning and crossfades. Apps own concrete
/// subclasses and decide what each voice sounds like.
abstract class ProceduralVoice {
  /// The handles this voice currently owns, populated by [build]/[retune].
  final List<VoiceHandle> handles = [];

  final List<VoiceSource> _sources = [];
  double _level = 0;
  bool _paused = false;

  /// How long an old sound body is faded out for when swapping parameters.
  static const Duration crossfade = Duration(milliseconds: 700);

  /// Stable sound id this voice renders.
  String get id;

  /// Creates the looping voice(s) for [params]. Subclass hook.
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  );

  /// Pushes a `0..1` [level] onto the live voice(s). Subclass hook.
  void apply(AudioBackend backend, double level);

  /// Starts any non-looping behavior owned by this voice.
  void start(AudioBackend backend) {}

  /// Stops any non-looping behavior owned by this voice.
  void stop(AudioBackend backend) {}

  /// Releases any resources owned directly by this voice.
  void dispose(AudioBackend backend) {}

  /// Builds the voice's looping handles for [params].
  Future<void> build(
    ProceduralVoiceBuildContext context, [
    Map<String, double> params = const {},
  ]) async {
    final voices = await create(context, params);
    handles
      ..clear()
      ..addAll(voices.map((voice) => voice.handle));
    _sources
      ..clear()
      ..addAll(voices.map((voice) => voice.source));
  }

  /// Re-renders the voice for [params], crossfading from the live voices to the
  /// new ones and disposing the old sources once they have faded out.
  Future<void> retune(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
    AudioBackend backend,
  ) async {
    final oldHandles = List<VoiceHandle>.of(handles);
    final oldSources = List<VoiceSource>.of(_sources);

    await build(context, params);
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
  /// [retune] can restore the mix.
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
