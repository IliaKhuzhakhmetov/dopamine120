import 'package:dopamine120/features/focus/data/repositories/silent_ambience_repository.dart';
import 'package:dopamine120/features/focus/domain/entities/focus_dimension.dart';
import 'package:dopamine120/features/focus/domain/entities/sound_layer.dart';
import 'package:dopamine120/features/focus/domain/repositories/ambience_repository.dart';
import 'package:dopamine120/features/focus/domain/usecases/select_dimension.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_layer_level.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_temporal_distortion.dart';
import 'package:dopamine120/features/focus/domain/usecases/start_ambience.dart';
import 'package:dopamine120/features/focus/domain/usecases/stop_ambience.dart';
import 'package:dopamine120/features/focus/presentation/controller/focus_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FocusController', () {
    late SilentAmbienceRepository repository;

    FocusController buildWith(AmbienceRepository repository) => FocusController(
      startAmbience: StartAmbience(repository),
      setLayerLevel: SetLayerLevel(repository),
      setTemporalDistortion: SetTemporalDistortion(repository),
      selectDimension: SelectDimension(repository),
      stopAmbience: StopAmbience(repository),
      sessionLength: const Duration(seconds: 3),
    );

    FocusController build() => buildWith(repository);

    setUp(() => repository = SilentAmbienceRepository());

    test('mixing a layer warps the orb and forwards the level', () async {
      final controller = build();

      await controller.setLayer(SoundLayer.drone, 0.7);

      expect(controller.knobs.drone, 0.7);
      expect(controller.levelOf(SoundLayer.drone), 0.7);
      expect(repository.levels[SoundLayer.drone], 0.7);
    });

    test('clamps layer levels to 0..1', () async {
      final controller = build();

      await controller.setLayer(SoundLayer.rain, 1.6);

      expect(controller.knobs.rain, 1.0);
      expect(repository.levels[SoundLayer.rain], 1.0);
    });

    test('starts the engine lazily, exactly once', () async {
      final controller = build();
      expect(repository.running, isFalse);

      await controller.setLayer(SoundLayer.bell, 0.5);
      expect(repository.running, isTrue);

      await controller.setLayer(SoundLayer.bell, 0.2);
      // The applied dimension reflects the single start, not repeated starts.
      expect(repository.dimension, FocusDimension.room);
    });

    test('primeAudio starts the engine before async knob updates', () async {
      final controller = build();

      controller.primeAudio();
      await Future<void>.delayed(Duration.zero);

      expect(repository.running, isTrue);
      expect(repository.dimension, FocusDimension.room);
    });

    test('retries audio start after a failed prime gesture', () async {
      final repository = _FlakyAmbienceRepository();
      final controller = buildWith(repository);

      controller.primeAudio();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.startAttempts, 1);
      expect(repository.running, isFalse);

      await controller.setLayer(SoundLayer.drone, 0.35);

      expect(repository.startAttempts, 2);
      expect(repository.running, isTrue);
      expect(repository.dimension, FocusDimension.room);
      expect(repository.levels[SoundLayer.drone], 0.35);
    });

    test('selecting a dimension updates state and the bus', () async {
      final controller = build();

      await controller.selectDimension(FocusDimension.cosmos);

      expect(controller.dimension, FocusDimension.cosmos);
      expect(repository.dimension, FocusDimension.cosmos);
    });

    test('pressing the orb temporarily distorts the audio bus', () async {
      final controller = build();

      controller.setTemporalDistortion(1);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.running, isTrue);
      expect(repository.temporalDistortion, 1);

      controller.setTemporalDistortion(0);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.temporalDistortion, 0);
    });

    test('ignores re-selecting the active dimension', () async {
      final controller = build();

      await controller.selectDimension(FocusDimension.room);

      // room is already active, so the engine was never started.
      expect(repository.running, isFalse);
    });

    test('mute silences the running mix and unmute resumes it', () async {
      final controller = build();
      await controller.setLayer(SoundLayer.drone, 0.6);
      expect(repository.running, isTrue);

      await controller.toggleMute();
      expect(controller.isMuted, isTrue);
      expect(repository.running, isFalse);

      await controller.toggleMute();
      expect(controller.isMuted, isFalse);
      expect(repository.running, isTrue);
      // The mix returns unchanged.
      expect(repository.levels[SoundLayer.drone], 0.6);
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
      await controller.setLayer(SoundLayer.drone, 0.4);
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
  FocusDimension? dimension;
  final Map<SoundLayer, double> levels = {};
  double temporalDistortion = 0;

  @override
  Future<void> start() async {
    startAttempts++;
    if (startAttempts == 1) {
      throw StateError('audio start failed once');
    }
    running = true;
  }

  @override
  Future<void> setLayerLevel(SoundLayer layer, double level) async {
    levels[layer] = level;
  }

  @override
  Future<void> selectDimension(FocusDimension dimension) async {
    this.dimension = dimension;
  }

  @override
  Future<void> setTemporalDistortion(double amount) async {
    temporalDistortion = amount;
  }

  @override
  Future<void> stop() async {
    running = false;
  }

  @override
  Future<void> dispose() async {
    running = false;
  }
}
