import 'dart:async';
import 'dart:math' as math;

import 'audio_backend.dart';
import 'loop_player.dart';
import 'procedural_voice.dart';

/// A [ProceduralVoice] that keeps several bundled recordings looping at once and
/// slowly crossfades between them, so a single knob plays an ever-varying bed
/// instead of the same loop on repeat.
///
/// Every recording in [assetKeys] is started and kept alive; only one is audible
/// at a time (at the mix level scaled by [gain]). A timer periodically fades the
/// audible loop down and a different, randomly chosen one up over [crossfade],
/// holding each pick for a random span in `[minHold, maxHold]`.
class ShuffledAssetLoopVoice extends ProceduralVoice {
  /// Creates a rotating loop voice over [assetKeys].
  ShuffledAssetLoopVoice({
    required this.id,
    required this.assetKeys,
    this.pan = 0,
    this.gain = 1,
    this.loadModePolicy = LoadModePolicy.memory,
    this.crossfade = const Duration(seconds: 4),
    this.minHold = const Duration(seconds: 18),
    this.maxHold = const Duration(seconds: 40),
  }) : assert(assetKeys.isNotEmpty, 'needs at least one recording');

  @override
  final String id;

  /// App asset keys of the recordings to rotate between.
  final List<String> assetKeys;

  /// Stereo pan in `-1..1`.
  final double pan;

  /// Constant multiplier applied to the mix level before it reaches the voice.
  final double gain;

  /// Asset load policy.
  final LoadModePolicy loadModePolicy;

  /// How long an outgoing loop fades down (and the next fades up) on a swap.
  final Duration crossfade;

  /// Shortest time a pick stays audible before the next swap.
  final Duration minHold;

  /// Longest time a pick stays audible before the next swap.
  final Duration maxHold;

  math.Random? _random;
  Timer? _rotateTimer;
  bool _running = false;
  int _activeIndex = 0;
  double _level = 0;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    _random = context.random;
    _activeIndex = context.random.nextInt(assetKeys.length);
    final voices = <LoopVoice>[];
    for (final key in assetKeys) {
      voices.add(
        await context.player.asset(key, pan: pan, policy: loadModePolicy),
      );
    }
    return voices;
  }

  @override
  void apply(AudioBackend backend, double level) {
    _level = level;
    for (var i = 0; i < handles.length; i++) {
      backend.setVolume(handles[i], i == _activeIndex ? level * gain : 0);
    }
  }

  @override
  void start(AudioBackend backend) {
    stop(backend);
    _running = true;
    if (handles.length > 1) _scheduleRotate(backend);
  }

  @override
  void stop(AudioBackend backend) {
    _running = false;
    _rotateTimer?.cancel();
    _rotateTimer = null;
  }

  @override
  void dispose(AudioBackend backend) => stop(backend);

  void _scheduleRotate(AudioBackend backend) {
    final random = _random;
    if (random == null) return;
    final spreadMs = (maxHold - minHold).inMilliseconds;
    final waitMs =
        minHold.inMilliseconds + (spreadMs <= 0 ? 0 : random.nextInt(spreadMs));
    _rotateTimer = Timer(Duration(milliseconds: waitMs), () {
      _rotate(backend);
      if (_running) _scheduleRotate(backend);
    });
  }

  void _rotate(AudioBackend backend) {
    final random = _random;
    if (random == null || handles.length < 2) return;

    // Pick any loop other than the one currently audible.
    var next = random.nextInt(handles.length - 1);
    if (next >= _activeIndex) next++;

    backend.fadeVolume(handles[_activeIndex], 0, crossfade);
    backend.fadeVolume(handles[next], _level * gain, crossfade);
    _activeIndex = next;
  }
}
