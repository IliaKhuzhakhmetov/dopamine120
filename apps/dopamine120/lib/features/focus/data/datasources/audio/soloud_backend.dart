import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'audio_backend.dart';

/// Adapts [AudioBackend] onto `flutter_soloud` and the OS audio session.
///
/// This is the only file in the focus feature that talks to SoLoud directly, so
/// it is also the only part that cannot run in a plain Dart test — everything
/// above it depends on the [AudioBackend] interface instead.
class SoLoudBackend implements AudioBackend {
  /// Wraps the SoLoud singleton by default; inject one for special cases.
  SoLoudBackend({SoLoud? soloud}) : _soloud = soloud ?? SoLoud.instance;

  final SoLoud _soloud;

  AudioSource _source(VoiceSource source) => source.raw as AudioSource;
  SoundHandle _handle(VoiceHandle handle) => handle.raw as SoundHandle;

  @override
  bool get isInitialized => _soloud.isInitialized;

  @override
  Future<void> init() async {
    await _configureAudioSession();
    await _soloud.init();
  }

  @override
  void dispose() {
    if (_soloud.isInitialized) _soloud.deinit();
  }

  @override
  Future<VoiceSource> loadWaveform(WaveForm waveform) async {
    final source = await _soloud.loadWaveform(waveform, false, 1, 1);
    return VoiceSource(source);
  }

  @override
  void setWaveformFreq(VoiceSource source, double freq) =>
      _soloud.setWaveformFreq(_source(source), freq);

  @override
  Future<VoiceSource> loadNoise(String name, Uint8List bytes) async {
    final source = await _soloud.loadMem(name, bytes);
    return VoiceSource(source);
  }

  @override
  VoiceSource openPcmStream({
    required int maxBufferSizeBytes,
    required double bufferingTimeNeeds,
    required int sampleRate,
  }) {
    final source = _soloud.setBufferStream(
      maxBufferSizeBytes: maxBufferSizeBytes,
      bufferingTimeNeeds: bufferingTimeNeeds,
      sampleRate: sampleRate,
      channels: Channels.mono,
      format: BufferType.s16le,
    );
    return VoiceSource(source);
  }

  @override
  void pushPcm(VoiceSource source, Uint8List bytes) =>
      _soloud.addAudioDataStream(_source(source), bytes);

  @override
  void endPcm(VoiceSource source) => _soloud.setDataIsEnded(_source(source));

  @override
  void disposeSource(VoiceSource source) {
    // Fire-and-forget: the swap already crossfaded the old voice to silence, so
    // we only need the buffer freed, not to await it.
    unawaited(_soloud.disposeSource(_source(source)));
  }

  @override
  VoiceHandle play(
    VoiceSource source, {
    double volume = 1,
    bool looping = false,
  }) {
    final handle = _soloud.play(
      _source(source),
      volume: volume,
      looping: looping,
    );
    return VoiceHandle(handle);
  }

  @override
  void setVolume(VoiceHandle handle, double volume) =>
      _soloud.setVolume(_handle(handle), volume);

  @override
  void setPause(VoiceHandle handle, bool pause) =>
      _soloud.setPause(_handle(handle), pause);

  @override
  void oscillateVolume(
    VoiceHandle handle,
    double from,
    double to,
    Duration period,
  ) => _soloud.oscillateVolume(_handle(handle), from, to, period);

  @override
  void fadeVolume(VoiceHandle handle, double to, Duration time) =>
      _soloud.fadeVolume(_handle(handle), to, time);

  @override
  void scheduleStop(VoiceHandle handle, Duration time) =>
      _soloud.scheduleStop(_handle(handle), time);

  @override
  void keepLoopAlive(VoiceHandle handle) {
    _soloud.setProtectVoice(_handle(handle), true);
    _soloud.setInaudibleBehavior(_handle(handle), true, false);
  }

  @override
  void applyBus(BusSettings settings) {
    final biquad = _soloud.filters.biquadResonantFilter;
    biquad.type.value = settings.filterType.toDouble();
    biquad.frequency.value = settings.frequency;
    biquad.resonance.value = settings.resonance;
    biquad.wet.value = settings.filterWet;

    final reverb = _soloud.filters.freeverbFilter;
    reverb.wet.value = settings.reverbWet;
    reverb.roomSize.value = settings.roomSize;
    reverb.damp.value = settings.damp;

    final echo = _soloud.filters.echoFilter;
    echo.delay.value = settings.echoDelay;
    echo.decay.value = settings.echoDecay;
    echo.wet.value = settings.echoWet;

    _soloud.setGlobalVolume(settings.globalVolume);
  }

  @override
  void activateBus() {
    _soloud.filters.biquadResonantFilter.activate();
    _soloud.filters.freeverbFilter.activate();
    _soloud.filters.echoFilter.activate();
  }

  Future<void> _configureAudioSession() async {
    if (kIsWeb) return;

    try {
      // flutter_soloud does not manage the iOS/macOS audio session, so the OS
      // defaults to a category the hardware mute switch silences. The `music`
      // configuration uses the playback category, letting ambience play
      // regardless of the ring/silent switch.
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (error, stackTrace) {
      // Non-fatal: a missing session just falls back to OS defaults.
      Log.w('Audio session configuration failed: $error');
      Log.d(stackTrace.toString());
    }
  }
}
