import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

import 'fake_audio_backend.dart';

bool _isClose(double a, double b) => (a - b).abs() < 1e-9;

const _room = AcousticProfile(
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

const _jungle = AcousticProfile(
  filterShape: AcousticFilterShape.bandpass,
  cutoffHz: 2100,
  resonance: 0.8,
  reverbWet: 0.18,
  roomSize: 0.5,
  delaySeconds: 0.22,
  delayDecay: 0.3,
  delayWet: 0.12,
  masterGain: 0.55,
);

void main() {
  late FakeAudioBackend backend;
  late ProceduralSoundEngine engine;

  setUp(() {
    backend = FakeAudioBackend();
    engine = ProceduralSoundEngine(
      backend: backend,
      random: Random(1),
      isWeb: false,
    );
  });

  group('lifecycle', () {
    test('start boots the backend once and activates the bus', () async {
      await engine.start();

      expect(engine.isReady, isTrue);
      expect(backend.initCount, 1);
      expect(backend.busActivations, 1);
    });

    test('builds the engine only once across stop/start', () async {
      await engine.start();
      await engine.stop();
      await engine.start();

      expect(backend.initCount, 1);
    });

    test('stop pauses every continuous voice', () async {
      await engine.start();
      await engine.stop();

      expect(backend.paused.values, isNotEmpty);
      expect(backend.paused.values.every((p) => p), isTrue);
    });

    test('dispose tears down the backend and clears readiness', () async {
      await engine.start();
      await engine.dispose();

      expect(backend.disposeCount, 1);
      expect(engine.isReady, isFalse);
    });
  });

  group('setLayer', () {
    test('routes a continuous layer to its own voice volume', () async {
      await engine.start();
      await engine.setLayer(SoundLayer.cicada, 1);

      expect(
        backend.volumes.values.where((v) => _isClose(v, 0.26)),
        hasLength(1),
      );
    });

    test('clamps the level into 0..1', () async {
      await engine.start();
      await engine.setLayer(SoundLayer.rain, 5);

      expect(
        backend.volumes.values.where((v) => _isClose(v, 0.20)),
        hasLength(1),
      );
    });

    test('bell level never touches a continuous voice', () async {
      await engine.start();
      final before = Map<int, double>.of(backend.volumes);

      await engine.setLayer(SoundLayer.bell, 1);

      expect(backend.volumes, before);
      expect(backend.oscillations, isEmpty);
    });

    test('builds lazily if a layer is set before start', () async {
      await engine.setLayer(SoundLayer.rain, 1);

      expect(engine.isReady, isTrue);
      expect(backend.initCount, 1);
    });
  });

  group('bus', () {
    test('applyProfile pushes the mapped settings', () async {
      await engine.start();
      backend.busSettings.clear();

      await engine.applyProfile(_jungle);

      expect(backend.busSettings.single.filterType, 2, reason: 'bandpass');
    });

    test('temporal distortion bends the active profile', () async {
      await engine.start();
      await engine.applyProfile(_room);
      backend.busSettings.clear();

      await engine.setTemporalDistortion(1);

      final bent = backend.busSettings.single;
      expect(bent.frequency, lessThan(16000), reason: 'filter closes');
      expect(bent.globalVolume, lessThan(0.55), reason: 'gain dips');
    });
  });
}
