import 'dart:math';

import 'package:flutter/foundation.dart';
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
      voices: [_TestVoice('rain', 0.20), _TestVoice('cicada', 0.26)],
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

    test('start and stop toggle the background audio session', () async {
      final session = _RecordingBackgroundAudioSession();
      final engine = ProceduralSoundEngine(
        backend: backend,
        backgroundAudioSession: session,
        random: Random(1),
        isWeb: false,
        voices: [_TestVoice('rain', 0.20)],
      );

      await engine.start();
      await engine.stop();

      expect(session.starts, 1);
      expect(session.stops, 1);
    });

    test('dispose tears down the backend and clears readiness', () async {
      await engine.start();
      await engine.dispose();

      expect(backend.disposeCount, 1);
      expect(engine.isReady, isFalse);
    });
  });

  group('setSound', () {
    test('routes a continuous layer to its own voice volume', () async {
      await engine.start();
      await engine.setSound('cicada', 1);

      expect(
        backend.volumes.values.where((v) => _isClose(v, 0.26)),
        hasLength(1),
      );
    });

    test('clamps the level into 0..1', () async {
      await engine.start();
      await engine.setSound('rain', 5);

      expect(
        backend.volumes.values.where((v) => _isClose(v, 0.20)),
        hasLength(1),
      );
    });

    test('unknown sound id is ignored', () async {
      await engine.start();
      final before = Map<int, double>.of(backend.volumes);

      await engine.setSound('missing', 1);

      expect(backend.volumes, before);
      expect(backend.oscillations, isEmpty);
    });

    test('builds lazily if a layer is set before start', () async {
      await engine.setSound('rain', 1);

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

    test('profile bend adjusts the active profile', () async {
      await engine.start();
      await engine.applyProfile(_room);
      backend.busSettings.clear();

      await engine.setProfileBend(1);

      final bent = backend.busSettings.single;
      expect(bent.frequency, lessThan(16000), reason: 'filter closes');
      expect(bent.globalVolume, lessThan(0.55), reason: 'gain dips');
    });
  });

  group('events', () {
    test('publishes generic events from procedural voices', () async {
      final events = <ProceduralSoundEvent>[];
      final engine = ProceduralSoundEngine(
        backend: backend,
        random: Random(1),
        isWeb: false,
        voices: [_EventVoice()],
      );
      final subscription = engine.soundEvents.listen(events.add);

      await engine.start();
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.single.soundId, 'event');
      expect(events.single.intensity, 0.8);

      await subscription.cancel();
      await engine.dispose();
    });
  });
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

class _TestVoice extends ProceduralVoice {
  _TestVoice(this.id, this.scale);

  @override
  final String id;

  final double scale;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    final frequency = params['frequencyHz'] ?? 220;
    return [await context.player.oscillator(WaveFormType.sin, frequency)];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * scale);
    }
  }
}

class _EventVoice extends ProceduralVoice {
  late void Function(ProceduralSoundEvent event) _emit;

  @override
  String get id => 'event';

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    _emit = context.emit;
    return const [];
  }

  @override
  void apply(AudioBackend backend, double level) {}

  @override
  void start(AudioBackend backend) {
    _emit(const ProceduralSoundEvent(soundId: 'event', intensity: 0.8));
  }
}
