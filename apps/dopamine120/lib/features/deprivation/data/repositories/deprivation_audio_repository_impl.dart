import 'package:sound_framework/sound_framework.dart';

import '../../domain/entities/deprivation_mask.dart';
import '../../domain/repositories/deprivation_audio_repository.dart';
import '../audio/deprivation_procedural_voices.dart';

class DeprivationAudioRepositoryImpl implements DeprivationAudioRepository {
  DeprivationAudioRepositoryImpl(this._engine);

  static const double maskVolume = defaultDeprivationMaskVolume;

  static const Map<DeprivationMask, String> _soundIds = {
    DeprivationMask.white: deprivationWhiteSoundId,
    DeprivationMask.pink: deprivationPinkSoundId,
    DeprivationMask.brown: deprivationBrownSoundId,
    DeprivationMask.rain: deprivationRainSoundId,
  };

  final ProceduralSoundEngine _engine;
  DeprivationMask _activeMask = DeprivationMask.silence;
  double _maskVolume = defaultDeprivationMaskVolume;

  @override
  Future<void> startMask(DeprivationMask mask) async {
    _activeMask = mask;
    if (mask == DeprivationMask.silence) {
      await stopMask();
      return;
    }

    await _engine.start();
    await _zeroMasks();
    await _engine.setSound(_soundIds[mask]!, _maskVolume);
  }

  @override
  Future<void> setMaskVolume(double volume) async {
    _maskVolume = volume.clamp(0, 1).toDouble();
    if (!_engine.isReady || _activeMask == DeprivationMask.silence) return;
    await _engine.setSound(_soundIds[_activeMask]!, _maskVolume);
  }

  @override
  Future<void> stopMask() async {
    _activeMask = DeprivationMask.silence;
    if (_engine.isReady) await _zeroMasks();
    await _engine.stop();
  }

  Future<void> _zeroMasks() async {
    for (final soundId in _soundIds.values) {
      await _engine.setSound(soundId, 0);
    }
  }
}
