import '../entities/deprivation_mask.dart';

const defaultDeprivationMaskVolumeDb = -21.0;

// -21 dB converted to linear gain for audio engines that do not accept dB.
const defaultDeprivationMaskVolume = 0.08912509381337455;

abstract class DeprivationAudioRepository {
  Future<void> startMask(DeprivationMask mask);

  Future<void> setMaskVolume(double volume);

  Future<void> stopMask();
}
