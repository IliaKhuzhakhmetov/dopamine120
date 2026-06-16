import 'dart:async';
import 'dart:math' as math;

import 'package:sound_framework/sound_framework.dart';

/// Builds the concrete procedural voices used by the Dopamine120 focus scene.
List<ProceduralVoice> buildFocusProceduralVoices() => [
  FocusDroneVoice(),
  FocusRainVoice(),
  FocusPulseVoice(),
  FocusBellVoice(),
  FocusCicadaVoice(),
];

/// Low chord with a faintly detuned twin; `frequencyRatio` shifts the chord.
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
      await context.player.oscillator(WaveFormType.sin, 55 * r),
      await context.player.oscillator(WaveFormType.triangle, 110 * r),
      await context.player.oscillator(WaveFormType.triangle, 110.5 * r),
      await context.player.oscillator(WaveFormType.sin, 165 * r),
      await context.player.oscillator(WaveFormType.sin, 220 * r),
    ];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.15);
    }
  }
}

/// Soft pink noise layer; `centerHz` and `q` tune the band.
class FocusRainVoice extends ProceduralVoice {
  @override
  String get id => 'rain';

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final wav = context.synth.bandNoiseWav(
      centerHz: params['centerHz'] ?? 1050,
      q: params['q'] ?? 0.5,
      color: NoiseColor.pink,
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
      fundamentalHz: params['frequencyHz'] ?? 55,
      harmonicGains: const [0.35, 1.0, 0.65, 0.4, 0.2],
    );
    return [await context.player.noise(wav)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      if (level <= 0) {
        backend.setVolume(handle, 0);
      } else {
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

/// Sparse note pings that also drive the focus orb's bell particles.
class FocusBellVoice extends ProceduralVoice {
  @override
  String get id => 'bell';

  static const List<double> _notes = [261.63, 293.66, 329.63, 392.0, 440.0];
  static const double _partialRatio = 2.76;
  static const Duration _tick = Duration(milliseconds: 430);

  math.Random? _random;
  void Function(ProceduralSoundEvent event)? _emit;
  VoiceSource? _strikeSource;
  VoiceSource? _partialSource;
  Timer? _timer;
  double _level = 0;
  double _frequencyMultiplier = 1;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    _random = context.random;
    _emit = context.emit;
    _frequencyMultiplier = params['frequencyMultiplier'] ?? 1;
    _strikeSource ??= await context.backend.loadWaveform(WaveFormType.sin);
    _partialSource ??= await context.backend.loadWaveform(WaveFormType.sin);
    return const [];
  }

  @override
  void apply(AudioBackend backend, double level) {
    _level = level;
  }

  @override
  void start(AudioBackend backend) {
    stop(backend);
    _timer = Timer.periodic(_tick, (_) => _maybeRing(backend));
  }

  @override
  void stop(AudioBackend backend) {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose(AudioBackend backend) {
    stop(backend);
    final strike = _strikeSource;
    final partial = _partialSource;
    if (strike != null) backend.disposeSource(strike);
    if (partial != null) backend.disposeSource(partial);
    _strikeSource = null;
    _partialSource = null;
  }

  void _maybeRing(AudioBackend backend) {
    final random = _random;
    final strikeSource = _strikeSource;
    final partialSource = _partialSource;
    if (random == null ||
        strikeSource == null ||
        partialSource == null ||
        _level <= 0) {
      return;
    }
    if (random.nextDouble() >= _level * 0.6) return;

    final note = _notes[random.nextInt(_notes.length)] * _frequencyMultiplier;
    _emit?.call(
      ProceduralSoundEvent(soundId: id, intensity: _level, frequencyHz: note),
    );

    backend.setWaveformFreq(strikeSource, note);
    final strike = backend.play(strikeSource, volume: _level * 0.15);
    backend.fadeVolume(strike, 0, const Duration(milliseconds: 2200));
    backend.scheduleStop(strike, const Duration(milliseconds: 2300));

    backend.setWaveformFreq(partialSource, note * _partialRatio);
    final shimmer = backend.play(partialSource, volume: _level * 0.05);
    backend.fadeVolume(shimmer, 0, const Duration(milliseconds: 1500));
    backend.scheduleStop(shimmer, const Duration(milliseconds: 1600));
  }
}

/// High-frequency chatter layer; `centerHz` and `q` tune the band.
class FocusCicadaVoice extends ProceduralVoice {
  @override
  String get id => 'cicada';

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final wav = context.synth.bandNoiseWav(
      centerHz: params['centerHz'] ?? 4800,
      q: params['q'] ?? 9,
      random: context.random,
      transform: _cicadaModulation,
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

double _cicadaModulation(double sample, double timeSeconds) {
  final buzz =
      0.5 + 0.5 * (math.sin(2 * math.pi * 72 * timeSeconds) >= 0 ? 1 : 0);
  final swell = 0.6 + 0.4 * math.sin(2 * math.pi * 0.16 * timeSeconds);
  return sample * buzz * swell;
}
