import 'package:dopamine120/features/focus/data/scenes/focus_scene.dart';
import 'package:dopamine120/features/focus/data/repositories/silent_ambience_repository.dart';
import 'package:dopamine120/features/focus/domain/repositories/ambience_repository.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_scene_dimension.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_scene_knob.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_temporal_distortion.dart';
import 'package:dopamine120/features/focus/domain/usecases/start_ambience.dart';
import 'package:dopamine120/features/focus/domain/usecases/stop_ambience.dart';
import 'package:dopamine120/features/focus/domain/usecases/watch_scene_sound_events.dart';
import 'package:dopamine120/features/focus/presentation/controller/focus_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

void main() {
  group('FocusController', () {
    late SilentAmbienceRepository repository;

    FocusController buildWith(AmbienceRepository repository) => FocusController(
      scene: repository.scene,
      startAmbience: StartAmbience(repository),
      setSceneKnob: SetSceneKnob(repository),
      setSceneDimension: SetSceneDimension(repository),
      setTemporalDistortion: SetTemporalDistortion(repository),
      stopAmbience: StopAmbience(repository),
      watchSceneSoundEvents: WatchSceneSoundEvents(repository),
      sessionLength: const Duration(seconds: 3),
    );

    FocusController build() => buildWith(repository);

    setUp(() => repository = SilentAmbienceRepository());

    test('mixing a scene knob warps the orb and forwards the value', () async {
      final controller = build();

      await controller.setKnob('drone', 0.7);

      expect(controller.knobs.drone, 0.7);
      expect(controller.knobValue('drone'), 0.7);
      expect(repository.knobValues['drone'], 0.7);
    });

    test('clamps scene knob values to 0..1', () async {
      final controller = build();

      await controller.setKnob('bell', 1.6);

      expect(controller.knobs.bell, 1.0);
      expect(repository.knobValues['bell'], 1.0);
    });

    test('starts the engine lazily, exactly once', () async {
      final controller = build();
      expect(repository.running, isFalse);

      await controller.setKnob('bell', 0.8);
      expect(repository.running, isTrue);

      await controller.setKnob('bell', 0.2);
      expect(repository.knobValues['bell'], 0.2);
    });

    test('coalesces rapid scene knob changes before touching audio', () {
      fakeAsync((async) {
        final controller = build();

        controller.setKnob('pulse', 0.2);
        controller.setKnob('pulse', 0.7);

        async.elapse(const Duration(milliseconds: 47));
        async.flushMicrotasks();
        expect(repository.knobValues['pulse'], isNull);

        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();

        expect(controller.knobs.pulse, 0.7);
        expect(repository.knobValues['pulse'], 0.7);

        controller.dispose();
      });
    });

    test('primeAudio starts the engine before async knob updates', () async {
      final controller = build();

      controller.primeAudio();
      await Future<void>.delayed(Duration.zero);

      expect(repository.running, isTrue);
      expect(
        repository.knobValues['drone'],
        focusScene.knobs.first.initialValue,
      );
    });

    test('retries audio start after a failed prime gesture', () async {
      final repository = _FlakyAmbienceRepository();
      final controller = buildWith(repository);

      controller.primeAudio();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.startAttempts, 1);
      expect(repository.running, isFalse);

      await controller.setKnob('drone', 0.35);

      expect(repository.startAttempts, 2);
      expect(repository.running, isTrue);
      expect(repository.knobValues['drone'], 0.35);
    });

    test('selecting a scene dimension updates state and the bus', () async {
      final controller = build();

      await controller.selectDimension('cosmos');

      expect(controller.dimensionId, 'cosmos');
      expect(controller.dimensionValue('cosmos'), 1);
      expect(repository.dimensionValues['cosmos'], 1);
    });

    test('pressing the orb temporarily distorts the focus mix', () async {
      final controller = build();

      controller.setOrbDistortion(1);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.running, isTrue);
      expect(repository.temporalDistortion, 1);

      controller.setOrbDistortion(0);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.temporalDistortion, 0);
    });

    test('bell sound events pulse the orb controller', () async {
      final controller = build();

      await Future<void>.delayed(Duration.zero);
      repository.emitSoundEvent(
        const ProceduralSoundEvent(
          soundId: 'bell',
          intensity: 0.7,
          frequencyHz: 440,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.orbController.bellStrikeSequence, 1);
      expect(controller.orbController.bellStrikeIntensity, 0.7);
    });

    test('ignores re-selecting the active scene dimension', () async {
      final controller = build();

      await controller.selectDimension('room');

      // room is already active, so the engine was never started.
      expect(repository.running, isFalse);
    });

    test('mute silences the running mix and unmute resumes it', () async {
      final controller = build();
      await controller.setKnob('drone', 0.6);
      expect(repository.running, isTrue);

      await controller.toggleMute();
      expect(controller.isMuted, isTrue);
      expect(repository.running, isFalse);

      await controller.toggleMute();
      expect(controller.isMuted, isFalse);
      expect(repository.running, isTrue);
      // The mix returns unchanged.
      expect(repository.knobValues['drone'], 0.6);
    });

    test('timer counts down and resets on demand', () {
      fakeAsync((async) {
        final controller = build()..startTimer();

        async.elapse(const Duration(seconds: 2));
        expect(controller.remainingLabel, '00:01');

        controller.startTimer();
        expect(controller.remainingLabel, '00:03');

        controller.dispose();
      });
    });

    test('stops the engine when disposed', () async {
      final controller = build();
      await controller.setKnob('drone', 0.6);
      expect(repository.running, isTrue);

      controller.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(repository.running, isFalse);
    });
  });
}

class _FlakyAmbienceRepository implements AmbienceRepository {
  int startAttempts = 0;
  bool running = false;
  final Map<String, double> knobValues = {};
  final Map<String, double> dimensionValues = {};

  @override
  SceneConfig get scene => focusScene;

  @override
  Stream<ProceduralSoundEvent> get soundEvents => const Stream.empty();

  @override
  Future<void> start() async {
    startAttempts++;
    if (startAttempts == 1) {
      throw StateError('audio start failed once');
    }
    running = true;
  }

  @override
  Future<void> setKnobValue(String knobId, double value) async {
    knobValues[knobId] = value;
  }

  @override
  Future<void> setDimensionValue(String dimensionId, double value) async {
    dimensionValues[dimensionId] = value;
  }

  @override
  Future<void> setTemporalDistortion(double amount) async {}

  @override
  Future<void> stop() async {
    running = false;
  }

  @override
  Future<void> dispose() async {
    running = false;
  }
}
