import 'dart:math';
import 'dart:typed_data';

import 'package:dopamine120/features/focus/data/scenes/focus_scene.dart';
import 'package:dopamine120/features/focus/data/audio/focus_procedural_voices.dart';
import 'package:dopamine120/features/focus/data/repositories/ambience_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

void main() {
  test(
    'maps focus scene filter profile without retuning source sounds',
    () async {
      final backend = _RecordingAudioBackend();
      final engine = ProceduralSoundEngine(
        backend: backend,
        random: Random(1),
        isWeb: false,
        voices: buildFocusProceduralVoices(),
      );
      final repository = AmbienceRepositoryImpl(engine);

      await repository.setDimensionValue('cathedral', 1);

      expect(repository.scene.id, 'focus');
      expect(repository.scene, same(focusScene));
      final bus = backend.busSettings.single;
      expect(bus.frequency, 9000);
      expect(bus.reverbWet, 0.55);
      expect(
        focusScene.filters.every((filter) => filter.mappings.isEmpty),
        isTrue,
      );
      expect(backend.waveformFrequencies.values, isNot(contains(27.5)));

      await repository.dispose();
    },
  );
}

class _RecordingAudioBackend implements AudioBackend {
  bool _initialized = false;
  int _nextSource = 0;
  int _nextHandle = 0;

  final List<BusSettings> busSettings = [];
  final Map<int, double> waveformFrequencies = {};

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
  void setWaveformFreq(VoiceSource source, double freq) {
    waveformFrequencies[source.raw as int] = freq;
  }

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
  }) => VoiceHandle(_nextHandle++);

  @override
  Future<BusRef> createBus(String id) async => const BusRef(0);

  @override
  VoiceRef playRequest(PlayRequest request) => VoiceRef(_nextHandle++);

  @override
  Future<void> stop(VoiceRef voice, {Duration fadeOut = Duration.zero}) async {}

  @override
  void setVolume(VoiceHandle handle, double volume) {}

  @override
  void setBusVolume(BusRef bus, double volume) {}

  @override
  void setParam(AudioParamAddress address, double value) {}

  @override
  void setPause(VoiceHandle handle, bool pause) {}

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
  void applyBus(BusSettings settings) => busSettings.add(settings);

  @override
  void activateBus() {}
}
