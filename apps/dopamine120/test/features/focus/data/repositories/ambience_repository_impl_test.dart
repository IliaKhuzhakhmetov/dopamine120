import 'dart:math';
import 'dart:typed_data';

import 'package:dopamine120/features/focus/data/repositories/ambience_repository_impl.dart';
import 'package:dopamine120/features/focus/domain/entities/focus_dimension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

void main() {
  test(
    'selectDimension maps app dimension profile and timbre to the engine',
    () async {
      final backend = _RecordingAudioBackend();
      final engine = ProceduralSoundEngine(
        backend: backend,
        random: Random(1),
        isWeb: false,
      );
      final repository = AmbienceRepositoryImpl(engine);

      await repository.selectDimension(FocusDimension.cathedral);

      final bus = backend.busSettings.single;
      expect(bus.frequency, 9000);
      expect(bus.reverbWet, 0.55);
      expect(backend.waveformFrequencies.values, contains(27.5));

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
    bool looping = false,
  }) => VoiceHandle(_nextHandle++);

  @override
  void setVolume(VoiceHandle handle, double volume) {}

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
