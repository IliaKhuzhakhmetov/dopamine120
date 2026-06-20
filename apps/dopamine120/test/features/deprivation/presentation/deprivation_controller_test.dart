import 'package:dopamine120/features/deprivation/domain/entities/deprivation_mask.dart';
import 'package:dopamine120/features/deprivation/domain/repositories/deprivation_audio_repository.dart';
import 'package:dopamine120/features/deprivation/domain/usecases/set_deprivation_mask_volume.dart';
import 'package:dopamine120/features/deprivation/domain/usecases/start_deprivation_mask.dart';
import 'package:dopamine120/features/deprivation/domain/usecases/stop_deprivation_mask.dart';
import 'package:dopamine120/features/deprivation/presentation/controller/deprivation_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults, counts down, pauses, resumes, and ends', () {
    fakeAsync((async) {
      final repository = _RecordingDeprivationAudioRepository();
      var completed = 0;
      final controller = DeprivationController(
        startMask: StartDeprivationMask(repository),
        setMaskVolume: SetDeprivationMaskVolume(repository),
        stopMask: StopDeprivationMask(repository),
        initialDuration: const Duration(seconds: 4),
        onCompleted: () => completed++,
      );

      expect(controller.duration, const Duration(seconds: 4));
      expect(controller.mask, DeprivationMask.silence);
      expect(controller.maskVolume, defaultDeprivationMaskVolumeDb);
      expect(controller.canEdit, isTrue);

      controller.setMask(DeprivationMask.brown);
      controller.start();
      async.flushMicrotasks();

      expect(repository.startedMasks, [DeprivationMask.brown]);
      expect(controller.canEdit, isFalse);

      async.elapse(const Duration(seconds: 2));
      expect(controller.remainingLabel, '00:02');

      controller.setMask(DeprivationMask.rain);
      async.flushMicrotasks();
      expect(repository.startedMasks, [
        DeprivationMask.brown,
        DeprivationMask.rain,
      ]);

      controller.setMaskVolume(-10);
      async.flushMicrotasks();
      expect(repository.volumes, [
        closeTo(DeprivationController.maskVolumeDbToGain(-21), 0.000001),
        closeTo(DeprivationController.maskVolumeDbToGain(-10), 0.000001),
      ]);

      controller.pause();
      async.flushMicrotasks();
      expect(repository.stopCount, 1);
      controller.setMaskVolume(-20);
      controller.setMask(DeprivationMask.pink);
      async.flushMicrotasks();
      expect(repository.startedMasks, [
        DeprivationMask.brown,
        DeprivationMask.rain,
      ]);
      expect(repository.volumes, [
        closeTo(DeprivationController.maskVolumeDbToGain(-21), 0.000001),
        closeTo(DeprivationController.maskVolumeDbToGain(-10), 0.000001),
        closeTo(DeprivationController.maskVolumeDbToGain(-20), 0.000001),
      ]);
      async.elapse(const Duration(seconds: 3));
      expect(controller.remainingLabel, '00:02');

      controller.resume();
      async.flushMicrotasks();
      expect(repository.startedMasks, [
        DeprivationMask.brown,
        DeprivationMask.rain,
        DeprivationMask.pink,
      ]);
      async.elapse(const Duration(seconds: 1));
      expect(controller.remainingLabel, '00:01');

      controller.end();
      async.flushMicrotasks();

      expect(repository.stopCount, 2);
      expect(completed, 1);
      expect(controller.isCompleted, isTrue);

      controller.dispose();
    });
  });
}

class _RecordingDeprivationAudioRepository
    implements DeprivationAudioRepository {
  final List<DeprivationMask> startedMasks = [];
  final List<double> volumes = [];
  int stopCount = 0;

  @override
  Future<void> startMask(DeprivationMask mask) async => startedMasks.add(mask);

  @override
  Future<void> setMaskVolume(double volume) async => volumes.add(volume);

  @override
  Future<void> stopMask() async => stopCount++;
}
