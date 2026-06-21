import 'dart:async';
import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../domain/entities/deprivation_mask.dart';
import '../../domain/repositories/deprivation_audio_repository.dart';
import '../../domain/usecases/set_deprivation_mask_volume.dart';
import '../../domain/usecases/start_deprivation_mask.dart';
import '../../domain/usecases/stop_deprivation_mask.dart';

class DeprivationController extends ChangeNotifier {
  DeprivationController({
    required StartDeprivationMask startMask,
    required SetDeprivationMaskVolume setMaskVolume,
    required StopDeprivationMask stopMask,
    BackgroundAudioSession backgroundAudioSession =
        const NoopBackgroundAudioSession(),
    VoidCallback? onCompleted,
    Duration initialDuration = const Duration(minutes: 30),
  }) : _startMask = startMask,
       _setMaskVolume = setMaskVolume,
       _stopMask = stopMask,
       _backgroundAudioSession = backgroundAudioSession,
       _onCompleted = onCompleted,
       _duration = initialDuration,
       _remaining = initialDuration {
    _backgroundAudioSession.requests.addListener(_handleBackgroundAudioRequest);
  }

  final StartDeprivationMask _startMask;
  final SetDeprivationMaskVolume _setMaskVolume;
  final StopDeprivationMask _stopMask;
  final BackgroundAudioSession _backgroundAudioSession;
  final VoidCallback? _onCompleted;

  Duration _duration;
  Duration _remaining;
  DeprivationMask _mask = DeprivationMask.silence;
  double _maskVolumeDb = defaultDeprivationMaskVolumeDb;
  Timer? _timer;
  bool _started = false;
  bool _paused = false;
  bool _completed = false;
  bool _disposed = false;

  Duration get duration => _duration;
  Duration get remaining => _remaining;
  DeprivationMask get mask => _mask;
  double get maskVolume => _maskVolumeDb;
  bool get isStarted => _started;
  bool get isPaused => _paused;
  bool get isCompleted => _completed;
  bool get canEdit => !_started;
  String get remainingLabel => formatDuration(_remaining);

  static const durationOptions = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
  ];
  static const minMaskVolumeDb = -120.0;
  static const maxMaskVolumeDb = 0.0;

  static double maskVolumeDbToGain(double volumeDb) {
    final clamped = volumeDb.clamp(minMaskVolumeDb, maxMaskVolumeDb).toDouble();
    return math.pow(10, clamped / 20).toDouble();
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setDuration(Duration duration) {
    if (!canEdit || duration == _duration) return;
    _duration = duration;
    _remaining = duration;
    notifyListeners();
  }

  void setMask(DeprivationMask mask) {
    if (mask == _mask) return;
    _mask = mask;
    notifyListeners();
    if (_started && !_paused && !_completed) {
      unawaited(_startMask(mask));
    }
  }

  void setMaskVolume(double volume) {
    final next = volume.clamp(minMaskVolumeDb, maxMaskVolumeDb).toDouble();
    if (next == _maskVolumeDb) return;
    _maskVolumeDb = next;
    notifyListeners();
    if (_started && !_completed) {
      unawaited(_setMaskVolume(maskVolumeDbToGain(next)));
    }
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _paused = false;
    _completed = false;
    notifyListeners();
    await _startMask(_mask);
    await _setMaskVolume(maskVolumeDbToGain(_maskVolumeDb));
    _startTimer();
  }

  void pause() {
    if (!_started || _paused || _completed) return;
    _timer?.cancel();
    _timer = null;
    _paused = true;
    notifyListeners();
    unawaited(_stopMask(const NoParams()));
  }

  void resume() {
    if (!_started || !_paused || _completed) return;
    _paused = false;
    notifyListeners();
    unawaited(_startMask(_mask));
    _startTimer();
  }

  Future<void> end() => _complete();

  @override
  void dispose() {
    _disposed = true;
    _backgroundAudioSession.requests.removeListener(
      _handleBackgroundAudioRequest,
    );
    _timer?.cancel();
    unawaited(_stopMask(const NoParams()));
    super.dispose();
  }

  void _handleBackgroundAudioRequest() {
    switch (_backgroundAudioSession.requests.value) {
      case BackgroundAudioSessionRequest.start:
        if (_started && !_paused && !_completed) unawaited(_startMask(_mask));
      case BackgroundAudioSessionRequest.stop:
        if (_started && !_paused && !_completed) {
          unawaited(_stopMask(const NoParams()));
        }
      case null:
        break;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _remaining = Duration.zero;
        notifyListeners();
        unawaited(_complete());
        return;
      }
      _remaining -= const Duration(seconds: 1);
      notifyListeners();
    });
  }

  Future<void> _complete() async {
    if (_completed) return;
    _timer?.cancel();
    _timer = null;
    _started = false;
    _paused = false;
    _completed = true;
    notifyListeners();
    await _stopMask(const NoParams());
    if (!_disposed) _onCompleted?.call();
  }
}
