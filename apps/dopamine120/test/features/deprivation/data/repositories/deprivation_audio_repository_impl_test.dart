import 'dart:math';

import 'package:dopamine120/features/deprivation/data/audio/deprivation_procedural_voices.dart';
import 'package:dopamine120/features/deprivation/data/repositories/deprivation_audio_repository_impl.dart';
import 'package:dopamine120/features/deprivation/domain/entities/deprivation_mask.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

void main() {
  test('starting silence zeros and stops warm masks', () async {
    final backend = _RecordingAudioBackend();
    final repository = _buildRepository(backend);

    await repository.startMask(DeprivationMask.pink);
    await repository.startMask(DeprivationMask.silence);

    expect(backend.volumes, _maskVolumes());
    expect(backend.paused, {0: true, 1: true, 2: true, 3: true});
  });

  test(
    'starting each mask enables only that sound at fixed low level',
    () async {
      for (final entry in {
        DeprivationMask.white: 0,
        DeprivationMask.pink: 1,
        DeprivationMask.brown: 2,
        DeprivationMask.rain: 3,
      }.entries) {
        final backend = _RecordingAudioBackend();
        final repository = _buildRepository(backend);

        await repository.startMask(entry.key);

        for (var handle = 0; handle < 4; handle++) {
          expect(
            backend.volumes[handle],
            handle == entry.value
                ? DeprivationAudioRepositoryImpl.maskVolume
                : 0,
          );
        }
      }
    },
  );

  test('volume changes affect the active mask only', () async {
    final backend = _RecordingAudioBackend();
    final repository = _buildRepository(backend);

    await repository.startMask(DeprivationMask.brown);
    await repository.setMaskVolume(0.3);

    expect(backend.volumes, _maskVolumes(brown: 0.3));
  });

  test('volume set while stopped is used on next start', () async {
    final backend = _RecordingAudioBackend();
    final repository = _buildRepository(backend);

    await repository.setMaskVolume(0.25);
    await repository.startMask(DeprivationMask.rain);

    expect(backend.volumes, _maskVolumes(rain: 0.25));
  });

  test('start and stop toggle the engine background audio session', () async {
    final backend = _RecordingAudioBackend();
    final session = _RecordingBackgroundAudioSession();
    final repository = _buildRepository(
      backend,
      backgroundAudioSession: session,
    );

    await repository.startMask(DeprivationMask.brown);
    await repository.stopMask();

    expect(session.starts, 1);
    expect(session.stops, 1);
  });
}

Map<int, double> _maskVolumes({
  double white = 0,
  double pink = 0,
  double brown = 0,
  double rain = 0,
}) => {0: white, 1: pink, 2: brown, 3: rain};

DeprivationAudioRepositoryImpl _buildRepository(
  _RecordingAudioBackend backend, {
  BackgroundAudioSession backgroundAudioSession =
      const NoopBackgroundAudioSession(),
}) {
  return DeprivationAudioRepositoryImpl(
    ProceduralSoundEngine(
      backend: backend,
      backgroundAudioSession: backgroundAudioSession,
      random: Random(1),
      isWeb: false,
      voices: buildDeprivationProceduralVoices(),
    ),
  );
}

class _RecordingBackgroundAudioSession implements BackgroundAudioSession {
  final _requests = ValueNotifier<BackgroundAudioSessionRequest?>(null);
  int starts = 0;
  int stops = 0;

  @override
  ValueListenable<BackgroundAudioSessionRequest?> get requests => _requests;

  @override
  Future<void> start() async => starts++;

  @override
  Future<void> stop() async => stops++;
}

class _RecordingAudioBackend implements AudioBackend {
  bool _initialized = false;
  int _nextSource = 0;
  int _nextHandle = 0;

  final Map<int, double> volumes = {};
  final Map<int, bool> paused = {};

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async => _initialized = true;

  @override
  void dispose() => _initialized = false;

  @override
  Future<VoiceSource> loadWaveform(WaveFormType waveform) async =>
      VoiceSource(_nextSource++);

  @override
  void setWaveformFreq(VoiceSource source, double freq) {}

  @override
  Future<VoiceSource> loadNoise(String name, Uint8List bytes) async =>
      VoiceSource(_nextSource++);

  @override
  Future<AudioSourceRef> loadAsset(
    String assetKey, {
    LoadModePolicy policy = LoadModePolicy.memory,
  }) async => AudioSourceRef(_nextSource++);

  @override
  VoiceSource openPcmStream({
    required int maxBufferSizeBytes,
    required double bufferingTimeNeeds,
    required int sampleRate,
  }) => VoiceSource(_nextSource++);

  @override
  void pushPcm(VoiceSource source, Uint8List bytes) {}

  @override
  void endPcm(VoiceSource source) {}

  @override
  void disposeSource(VoiceSource source) {}

  @override
  VoiceHandle play(
    VoiceSource source, {
    double volume = 1,
    double pan = 0,
    bool looping = false,
  }) {
    final handle = _nextHandle++;
    volumes[handle] = volume;
    return VoiceHandle(handle);
  }

  @override
  Future<BusRef> createBus(String id) async => const BusRef(0);

  @override
  VoiceRef playRequest(PlayRequest request) => VoiceRef(_nextHandle++);

  @override
  Future<void> stop(VoiceRef voice, {Duration fadeOut = Duration.zero}) async {}

  @override
  void setVolume(VoiceHandle handle, double volume) {
    volumes[handle.raw as int] = volume;
  }

  @override
  void setBusVolume(BusRef bus, double volume) {}

  @override
  void setParam(AudioParamAddress address, double value) {}

  @override
  void setPause(VoiceHandle handle, bool pause) {
    paused[handle.raw as int] = pause;
  }

  @override
  void oscillateVolume(
    VoiceHandle handle,
    double from,
    double to,
    Duration period,
  ) {}

  @override
  void fadeVolume(VoiceHandle handle, double to, Duration time) {}

  @override
  void scheduleStop(VoiceHandle handle, Duration time) {}

  @override
  void keepLoopAlive(VoiceHandle handle) {}

  @override
  void applyBus(BusSettings settings) {}

  @override
  void activateBus() {}
}
