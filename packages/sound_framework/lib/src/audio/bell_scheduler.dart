import 'dart:async';
import 'dart:math' as math;

import '../models/bell_strike.dart';
import 'audio_backend.dart';

/// Schedules the bell layer's sparse, randomly-timed pings.
///
/// Unlike the continuous [AmbientVoice]s, the bell is struck on a timer rather
/// than held open, so it owns its own scheduling and two retunable voices (a
/// sine strike tone and a quieter inharmonic shimmer). Injecting [random] and
/// [tick] keeps it deterministic and drivable under `fake_async`.
class BellScheduler {
  /// Wires the scheduler to [_backend].
  BellScheduler(
    this._backend, {
    required math.Random random,
    Duration tick = const Duration(milliseconds: 430),
    void Function(BellStrike strike)? onStrike,
  }) : _random = random,
       _tick = tick,
       _onStrike = onStrike;

  final AudioBackend _backend;
  final math.Random _random;
  final Duration _tick;
  final void Function(BellStrike strike)? _onStrike;

  /// Notes the bell arpeggiates through (a warm major pentatonic, an octave
  /// below the reference so pings read as mellow chimes, not shrill plinks).
  static const List<double> _notes = [261.63, 293.66, 329.63, 392.0, 440.0];

  /// Inharmonic upper partial that gives the bell its metallic shimmer; a real
  /// bell's first overtone sits near this ratio above the strike tone.
  static const double _partialRatio = 2.76;

  VoiceSource? _strikeSource;
  VoiceSource? _partialSource;
  Timer? _timer;
  double _level = 0;
  double _transpose = 1;

  /// Whether the two bell voices have been loaded.
  bool get isReady => _strikeSource != null;

  /// Sets the bell layer's `0..1` mix level (probability and volume of pings).
  set level(double value) => _level = value;

  /// Multiplies every struck note, transposing the chimes for the dimension.
  set transpose(double value) => _transpose = value;

  /// Loads the strike and shimmer voices (idempotent per engine build).
  Future<void> build() async {
    _strikeSource = await _backend.loadWaveform(WaveFormType.sin);
    _partialSource = await _backend.loadWaveform(WaveFormType.sin);
  }

  /// Starts the periodic scheduler.
  void start() {
    stop();
    _timer = Timer.periodic(_tick, (_) => _maybeRing());
  }

  /// Stops scheduling further pings (already-ringing voices fade out on their
  /// own schedule).
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Stops the scheduler and forgets the voices.
  void dispose() {
    stop();
    _strikeSource = null;
    _partialSource = null;
    _level = 0;
    _transpose = 1;
  }

  void _maybeRing() {
    final strikeSource = _strikeSource;
    final partialSource = _partialSource;
    if (strikeSource == null || partialSource == null || _level <= 0) return;
    if (_random.nextDouble() >= _level * 0.6) return;

    final note = _notes[_random.nextInt(_notes.length)] * _transpose;
    _onStrike?.call(BellStrike(intensity: _level, frequency: note));

    // Strike tone: instant attack, long soft tail.
    _backend.setWaveformFreq(strikeSource, note);
    final strike = _backend.play(strikeSource, volume: _level * 0.15);
    _backend.fadeVolume(strike, 0, const Duration(milliseconds: 2200));
    _backend.scheduleStop(strike, const Duration(milliseconds: 2300));

    // Inharmonic shimmer: quieter and shorter so it colours the attack and
    // decays away first, the way a real bell's overtones do.
    _backend.setWaveformFreq(partialSource, note * _partialRatio);
    final shimmer = _backend.play(partialSource, volume: _level * 0.05);
    _backend.fadeVolume(shimmer, 0, const Duration(milliseconds: 1500));
    _backend.scheduleStop(shimmer, const Duration(milliseconds: 1600));
  }
}
