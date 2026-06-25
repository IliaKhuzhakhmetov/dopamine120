import 'package:dopamine120/features/imagination/domain/entities/imagination_sound_cue.dart';
import 'package:dopamine120/features/imagination/domain/repositories/imagination_audio_repository.dart';
import 'package:dopamine120/features/imagination/domain/usecases/play_imagination_cue.dart';
import 'package:dopamine120/features/imagination/domain/usecases/set_imagination_drone.dart';
import 'package:dopamine120/features/imagination/domain/usecases/set_imagination_theme.dart';
import 'package:dopamine120/features/imagination/domain/usecases/start_imagination_audio.dart';
import 'package:dopamine120/features/imagination/domain/usecases/stop_imagination_audio.dart';
import 'package:dopamine120/features/imagination/presentation/controller/imagination_controller.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts timer, keeps screen after completion, and reveals next', () {
    fakeAsync((async) {
      final repository = _RecordingImaginationAudioRepository();
      final controller = _buildController(
        repository,
        duration: const Duration(seconds: 2),
      );

      expect(controller.remainingLabel, '00:02');
      expect(controller.canSkip, isTrue);
      expect(controller.canGoNext, isFalse);
      expect(controller.droneDb, ImaginationController.defaultDroneDb);

      controller.start();
      async.flushMicrotasks();

      expect(repository.startCount, 1);
      expect(repository.themes, ['room']);
      expect(repository.drones, [
        closeTo(
          ImaginationController.droneDbToValue(
            ImaginationController.defaultDroneDb,
          ),
          0.000001,
        ),
      ]);

      async.elapse(const Duration(seconds: 1));
      expect(controller.remainingLabel, '00:01');

      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();

      expect(controller.remainingLabel, '00:00');
      expect(controller.isCompleted, isTrue);
      expect(controller.canGoNext, isTrue);
      expect(repository.cues, [ImaginationSoundCue.completion]);
      expect(repository.stopCount, 0);

      controller.dispose();
      async.flushMicrotasks();
      expect(repository.stopCount, 1);
    });
  });

  test('block add and remove emit soft cues', () {
    fakeAsync((async) {
      final repository = _RecordingImaginationAudioRepository();
      final controller = _buildController(repository);

      controller.setType(BlockType.glass);
      controller.blockController.spawnAt(
        0,
        0,
        source: BlockFieldEventSource.userTap,
      );
      controller.setMode(BlockFieldMode.delete);
      controller.blockController.deleteTopBlockAt(
        0,
        0,
        source: BlockFieldEventSource.userTap,
      );
      async.flushMicrotasks();

      expect(controller.blockController.selectedType, BlockType.glass);
      expect(controller.blockController.mode, BlockFieldMode.delete);
      expect(repository.cues, [
        ImaginationSoundCue.blockAdd,
        ImaginationSoundCue.blockRemove,
      ]);

      controller.dispose();
      async.flushMicrotasks();
    });
  });
}

ImaginationController _buildController(
  _RecordingImaginationAudioRepository repository, {
  Duration duration = const Duration(minutes: 2),
}) {
  return ImaginationController(
    startAudio: StartImaginationAudio(repository),
    setDrone: SetImaginationDrone(repository),
    setTheme: SetImaginationTheme(repository),
    playCue: PlayImaginationCue(repository),
    stopAudio: StopImaginationAudio(repository),
    duration: duration,
  );
}

class _RecordingImaginationAudioRepository
    implements ImaginationAudioRepository {
  int startCount = 0;
  int stopCount = 0;
  final List<double> drones = [];
  final List<String> themes = [];
  final List<ImaginationSoundCue> cues = [];

  @override
  Future<void> start() async => startCount++;

  @override
  Future<void> setDrone(double value) async => drones.add(value);

  @override
  Future<void> setTheme(String themeId) async => themes.add(themeId);

  @override
  Future<void> playCue(ImaginationSoundCue cue) async => cues.add(cue);

  @override
  Future<void> stop() async => stopCount++;
}
