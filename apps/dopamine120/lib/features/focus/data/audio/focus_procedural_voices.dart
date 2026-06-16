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

/// Soft pink noise layer; `centerHz` and `q` tune the band.
class FocusRainVoice extends ProceduralVoice {
  @override
  String get id => 'rain';

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final left = context.synth.bandNoiseWav(
      centerHz: params['centerHz'] ?? 920,
      q: params['q'] ?? 0.38,
      color: NoiseColor.pink,
      seconds: 5.5,
      random: context.random,
      transform: _rainBreath,
      crossfadeSeconds: 0.45,
    );
    final right = context.synth.bandNoiseWav(
      centerHz: (params['centerHz'] ?? 920) * 1.08,
      q: params['q'] ?? 0.38,
      color: NoiseColor.pink,
      seconds: 5.5,
      random: context.random,
      transform: _rainBreath,
      crossfadeSeconds: 0.45,
    );
    return [
      await context.player.noise(left, pan: -0.24),
      await context.player.noise(right, pan: 0.24),
    ];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.11);
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

/// Sparse note pings that also drive the focus orb's bell particles.
class FocusBellVoice extends ProceduralVoice {
  @override
  String get id => 'bell';

  static const List<double> _notes = [
    220.00,
    246.94,
    261.63,
    293.66,
    329.63,
    392.00,
  ];
  static const double _partialRatio = 2.71;
  static const double _highPartialRatio = 4.13;

  math.Random? _random;
  void Function(ProceduralSoundEvent event)? _emit;
  VoiceSource? _strikeSource;
  VoiceSource? _partialSource;
  VoiceSource? _highPartialSource;
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
    _highPartialSource ??= await context.backend.loadWaveform(WaveFormType.sin);
    return const [];
  }

  @override
  void apply(AudioBackend backend, double level) {
    _level = level;
  }

  @override
  void start(AudioBackend backend) {
    stop(backend);
    _scheduleNext(backend);
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
    final highPartial = _highPartialSource;
    if (strike != null) backend.disposeSource(strike);
    if (partial != null) backend.disposeSource(partial);
    if (highPartial != null) backend.disposeSource(highPartial);
    _strikeSource = null;
    _partialSource = null;
    _highPartialSource = null;
  }

  void _scheduleNext(AudioBackend backend) {
    final random = _random;
    if (random == null) return;

    final density = 1 - math.min(_level, 1);
    final minMs = 460 + (density * 360).round();
    final spreadMs = 720 + (density * 620).round();
    _timer = Timer(
      Duration(milliseconds: minMs + random.nextInt(spreadMs)),
      () {
        _maybeRing(backend);
        if (_timer != null) _scheduleNext(backend);
      },
    );
  }

  void _maybeRing(AudioBackend backend) {
    final random = _random;
    final strikeSource = _strikeSource;
    final partialSource = _partialSource;
    final highPartialSource = _highPartialSource;
    if (random == null ||
        strikeSource == null ||
        partialSource == null ||
        highPartialSource == null ||
        _level <= 0) {
      return;
    }
    if (random.nextDouble() >= 0.16 + _level * 0.52) return;

    final octave = random.nextDouble() < 0.18 ? 0.5 : 1.0;
    final cents = (random.nextDouble() * 10 - 5) / 1200;
    final drift = math.pow(2, cents).toDouble();
    final note =
        _notes[random.nextInt(_notes.length)] *
        octave *
        drift *
        _frequencyMultiplier;
    _emit?.call(
      ProceduralSoundEvent(soundId: id, intensity: _level, frequencyHz: note),
    );

    backend.setWaveformFreq(strikeSource, note);
    final pan = random.nextDouble() * 0.7 - 0.35;
    final strike = backend.play(strikeSource, volume: _level * 0.11, pan: pan);
    backend.fadeVolume(strike, 0, const Duration(milliseconds: 3400));
    backend.scheduleStop(strike, const Duration(milliseconds: 3600));

    backend.setWaveformFreq(partialSource, note * _partialRatio);
    final shimmer = backend.play(
      partialSource,
      volume: _level * 0.032,
      pan: (pan * -0.45).clamp(-1.0, 1.0).toDouble(),
    );
    backend.fadeVolume(shimmer, 0, const Duration(milliseconds: 2400));
    backend.scheduleStop(shimmer, const Duration(milliseconds: 2600));

    backend.setWaveformFreq(highPartialSource, note * _highPartialRatio);
    final air = backend.play(
      highPartialSource,
      volume: _level * 0.012,
      pan: (pan + 0.18).clamp(-1.0, 1.0).toDouble(),
    );
    backend.fadeVolume(air, 0, const Duration(milliseconds: 1200));
    backend.scheduleStop(air, const Duration(milliseconds: 1400));
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
      centerHz: params['centerHz'] ?? 3900,
      q: params['q'] ?? 5.2,
      color: NoiseColor.pink,
      seconds: 8,
      random: context.random,
      transform: _cicadaModulation,
      crossfadeSeconds: 0.5,
    );
    return [await context.player.noise(wav, pan: 0.16)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * 0.18);
    }
  }
}

double _rainBreath(double sample, double timeSeconds) {
  final slow = 0.82 + 0.18 * math.sin(2 * math.pi * 0.071 * timeSeconds);
  final fine = 0.94 + 0.06 * math.sin(2 * math.pi * 0.37 * timeSeconds + 0.8);
  return sample * slow * fine;
}

double _pulseBody(double sample, double timeSeconds) {
  final tremolo =
      0.62 +
      0.25 * math.sin(2 * math.pi * 0.58 * timeSeconds) +
      0.13 * math.sin(2 * math.pi * 1.16 * timeSeconds + 1.2);
  final bloom = 0.86 + 0.14 * math.sin(2 * math.pi * 0.19 * timeSeconds + 0.4);
  return sample * tremolo * bloom;
}

double _cicadaModulation(double sample, double timeSeconds) {
  final wing =
      0.56 +
      0.23 * math.sin(2 * math.pi * 43 * timeSeconds) +
      0.14 * math.sin(2 * math.pi * 61 * timeSeconds + 1.7);
  final pulse = 0.72 + 0.28 * math.sin(2 * math.pi * 0.25 * timeSeconds);
  final flicker = 0.9 + 0.1 * math.sin(2 * math.pi * 7.25 * timeSeconds + 0.3);
  return sample * wing.clamp(0.0, 1.0) * pulse * flicker;
}
