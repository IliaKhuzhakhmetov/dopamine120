import 'dart:async';

import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../data/scenes/imagination_scene.dart';
import '../../domain/entities/imagination_sound_cue.dart';
import '../../domain/usecases/play_imagination_cue.dart';
import '../../domain/usecases/set_imagination_drone.dart';
import '../../domain/usecases/set_imagination_theme.dart';
import '../../domain/usecases/start_imagination_audio.dart';
import '../../domain/usecases/stop_imagination_audio.dart';

class ImaginationController extends ChangeNotifier {
  ImaginationController({
    required StartImaginationAudio startAudio,
    required SetImaginationDrone setDrone,
    required SetImaginationTheme setTheme,
    required PlayImaginationCue playCue,
    required StopImaginationAudio stopAudio,
    BackgroundAudioSession backgroundAudioSession =
        const NoopBackgroundAudioSession(),
    Duration duration = const Duration(minutes: 2),
  }) : _startAudio = startAudio,
       _setDrone = setDrone,
       _setTheme = setTheme,
       _playCue = playCue,
       _stopAudio = stopAudio,
       _backgroundAudioSession = backgroundAudioSession,
       _duration = duration,
       _remaining = duration,
       blockController = BlockFieldController(
         selectedType: BlockType.core,
         mode: BlockFieldMode.spawn,
       ) {
    _blockEvents = blockController.events.listen(_handleBlockEvent);
    _backgroundAudioSession.requests.addListener(_handleBackgroundAudioRequest);
  }

  static const minDroneDb = minImaginationDroneDb;
  static const maxDroneDb = maxImaginationDroneDb;
  static const defaultDroneDb = defaultImaginationDroneDb;
  static const themeIds = [
    'room',
    'cathedral',
    'underwater',
    'cosmos',
    'jungle',
    'cave',
    'deprivation',
  ];

  final StartImaginationAudio _startAudio;
  final SetImaginationDrone _setDrone;
  final SetImaginationTheme _setTheme;
  final PlayImaginationCue _playCue;
  final StopImaginationAudio _stopAudio;
  final BackgroundAudioSession _backgroundAudioSession;
  final Duration _duration;
  final BlockFieldController blockController;

  late final StreamSubscription<BlockFieldBlockEvent> _blockEvents;
  Timer? _timer;
  bool _started = false;
  bool _completed = false;
  bool _muted = false;
  bool _droneRunning = false;
  Duration _remaining;
  double _droneDb = defaultDroneDb;
  String _selectedThemeId = defaultImaginationThemeId;

  bool get isStarted => _started;
  bool get isCompleted => _completed;
  bool get isMuted => _muted;
  bool get canSkip => true;
  bool get canGoNext => _completed;
  Duration get remaining => _remaining;
  String get remainingLabel => formatDuration(_remaining);
  double get droneDb => _droneDb;
  String get selectedThemeId => _selectedThemeId;

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static double droneDbToValue(double db) {
    final clamped = db.clamp(minDroneDb, maxDroneDb).toDouble();
    return (clamped - minDroneDb) / (maxDroneDb - minDroneDb);
  }

  void setMode(BlockFieldMode mode) {
    blockController.mode = mode;
    notifyListeners();
  }

  void setType(BlockType type) {
    blockController.selectedType = type;
    notifyListeners();
  }

  void setTheme(String themeId) {
    if (_selectedThemeId == themeId) return;
    _selectedThemeId = themeId;
    notifyListeners();
    if (!_muted) unawaited(_setTheme(themeId));
  }

  void setDroneDb(double db) {
    final next = db.clamp(minDroneDb, maxDroneDb).toDouble();
    if (next == _droneDb) return;
    _droneDb = next;
    notifyListeners();
    if (!_muted && _droneRunning) {
      unawaited(_setDrone(droneDbToValue(next)));
    }
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _completed = false;
    _droneRunning = true;
    _remaining = _duration;
    notifyListeners();
    if (!_muted) {
      await _startAudio(const NoParams());
      await _setTheme(_selectedThemeId);
      await _setDrone(droneDbToValue(_droneDb));
    }
    _startTimer();
  }

  Future<void> toggleMute() async {
    if (_muted) {
      _muted = false;
      notifyListeners();
      if (_droneRunning) {
        await _startAudio(const NoParams());
        await _setTheme(_selectedThemeId);
        await _setDrone(droneDbToValue(_droneDb));
      }
    } else {
      _muted = true;
      notifyListeners();
      await _stopAudio(const NoParams());
    }
  }

  @override
  void dispose() {
    _backgroundAudioSession.requests.removeListener(
      _handleBackgroundAudioRequest,
    );
    _timer?.cancel();
    unawaited(_blockEvents.cancel());
    blockController.dispose();
    unawaited(_stopAudio(const NoParams()));
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _remaining = Duration.zero;
        _completed = true;
        _timer?.cancel();
        _timer = null;
        notifyListeners();
        if (!_muted) unawaited(_playCue(ImaginationSoundCue.completion));
        return;
      }
      _remaining -= const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _handleBlockEvent(BlockFieldBlockEvent event) {
    if (_muted) return;
    final cue = switch (event.kind) {
      BlockFieldBlockEventKind.spawned => ImaginationSoundCue.blockAdd,
      BlockFieldBlockEventKind.deleted => ImaginationSoundCue.blockRemove,
      BlockFieldBlockEventKind.tapped => null,
    };
    if (cue != null) unawaited(_playCue(cue));
  }

  void _handleBackgroundAudioRequest() {
    switch (_backgroundAudioSession.requests.value) {
      case BackgroundAudioSessionRequest.start:
        if (!_muted && _droneRunning) unawaited(_startAudio(const NoParams()));
      case BackgroundAudioSessionRequest.stop:
        if (!_muted) unawaited(_stopAudio(const NoParams()));
      case null:
        break;
    }
  }
}
