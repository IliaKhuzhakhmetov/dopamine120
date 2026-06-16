import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'audio_backend.dart';

/// Adapts [AudioBackend] onto `flutter_soloud` and the OS audio session.
///
/// This is the only file in the focus feature that talks to SoLoud directly, so
/// it is also the only part that cannot run in a plain Dart test — everything
/// above it depends on the [AudioBackend] interface instead.
class SoLoudAudioBackend implements AudioBackend {
  /// Wraps the SoLoud singleton by default; inject one for special cases.
  SoLoudAudioBackend({
    SoLoud? soloud,
    AssetBundle? assetBundle,
    bool? isWeb,
    void Function(Object error, StackTrace stackTrace)? onSessionError,
  }) : _soloud = soloud ?? SoLoud.instance,
       _assetBundle = assetBundle ?? rootBundle,
       _isWeb = isWeb ?? kIsWeb,
       _onSessionError = onSessionError;

  final SoLoud _soloud;
  final AssetBundle _assetBundle;
  final bool _isWeb;
  final void Function(Object error, StackTrace stackTrace)? _onSessionError;

  AudioSource _source(VoiceSource source) => source.raw as AudioSource;
  SoundHandle _handle(VoiceHandle handle) => handle.raw as SoundHandle;
  Bus _bus(BusRef bus) => bus.raw as Bus;

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
  Future<VoiceSource> loadWaveform(WaveFormType waveform) async {
    final source = await _soloud.loadWaveform(_waveform(waveform), false, 1, 1);
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
  Future<AudioSourceRef> loadAsset(
    String assetKey, {
    LoadModePolicy policy = LoadModePolicy.memory,
  }) async {
    if (_isWeb) {
      final data = await _assetBundle.load(assetKey);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final source = await _soloud.loadMem(assetKey, bytes);
      return AudioSourceRef(source);
    }

    final source = await _soloud.loadAsset(assetKey, mode: _loadMode(policy));
    return AudioSourceRef(source);
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
    double pan = 0,
    bool looping = false,
  }) {
    final handle = _soloud.play(
      _source(source),
      volume: volume,
      pan: pan,
      looping: looping,
    );
    return VoiceHandle(handle);
  }

  @override
  Future<BusRef> createBus(String id) async {
    final bus = _soloud.createMixingBus(name: id);
    bus.playOnEngine();
    return BusRef(bus);
  }

  @override
  VoiceRef playRequest(PlayRequest request) {
    final bus = request.bus;
    final handle = bus == null
        ? _soloud.play(
            _source(request.source),
            volume: request.volume,
            pan: request.pan,
            looping: request.looping,
          )
        : _bus(bus).play(
            _source(request.source),
            volume: request.volume,
            pan: request.pan,
            looping: request.looping,
          );
    return VoiceRef(handle);
  }

  @override
  Future<void> stop(VoiceRef voice, {Duration fadeOut = Duration.zero}) async {
    if (fadeOut > Duration.zero) {
      _soloud.fadeVolume(_handle(voice), 0, fadeOut);
      _soloud.scheduleStop(_handle(voice), fadeOut);
      return;
    }
    await _soloud.stop(_handle(voice));
  }

  @override
  void setVolume(VoiceHandle handle, double volume) =>
      _soloud.setVolume(_handle(handle), volume);

  @override
  void setBusVolume(BusRef bus, double volume) {
    final handle = _bus(bus).soundHandle;
    if (handle != null) _soloud.setVolume(handle, volume);
  }

  @override
  void setParam(AudioParamAddress address, double value) {
    final bus = address.bus;
    if (address.name == 'volume' && bus != null) {
      setBusVolume(bus, value);
    }
  }

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
    if (_isWeb) return;

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
      _onSessionError?.call(error, stackTrace);
    }
  }

  WaveForm _waveform(WaveFormType waveform) => switch (waveform) {
    WaveFormType.sin => WaveForm.sin,
    WaveFormType.triangle => WaveForm.triangle,
  };

  LoadMode _loadMode(LoadModePolicy policy) => switch (policy) {
    LoadModePolicy.memory => LoadMode.memory,
    LoadModePolicy.disk => LoadMode.disk,
  };
}
