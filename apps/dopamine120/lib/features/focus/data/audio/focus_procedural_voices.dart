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
  FocusBirdsongVoice(),
  FocusBambooVoice(),
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

/// Sparse procedural birdsong: randomly scheduled chirp phrases, each a short
/// burst of pitch-swept syllables in the upper register. The knob's level both
/// raises the volume and makes the birds more talkative.
class FocusBirdsongVoice extends ProceduralVoice {
  @override
  String get id => 'birdsong';

  /// Base pitches for a phrase, a bright pentatonic spread in the bird register.
  static const List<double> _notes = [1760.0, 1975.5, 2349.3, 2637.0, 3135.9];

  math.Random? _random;
  VoiceSource? _chirpSource;
  Timer? _phraseTimer;
  final List<Timer> _syllableTimers = [];
  bool _running = false;
  double _level = 0;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    _random = context.random;
    _chirpSource ??= await context.backend.loadWaveform(WaveFormType.sin);
    return const [];
  }

  @override
  void apply(AudioBackend backend, double level) {
    _level = level;
  }

  @override
  void start(AudioBackend backend) {
    stop(backend);
    _running = true;
    _schedulePhrase(backend);
  }

  @override
  void stop(AudioBackend backend) {
    _running = false;
    _phraseTimer?.cancel();
    _phraseTimer = null;
    for (final timer in _syllableTimers) {
      timer.cancel();
    }
    _syllableTimers.clear();
  }

  @override
  void dispose(AudioBackend backend) {
    stop(backend);
    final source = _chirpSource;
    if (source != null) backend.disposeSource(source);
    _chirpSource = null;
  }

  void _schedulePhrase(AudioBackend backend) {
    final random = _random;
    if (random == null) return;

    // Quieter knob → longer, sparser gaps between phrases.
    final density = 1 - math.min(_level, 1);
    final minMs = 1700 + (density * 3600).round();
    final spreadMs = 2400 + (density * 4200).round();
    _phraseTimer = Timer(
      Duration(milliseconds: minMs + random.nextInt(spreadMs)),
      () {
        _maybeSing(backend);
        if (_running) _schedulePhrase(backend);
      },
    );
  }

  void _maybeSing(AudioBackend backend) {
    final random = _random;
    final source = _chirpSource;
    if (random == null || source == null || _level <= 0) return;
    if (random.nextDouble() >= 0.22 + _level * 0.6) return;

    for (final timer in _syllableTimers) {
      timer.cancel();
    }
    _syllableTimers.clear();

    final base = _notes[random.nextInt(_notes.length)];
    final pan = (random.nextDouble() * 1.2 - 0.6).clamp(-1.0, 1.0).toDouble();
    final syllables = 2 + random.nextInt(4);
    var offsetMs = 0;
    for (var s = 0; s < syllables; s++) {
      final durMs = 60 + random.nextInt(70);
      final cents = (random.nextInt(5) - 2) / 12;
      final freq = base * math.pow(2, cents).toDouble();
      final startMs = offsetMs;
      _syllableTimers.add(
        Timer(Duration(milliseconds: startMs), () {
          _chirp(backend, source, freq, durMs, pan);
        }),
      );
      offsetMs += durMs + 30 + random.nextInt(70);
    }
  }

  void _chirp(
    AudioBackend backend,
    VoiceSource source,
    double freq,
    int durMs,
    double pan,
  ) {
    if (_level <= 0) return;

    // Start a touch flat and warble upward across the syllable for a chirp.
    backend.setWaveformFreq(source, freq * 0.94);
    final handle = backend.play(source, volume: _level * 0.10, pan: pan);
    const steps = 4;
    for (var i = 1; i <= steps; i++) {
      final sweptFreq = freq * (0.94 + 0.12 * (i / steps));
      _syllableTimers.add(
        Timer(Duration(milliseconds: (durMs * i / steps).round()), () {
          backend.setWaveformFreq(source, sweptFreq);
        }),
      );
    }
    backend.fadeVolume(handle, 0, Duration(milliseconds: durMs + 40));
    backend.scheduleStop(handle, Duration(milliseconds: durMs + 70));
  }
}

/// Rare wooden clacks, like the sticks of a dream-catcher tapping as it sways:
/// sparse single knocks and occasional two- or three-tap clusters with a fast,
/// woody decay. The knob's level sets the volume and how often the sticks knock.
class FocusBambooVoice extends ProceduralVoice {
  @override
  String get id => 'bamboo';

  /// Hollow wooden pitches; a clack lands on one of these per knock.
  static const List<double> _notes = [880.0, 987.8, 1174.7, 1318.5, 1567.0];

  /// Inharmonic overtone that gives the knock its dry, woody transient.
  static const double _partialRatio = 3.17;

  math.Random? _random;
  VoiceSource? _bodySource;
  VoiceSource? _partialSource;
  Timer? _eventTimer;
  final List<Timer> _tapTimers = [];
  bool _running = false;
  double _level = 0;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    _random = context.random;
    _bodySource ??= await context.backend.loadWaveform(WaveFormType.triangle);
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
    _running = true;
    _scheduleNext(backend);
  }

  @override
  void stop(AudioBackend backend) {
    _running = false;
    _eventTimer?.cancel();
    _eventTimer = null;
    for (final timer in _tapTimers) {
      timer.cancel();
    }
    _tapTimers.clear();
  }

  @override
  void dispose(AudioBackend backend) {
    stop(backend);
    final body = _bodySource;
    final partial = _partialSource;
    if (body != null) backend.disposeSource(body);
    if (partial != null) backend.disposeSource(partial);
    _bodySource = null;
    _partialSource = null;
  }

  void _scheduleNext(AudioBackend backend) {
    final random = _random;
    if (random == null) return;

    // Deliberately rare: long gaps between knocks even at full level.
    final density = 1 - math.min(_level, 1);
    final minMs = 3200 + (density * 5200).round();
    final spreadMs = 3600 + (density * 6400).round();
    _eventTimer = Timer(
      Duration(milliseconds: minMs + random.nextInt(spreadMs)),
      () {
        _maybeKnock(backend);
        if (_running) _scheduleNext(backend);
      },
    );
  }

  void _maybeKnock(AudioBackend backend) {
    final random = _random;
    if (random == null ||
        _bodySource == null ||
        _partialSource == null ||
        _level <= 0) {
      return;
    }
    if (random.nextDouble() >= 0.3 + _level * 0.5) return;

    for (final timer in _tapTimers) {
      timer.cancel();
    }
    _tapTimers.clear();

    final base = _notes[random.nextInt(_notes.length)];
    final pan = (random.nextDouble() * 1.1 - 0.55).clamp(-1.0, 1.0).toDouble();
    // Most often a single tock; sometimes the sticks tap two or three times.
    final taps = 1 + (random.nextDouble() < 0.45 ? 1 + random.nextInt(2) : 0);
    var offsetMs = 0;
    for (var i = 0; i < taps; i++) {
      final cents = (random.nextInt(7) - 3) / 12;
      final freq = base * math.pow(2, cents).toDouble();
      final knockPan = (pan + (random.nextDouble() * 0.2 - 0.1))
          .clamp(-1.0, 1.0)
          .toDouble();
      _tapTimers.add(
        Timer(Duration(milliseconds: offsetMs), () {
          _knock(backend, freq, knockPan);
        }),
      );
      offsetMs += 90 + random.nextInt(120);
    }
  }

  void _knock(AudioBackend backend, double freq, double pan) {
    final body = _bodySource;
    final partial = _partialSource;
    if (body == null || partial == null || _level <= 0) return;

    // Woody body: short decay for a "tock" rather than a ring.
    backend.setWaveformFreq(body, freq);
    final tock = backend.play(body, volume: _level * 0.13, pan: pan);
    backend.fadeVolume(tock, 0, const Duration(milliseconds: 200));
    backend.scheduleStop(tock, const Duration(milliseconds: 240));

    // Inharmonic partial: a very fast click transient on top.
    backend.setWaveformFreq(partial, freq * _partialRatio);
    final tick = backend.play(partial, volume: _level * 0.05, pan: pan);
    backend.fadeVolume(tick, 0, const Duration(milliseconds: 90));
    backend.scheduleStop(tick, const Duration(milliseconds: 120));
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
