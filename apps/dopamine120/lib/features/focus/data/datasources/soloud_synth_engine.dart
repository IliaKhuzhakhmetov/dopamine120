import 'dart:async';
import 'dart:math' as math;

import 'package:app_logger/app_logger.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../../domain/entities/acoustic_profile.dart';
import '../../domain/entities/sound_layer.dart';

/// Procedural ambient synth built on `flutter_soloud`.
///
/// Recreates the reference Web Audio graph: three detuned drone oscillators, a
/// sub-bass pulse with a tremolo LFO, two loops of pre-shaped noise (rain and
/// cicada), randomly scheduled bell pings, and a shared filter → reverb → echo
/// bus whose settings come from the active [AcousticProfile].
///
/// All voices are created once and kept looping at zero volume; mixing a layer
/// just nudges a handle's volume, so changes are click-free and real time.
class SoloudSynthEngine {
  SoloudSynthEngine({SoLoud? soloud, math.Random? random})
    : _soloud = soloud ?? SoLoud.instance,
      _random = random ?? math.Random();

  /// Notes the bell layer arpeggiates through (a warm major pentatonic, an
  /// octave below the reference so the pings read as mellow chimes instead of
  /// shrill plinks on a small speaker).
  static const List<double> _bellNotes = [261.63, 293.66, 329.63, 392.0, 440.0];

  /// Inharmonic upper partial that gives the bell its metallic shimmer; a real
  /// bell's first overtone sits near this ratio above the strike tone.
  static const double _bellPartialRatio = 2.76;

  static const int _sampleRate = 44100;
  static const int _wavHeaderBytes = 44;
  static const Duration _bellTick = Duration(milliseconds: 430);
  static const double _webUnlockVolume = 0.0001;
  static const AcousticProfile _defaultProfile = AcousticProfile(
    filterShape: AcousticFilterShape.lowpass,
    cutoffHz: 16000,
    resonance: 0.1,
    reverbWet: 0.07,
    roomSize: 0.4,
    delaySeconds: 0.30,
    delayDecay: 0,
    delayWet: 0,
    masterGain: 0.55,
  );

  final SoLoud _soloud;
  final math.Random _random;

  bool _building = false;
  Future<void>? _buildOp;

  // Layer voices.
  final List<SoundHandle> _droneHandles = [];
  SoundHandle? _pulseHandle;
  SoundHandle? _rainHandle;
  SoundHandle? _cicadaHandle;
  AudioSource? _bellSource;
  AudioSource? _bellPartialSource;

  Timer? _bellTimer;
  double _bellLevel = 0;
  AcousticProfile _currentProfile = _defaultProfile;
  double _temporalDistortion = 0;

  /// Whether the engine has finished wiring its voices.
  bool get isReady => _bellSource != null;

  /// Boots the engine (once) and resumes all voices and the bell scheduler.
  Future<void> start() async {
    await _ensureBuilt();
    for (final handle in _allHandles) {
      _soloud.setPause(handle, false);
    }
    _startBellTimer();
  }

  /// Silences the scheduler and pauses every voice, leaving the engine warm.
  Future<void> stop() async {
    _bellTimer?.cancel();
    _bellTimer = null;
    if (!isReady) return;
    for (final handle in _allHandles) {
      _soloud.setPause(handle, true);
    }
  }

  /// Sets the audible level of [layer] in `0..1`.
  Future<void> setLayer(SoundLayer layer, double level) async {
    await _ensureBuilt();
    final value = level.clamp(0.0, 1.0);
    switch (layer) {
      case SoundLayer.drone:
        for (final handle in _droneHandles) {
          _soloud.setVolume(handle, value * 0.15);
        }
      case SoundLayer.rain:
        _setVolume(_rainHandle, value * 0.20);
      case SoundLayer.pulse:
        final handle = _pulseHandle;
        if (handle == null) break;
        if (value <= 0) {
          _soloud.setVolume(handle, 0);
        } else {
          // Slow tremolo around the pulse level, mirroring the reference LFO.
          // The pulse voice carries upper harmonics (see `_buildHarmonicWav`),
          // so a small speaker reconstructs the missing sub-bass fundamental
          // and the breathing stays audible instead of vanishing.
          _soloud.oscillateVolume(
            handle,
            value * 0.16,
            value * 0.46,
            const Duration(milliseconds: 1400),
          );
        }
      case SoundLayer.bell:
        _bellLevel = value;
      case SoundLayer.cicada:
        _setVolume(_cicadaHandle, value * 0.26);
    }
  }

  /// Re-tunes the shared filter/reverb/echo bus and master gain.
  Future<void> applyProfile(AcousticProfile profile) async {
    await _ensureBuilt();
    _currentProfile = profile;
    _applyProfileToBus(profile, _temporalDistortion);
  }

  /// Temporarily bends the shared bus while the orb is pressed.
  Future<void> setTemporalDistortion(double amount) async {
    await _ensureBuilt();
    _temporalDistortion = amount.clamp(0.0, 1.0).toDouble();
    _applyProfileToBus(_currentProfile, _temporalDistortion);
  }

  void _applyProfileToBus(AcousticProfile profile, double distortion) {
    final bend = distortion.clamp(0.0, 1.0).toDouble();
    final warpedCutoff = _mix(
      profile.cutoffHz,
      math.max(120, profile.cutoffHz * 0.38),
      bend,
    );
    final warpedResonance = _mix(
      profile.resonance,
      math.max(3.2, profile.resonance * 3.4),
      bend,
    );

    final biquad = _soloud.filters.biquadResonantFilter;
    biquad.type.value = profile.filterShape == AcousticFilterShape.lowpass
        ? 0
        : 2;
    biquad.frequency.value = warpedCutoff.clamp(10.0, 16000.0);
    biquad.resonance.value = warpedResonance.clamp(0.1, 20.0);
    biquad.wet.value = 1;

    final reverb = _soloud.filters.freeverbFilter;
    reverb.wet.value = (profile.reverbWet + bend * 0.08).clamp(0.0, 1.0);
    reverb.roomSize.value = (profile.roomSize + bend * 0.08).clamp(0.0, 1.0);
    reverb.damp.value = 0.35;

    final echo = _soloud.filters.echoFilter;
    echo.delay.value = _mix(
      profile.delaySeconds,
      math.max(0.035, profile.delaySeconds * 0.62),
      bend,
    ).clamp(0.001, 1.0);
    echo.decay.value = (profile.delayDecay + bend * 0.22).clamp(0.0, 1.0);
    echo.wet.value = (profile.delayWet + bend * 0.18).clamp(0.0, 1.0);

    _soloud.setGlobalVolume(
      (profile.masterGain * (1 - bend * 0.12)).clamp(0.0, 1.0),
    );
  }

  /// Tears the engine down and releases native resources.
  Future<void> dispose() async {
    _bellTimer?.cancel();
    _bellTimer = null;
    if (_soloud.isInitialized) {
      _soloud.deinit();
    }
    _droneHandles.clear();
    _pulseHandle = null;
    _rainHandle = null;
    _cicadaHandle = null;
    _bellSource = null;
    _bellPartialSource = null;
  }

  Iterable<SoundHandle> get _allHandles => [
    ..._droneHandles,
    _pulseHandle,
    _rainHandle,
    _cicadaHandle,
  ].whereType<SoundHandle>();

  void _setVolume(SoundHandle? handle, double volume) {
    if (handle != null) _soloud.setVolume(handle, volume);
  }

  Future<void> _ensureBuilt() {
    if (isReady) return Future.value();
    return _buildOp ??= _build();
  }

  Future<void> _build() async {
    if (_building) return;
    _building = true;
    try {
      if (!_soloud.isInitialized) {
        // flutter_soloud does not manage the iOS/macOS audio session, so the
        // OS defaults to a category the hardware mute switch silences. The
        // `music` configuration uses the playback category, letting ambience
        // play regardless of the ring/silent switch.
        await _configureAudioSession();
        await _soloud.init();
      }

      // Drone: a low triangle chord with a faintly detuned twin (110 vs 110.5)
      // whose slow beating gives the bed width and movement, plus a 55 Hz sine
      // that adds body felt on headphones without muddying a phone speaker.
      _droneHandles
        ..clear()
        ..add(await _playOscillator(WaveForm.sin, 55))
        ..add(await _playOscillator(WaveForm.triangle, 110))
        ..add(await _playOscillator(WaveForm.triangle, 110.5))
        ..add(await _playOscillator(WaveForm.sin, 165))
        ..add(await _playOscillator(WaveForm.sin, 220));

      // Pulse: a harmonic-rich 55 Hz tone (not a bare sine) so the breathing
      // survives on speakers that can't reproduce true sub-bass.
      _pulseHandle = await _playNoise(
        _buildHarmonicWav(
          fundamentalHz: 55,
          harmonicGains: const [0.35, 1.0, 0.65, 0.4, 0.2],
        ),
      );

      // Rain & cicada: pre-shaped noise loops. Rain uses softer pink noise in a
      // lower, wider band so it reads as depth rather than midrange hiss.
      _rainHandle = await _playNoise(
        _buildNoiseWav(centreHz: 1050, q: 0.5, pink: true),
      );
      _cicadaHandle = await _playNoise(
        _buildNoiseWav(centreHz: 4800, q: 9, amplitudeModulated: true),
      );

      // Bell: a sine strike tone plus a separate inharmonic upper partial,
      // both retuned per ping by the scheduler.
      _bellSource = await _soloud.loadWaveform(WaveForm.sin, false, 1, 1);
      _bellPartialSource = await _soloud.loadWaveform(
        WaveForm.sin,
        false,
        1,
        1,
      );

      // Activate the shared bus so dimensions can morph it.
      _soloud.filters.biquadResonantFilter.activate();
      _soloud.filters.freeverbFilter.activate();
      _soloud.filters.echoFilter.activate();
    } catch (error, stackTrace) {
      Log.e(
        'SoloudSynthEngine build failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _building = false;
    }
  }

  Future<void> _configureAudioSession() async {
    if (kIsWeb) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (error, stackTrace) {
      // Non-fatal: a missing session just falls back to OS defaults.
      Log.w('Audio session configuration failed: $error');
      Log.d(stackTrace.toString());
    }
  }

  Future<SoundHandle> _playOscillator(WaveForm waveform, double freq) async {
    final source = await _soloud.loadWaveform(waveform, false, 1, 1);
    _soloud.setWaveformFreq(source, freq);
    final handle = _soloud.play(
      source,
      volume: kIsWeb ? _webUnlockVolume : 0,
      looping: true,
    );
    _keepLoopAlive(handle);
    return handle;
  }

  Future<SoundHandle> _playNoise(Uint8List wav) async {
    if (kIsWeb) {
      return _playPcmStream(_pcmDataFromGeneratedWav(wav));
    }

    final source = await _soloud.loadMem(
      'focus_noise_${wav.hashCode}.wav',
      wav,
    );
    final handle = _soloud.play(
      source,
      volume: kIsWeb ? _webUnlockVolume : 0,
      looping: true,
    );
    _keepLoopAlive(handle);
    return handle;
  }

  SoundHandle _playPcmStream(Uint8List pcm) {
    // SoLoud stores stream samples as f32 internally (4 bytes/sample), so the
    // buffer ceiling must be sized against the decoded float length, not the
    // incoming s16le bytes. Our PCM is 2 bytes/sample, so the float buffer
    // needs ~2x the byte count; under-sizing it makes `addAudioDataStream`
    // overflow mid-add and throw `SoLoudPcmBufferFullCppException`.
    final sampleCount = pcm.length ~/ 2;
    final source = _soloud.setBufferStream(
      maxBufferSizeBytes: sampleCount * 4 + 1024,
      bufferingTimeNeeds: 0.05,
      sampleRate: _sampleRate,
      channels: Channels.mono,
      format: BufferType.s16le,
    );
    _soloud.addAudioDataStream(source, pcm);
    _soloud.setDataIsEnded(source);

    final handle = _soloud.play(
      source,
      volume: _webUnlockVolume,
      looping: true,
    );
    _keepLoopAlive(handle);
    return handle;
  }

  Uint8List _pcmDataFromGeneratedWav(Uint8List wav) {
    if (wav.length <= _wavHeaderBytes) return Uint8List(0);
    return Uint8List.sublistView(wav, _wavHeaderBytes);
  }

  void _keepLoopAlive(SoundHandle handle) {
    _soloud.setProtectVoice(handle, true);
    _soloud.setInaudibleBehavior(handle, true, false);
  }

  void _startBellTimer() {
    _bellTimer?.cancel();
    _bellTimer = Timer.periodic(_bellTick, (_) => _maybeRingBell());
  }

  void _maybeRingBell() {
    final source = _bellSource;
    final partial = _bellPartialSource;
    if (source == null || partial == null || _bellLevel <= 0) return;
    if (_random.nextDouble() >= _bellLevel * 0.6) return;

    final note = _bellNotes[_random.nextInt(_bellNotes.length)];

    // Strike tone: instant attack, long soft tail.
    _soloud.setWaveformFreq(source, note);
    final strike = _soloud.play(source, volume: _bellLevel * 0.15);
    _soloud.fadeVolume(strike, 0, const Duration(milliseconds: 2200));
    _soloud.scheduleStop(strike, const Duration(milliseconds: 2300));

    // Inharmonic shimmer: quieter and shorter so it colours the attack and
    // decays away first, the way a real bell's overtones do.
    _soloud.setWaveformFreq(partial, note * _bellPartialRatio);
    final shimmer = _soloud.play(partial, volume: _bellLevel * 0.05);
    _soloud.fadeVolume(shimmer, 0, const Duration(milliseconds: 1500));
    _soloud.scheduleStop(shimmer, const Duration(milliseconds: 1600));
  }

  /// Builds a 1 s seamlessly looping mono 16-bit WAV from a harmonic series.
  ///
  /// [harmonicGains] weights the fundamental ([fundamentalHz]) and its integer
  /// overtones; choosing [fundamentalHz] as a whole number of Hz keeps every
  /// partial phase-aligned at the loop boundary so the tone is click-free.
  Uint8List _buildHarmonicWav({
    required double fundamentalHz,
    required List<double> harmonicGains,
  }) {
    const seconds = 1;
    final length = _sampleRate * seconds;
    final samples = Float64List(length);
    var peak = 1e-9;

    for (var i = 0; i < length; i++) {
      final t = i / _sampleRate;
      var sample = 0.0;
      for (var h = 0; h < harmonicGains.length; h++) {
        final freq = fundamentalHz * (h + 1);
        sample += harmonicGains[h] * math.sin(2 * math.pi * freq * t);
      }
      samples[i] = sample;
      final magnitude = sample.abs();
      if (magnitude > peak) peak = magnitude;
    }

    return _encodeWavMono16(samples, 0.85 / peak);
  }

  /// Builds a ~2 s looping mono 16-bit WAV of band-shaped noise.
  ///
  /// A state-variable filter centres the noise around [centreHz] with the given
  /// [q]; [amplitudeModulated] adds the cicada's fast buzz and slow swell. When
  /// [pink] is set the source noise is shaped to a 1/f spectrum, which sounds
  /// fuller and softer than white noise — the difference between rainfall and
  /// hiss on a small speaker.
  Uint8List _buildNoiseWav({
    required double centreHz,
    required double q,
    bool amplitudeModulated = false,
    bool pink = false,
  }) {
    const seconds = 2;
    final length = _sampleRate * seconds;
    final samples = Float64List(length);

    // State-variable bandpass over the (optionally pink) noise source.
    final f = 2 * math.sin(math.pi * centreHz / _sampleRate);
    final damping = (1 / q).clamp(0.0, 1.0);
    var low = 0.0;
    var band = 0.0;
    var peak = 1e-9;

    // Paul Kellet's economy pink-noise filter state.
    var b0 = 0.0;
    var b1 = 0.0;
    var b2 = 0.0;

    for (var i = 0; i < length; i++) {
      final white = _random.nextDouble() * 2 - 1;
      double input;
      if (pink) {
        b0 = 0.99765 * b0 + white * 0.0990460;
        b1 = 0.96300 * b1 + white * 0.2965164;
        b2 = 0.57000 * b2 + white * 1.0526913;
        input = (b0 + b1 + b2 + white * 0.1848) * 0.25;
      } else {
        input = white;
      }
      low += f * band;
      final high = input - low - damping * band;
      band += f * high;
      var sample = band;

      if (amplitudeModulated) {
        final t = i / _sampleRate;
        final buzz = 0.5 + 0.5 * (math.sin(2 * math.pi * 72 * t) >= 0 ? 1 : 0);
        final swell = 0.6 + 0.4 * math.sin(2 * math.pi * 0.16 * t);
        sample *= buzz * swell;
      }

      samples[i] = sample;
      final magnitude = sample.abs();
      if (magnitude > peak) peak = magnitude;
    }

    // Normalise to avoid clipping, then encode.
    final gain = 0.9 / peak;
    return _encodeWavMono16(samples, gain);
  }

  Uint8List _encodeWavMono16(Float64List samples, double gain) {
    final dataBytes = samples.length * 2;
    final bytes = ByteData(44 + dataBytes);
    var offset = 0;

    void writeString(String value) {
      for (final unit in value.codeUnits) {
        bytes.setUint8(offset++, unit);
      }
    }

    writeString('RIFF');
    bytes.setUint32(offset, 36 + dataBytes, Endian.little);
    offset += 4;
    writeString('WAVE');
    writeString('fmt ');
    bytes.setUint32(offset, 16, Endian.little);
    offset += 4;
    bytes.setUint16(offset, 1, Endian.little); // PCM
    offset += 2;
    bytes.setUint16(offset, 1, Endian.little); // mono
    offset += 2;
    bytes.setUint32(offset, _sampleRate, Endian.little);
    offset += 4;
    bytes.setUint32(offset, _sampleRate * 2, Endian.little); // byte rate
    offset += 4;
    bytes.setUint16(offset, 2, Endian.little); // block align
    offset += 2;
    bytes.setUint16(offset, 16, Endian.little); // bits per sample
    offset += 2;
    writeString('data');
    bytes.setUint32(offset, dataBytes, Endian.little);
    offset += 4;

    for (final sample in samples) {
      final clamped = (sample * gain).clamp(-1.0, 1.0);
      bytes.setInt16(offset, (clamped * 32767).round(), Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  double _mix(double from, double to, double amount) =>
      from + (to - from) * amount;
}
