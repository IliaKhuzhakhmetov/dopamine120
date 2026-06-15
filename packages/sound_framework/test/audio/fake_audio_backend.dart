import 'dart:typed_data';

import 'package:sound_framework/sound_framework.dart';

/// A recording [AudioBackend] for unit tests.
///
/// Hands out integer-tagged [VoiceSource]/[VoiceHandle] tokens and logs every
/// call so tests can assert what the engine asked the audio layer to do, with no
/// native SoLoud anywhere in the tree.
class FakeAudioBackend implements AudioBackend {
  bool _initialized = false;
  int _sourceCounter = 0;
  int _handleCounter = 0;

  /// Number of [init] calls.
  int initCount = 0;

  /// Number of [dispose] calls.
  int disposeCount = 0;

  /// Waveforms passed to [loadWaveform], in order.
  final List<WaveFormType> loadedWaveforms = [];

  /// Names passed to [loadNoise], in order.
  final List<String> loadedNoises = [];

  /// PCM chunks pushed via [pushPcm].
  final List<Uint8List> pushedPcm = [];

  /// Number of [openPcmStream] calls.
  int pcmStreamCount = 0;

  /// Every [play] call, in order.
  final List<PlayCall> plays = [];

  /// Last volume set per handle id (via [play] or [setVolume]).
  final Map<int, double> volumes = {};

  /// Last pause state per handle id.
  final Map<int, bool> paused = {};

  /// Handle ids kept alive via [keepLoopAlive].
  final Set<int> keptAlive = {};

  /// Last frequency set per source id.
  final Map<int, double> waveformFreq = {};

  /// Every [oscillateVolume] call.
  final List<OscillateCall> oscillations = [];

  /// Every [fadeVolume] call.
  final List<FadeCall> fades = [];

  /// Every [scheduleStop] call.
  final List<ScheduleStopCall> scheduledStops = [];

  /// Every [BusSettings] pushed via [applyBus], in order.
  final List<BusSettings> busSettings = [];

  /// Number of [activateBus] calls.
  int busActivations = 0;

  /// Reads back the last volume of [handle].
  double? volumeOf(VoiceHandle handle) => volumes[handle.raw as int];

  /// Reads back the last pause state of [handle].
  bool? pausedOf(VoiceHandle handle) => paused[handle.raw as int];

  /// Whether [handle] was kept alive.
  bool isKeptAlive(VoiceHandle handle) => keptAlive.contains(handle.raw as int);

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    initCount++;
    _initialized = true;
  }

  @override
  void dispose() {
    disposeCount++;
    _initialized = false;
  }

  @override
  Future<VoiceSource> loadWaveform(WaveFormType waveform) async {
    loadedWaveforms.add(waveform);
    return VoiceSource(_sourceCounter++);
  }

  @override
  void setWaveformFreq(VoiceSource source, double freq) =>
      waveformFreq[source.raw as int] = freq;

  @override
  Future<VoiceSource> loadNoise(String name, Uint8List bytes) async {
    loadedNoises.add(name);
    return VoiceSource(_sourceCounter++);
  }

  @override
  VoiceSource openPcmStream({
    required int maxBufferSizeBytes,
    required double bufferingTimeNeeds,
    required int sampleRate,
  }) {
    pcmStreamCount++;
    return VoiceSource(_sourceCounter++);
  }

  @override
  void pushPcm(VoiceSource source, Uint8List bytes) => pushedPcm.add(bytes);

  @override
  void endPcm(VoiceSource source) {}

  /// Source ids released via [disposeSource], in order.
  final List<int> disposedSources = [];

  @override
  void disposeSource(VoiceSource source) =>
      disposedSources.add(source.raw as int);

  @override
  VoiceHandle play(
    VoiceSource source, {
    double volume = 1,
    bool looping = false,
  }) {
    final id = _handleCounter++;
    volumes[id] = volume;
    plays.add(
      PlayCall(
        sourceId: source.raw as int,
        handleId: id,
        volume: volume,
        looping: looping,
      ),
    );
    return VoiceHandle(id);
  }

  @override
  void setVolume(VoiceHandle handle, double volume) =>
      volumes[handle.raw as int] = volume;

  @override
  void setPause(VoiceHandle handle, bool pause) =>
      paused[handle.raw as int] = pause;

  @override
  void oscillateVolume(
    VoiceHandle handle,
    double from,
    double to,
    Duration period,
  ) => oscillations.add(
    OscillateCall(
      handleId: handle.raw as int,
      from: from,
      to: to,
      period: period,
    ),
  );

  @override
  void fadeVolume(VoiceHandle handle, double to, Duration time) =>
      fades.add(FadeCall(handleId: handle.raw as int, to: to, time: time));

  @override
  void scheduleStop(VoiceHandle handle, Duration time) => scheduledStops.add(
    ScheduleStopCall(handleId: handle.raw as int, time: time),
  );

  @override
  void keepLoopAlive(VoiceHandle handle) => keptAlive.add(handle.raw as int);

  @override
  void applyBus(BusSettings settings) => busSettings.add(settings);

  @override
  void activateBus() => busActivations++;
}

/// A recorded [AudioBackend.play] call.
class PlayCall {
  /// Bundles the play arguments.
  const PlayCall({
    required this.sourceId,
    required this.handleId,
    required this.volume,
    required this.looping,
  });

  /// Source token id.
  final int sourceId;

  /// Resulting handle token id.
  final int handleId;

  /// Start volume.
  final double volume;

  /// Whether the voice loops.
  final bool looping;
}

/// A recorded [AudioBackend.oscillateVolume] call.
class OscillateCall {
  /// Bundles the oscillation arguments.
  const OscillateCall({
    required this.handleId,
    required this.from,
    required this.to,
    required this.period,
  });

  /// Target handle id.
  final int handleId;

  /// Lower bound.
  final double from;

  /// Upper bound.
  final double to;

  /// Sweep period.
  final Duration period;
}

/// A recorded [AudioBackend.fadeVolume] call.
class FadeCall {
  /// Bundles the fade arguments.
  const FadeCall({
    required this.handleId,
    required this.to,
    required this.time,
  });

  /// Target handle id.
  final int handleId;

  /// Target volume.
  final double to;

  /// Fade duration.
  final Duration time;
}

/// A recorded [AudioBackend.scheduleStop] call.
class ScheduleStopCall {
  /// Bundles the stop arguments.
  const ScheduleStopCall({required this.handleId, required this.time});

  /// Target handle id.
  final int handleId;

  /// Delay before stopping.
  final Duration time;
}
