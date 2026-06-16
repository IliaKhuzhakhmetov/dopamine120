import 'dart:async';

import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../domain/usecases/set_scene_dimension.dart';
import '../../domain/usecases/set_scene_knob.dart';
import '../../domain/usecases/set_temporal_distortion.dart';
import '../../domain/usecases/start_ambience.dart';
import '../../domain/usecases/stop_ambience.dart';
import '../../domain/usecases/watch_scene_sound_events.dart';

/// Drives the focus screen: the orb knobs, focus scene controls, the task line
/// and the session timer, all backed by the ambient sound engine.
///
/// Audio starts lazily on the first knob or dimension interaction, matching the
/// reference UI (which boots its audio context on the first gesture).
class FocusController extends ChangeNotifier {
  FocusController({
    required SceneConfig scene,
    required StartAmbience startAmbience,
    required SetSceneKnob setSceneKnob,
    required SetSceneDimension setSceneDimension,
    required SetTemporalDistortion setTemporalDistortion,
    required StopAmbience stopAmbience,
    required WatchSceneSoundEvents watchSceneSoundEvents,
    Duration sessionLength = const Duration(minutes: 25),
  }) : _scene = scene,
       _startAmbience = startAmbience,
       _setSceneKnob = setSceneKnob,
       _setSceneDimension = setSceneDimension,
       _setTemporalDistortion = setTemporalDistortion,
       _stopAmbience = stopAmbience,
       _watchSceneSoundEvents = watchSceneSoundEvents,
       _sessionLength = sessionLength {
    _knobValues = {for (final knob in scene.knobs) knob.id: knob.initialValue};
    _dimensionValues = {
      for (final filter in scene.filters) filter.id: filter.initialValue,
    };
    _dimensionId = _initialDimensionId(scene);
    _knobs = _orbKnobsFromScene();
    unawaited(_bindSceneSoundEvents());
  }

  final SceneConfig _scene;
  final StartAmbience _startAmbience;
  final SetSceneKnob _setSceneKnob;
  final SetSceneDimension _setSceneDimension;
  final SetTemporalDistortion _setTemporalDistortion;
  final StopAmbience _stopAmbience;
  final WatchSceneSoundEvents _watchSceneSoundEvents;
  final Duration _sessionLength;

  late Map<String, double> _knobValues;
  late Map<String, double> _dimensionValues;
  late DopFocusOrbKnobs _knobs;
  final DopFocusOrbController _orbController = DopFocusOrbController();
  late String _dimensionId;
  String _task = '';
  bool _muted = false;
  late final ValueNotifier<Duration> _remaining = ValueNotifier(_sessionLength);
  Timer? _timer;
  Timer? _knobFlushTimer;
  StreamSubscription<ProceduralSoundEvent>? _soundEvents;
  bool _started = false;
  bool _disposed = false;
  Future<void>? _startOp;
  Future<void> _distortionOp = Future.value();
  Completer<void>? _knobFlushCompleter;
  final Map<String, double> _pendingKnobValues = {};

  static const Duration _knobFlushDelay = Duration(milliseconds: 48);

  /// Scene rendered and controlled by this focus session.
  SceneConfig get scene => _scene;

  /// Normalized knob levels that warp the orb.
  DopFocusOrbKnobs get knobs => _knobs;

  /// Event controller that syncs orb particles to real bell chimes.
  DopFocusOrbController get orbController => _orbController;

  /// The task the user is committing to.
  String get task => _task;

  /// Whether the ambient mix is currently silenced.
  bool get isMuted => _muted;

  /// Time left in the current session. Ticks every second on its own, so the
  /// timer chip can repaint without rebuilding the rest of the screen.
  ValueListenable<Duration> get remaining => _remaining;

  /// `mm:ss` view of [remaining].
  String get remainingLabel => formatDuration(_remaining.value);

  /// Active configured focus dimension.
  String get dimensionId => _dimensionId;

  /// Visual space matching the active configured focus dimension.
  DopFocusOrbDimension get orbDimension => _orbDimensionFor(_dimensionId);

  /// Formats a [duration] as `mm:ss`.
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Begins the countdown from the full session length.
  void startTimer() {
    _timer?.cancel();
    _remaining.value = _sessionLength;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.value.inSeconds <= 1) {
        _remaining.value = Duration.zero;
        _timer?.cancel();
      } else {
        _remaining.value -= const Duration(seconds: 1);
      }
    });
  }

  /// Starts the audio engine from the first user gesture.
  ///
  /// Chrome only unlocks WebAudio from user activation. Knob changes are async,
  /// so the focus screen calls this on pointer down before drag updates arrive.
  void primeAudio() {
    unawaited(_ensureStarted().catchError((_) {}));
  }

  /// Current scene knob value in `0..1`.
  double knobValue(String knobId) => _knobValues[knobId] ?? 0;

  /// Current scene dimension value in `0..1`.
  double dimensionValue(String dimensionId) =>
      _dimensionValues[dimensionId] ?? 0;

  /// Mixes scene [knobId] to [level] and warps the orb to match.
  Future<void> setKnob(String knobId, double level) {
    final value = level.clamp(0.0, 1.0).toDouble();
    if (_knobValues[knobId] == value) return Future<void>.value();
    _knobValues = {..._knobValues, knobId: value};
    _knobs = _orbKnobsFromScene();
    notifyListeners();
    _pendingKnobValues[knobId] = value;
    return _scheduleKnobFlush();
  }

  /// Adjusts one configured scene dimension.
  Future<void> setDimension(String dimensionId, double amount) async {
    final value = amount.clamp(0.0, 1.0).toDouble();
    if (_dimensionValues[dimensionId] == value) return;
    _dimensionValues = {..._dimensionValues, dimensionId: value};
    notifyListeners();
    await _ensureStarted();
    await _setSceneDimension(SetSceneDimensionParams(dimensionId, value));
  }

  /// Switches the configured focus scene dimension.
  Future<void> selectDimension(String dimensionId) async {
    if (dimensionId == _dimensionId) return;
    _dimensionId = dimensionId;
    _dimensionValues = {
      for (final filter in _scene.filters)
        filter.id: filter.id == dimensionId ? 1.0 : 0.0,
    };
    notifyListeners();
    await _ensureStarted();
    await _setSceneDimension(SetSceneDimensionParams(dimensionId, 1));
  }

  /// Records the task line text. Does not touch audio.
  void setTask(String task) => _task = task;

  /// Silences or resumes the whole mix, keeping the engine warm.
  ///
  /// Muting pauses the voices via [StopAmbience]; unmuting boots the engine if
  /// needed and resumes them. Knob levels survive, so the mix returns unchanged.
  Future<void> toggleMute() async {
    _muted = !_muted;
    notifyListeners();
    if (_muted) {
      await _stopAmbience(const NoParams());
      _started = false;
    } else {
      await _ensureStarted();
    }
  }

  /// Temporarily bends the focus scene while the orb is being pressed.
  void setOrbDistortion(double amount) {
    final value = amount.clamp(0.0, 1.0).toDouble();
    _distortionOp = _distortionOp.catchError((_) {}).then((_) async {
      await _ensureStarted();
      await _setTemporalDistortion(value);
    });
    unawaited(_distortionOp.catchError((_) {}));
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _knobFlushTimer?.cancel();
    _knobFlushCompleter?.complete();
    _knobFlushCompleter = null;
    unawaited(_soundEvents?.cancel());
    _orbController.dispose();
    _remaining.dispose();
    unawaited(_stopAmbience(const NoParams()));
    super.dispose();
  }

  Future<void> _ensureStarted() {
    if (_started) return Future.value();
    final pendingStart = _startOp;
    if (pendingStart != null) return pendingStart;

    final start = _start();
    _startOp = start;
    return start.whenComplete(() {
      _startOp = null;
    });
  }

  Future<void> _start() async {
    await _startAmbience(const NoParams());
    _started = true;
    await _applySceneState();
  }

  Future<void> _scheduleKnobFlush() {
    final completer = _knobFlushCompleter ??= Completer<void>();
    _knobFlushTimer?.cancel();
    _knobFlushTimer = Timer(_knobFlushDelay, () {
      final activeCompleter = _knobFlushCompleter;
      _knobFlushCompleter = null;
      unawaited(
        _flushPendingKnobs()
            .then((_) => activeCompleter?.complete())
            .catchError((Object error, StackTrace stackTrace) {
              activeCompleter?.completeError(error, stackTrace);
            }),
      );
    });
    return completer.future;
  }

  Future<void> _flushPendingKnobs() async {
    if (_disposed || _pendingKnobValues.isEmpty) return;
    final values = Map<String, double>.of(_pendingKnobValues);
    _pendingKnobValues.clear();
    await _ensureStarted();
    if (_disposed) return;
    for (final entry in values.entries) {
      await _setSceneKnob(SetSceneKnobParams(entry.key, entry.value));
    }
  }

  Future<void> _bindSceneSoundEvents() async {
    final events = await _watchSceneSoundEvents(const NoParams());
    if (_disposed) return;
    _soundEvents = events.listen((event) {
      if (_disposed) return;
      if (event.soundId == 'bell') {
        _orbController.strikeBell(intensity: event.intensity);
      }
    });
  }

  Future<void> _applySceneState() async {
    for (final entry in _knobValues.entries) {
      await _setSceneKnob(SetSceneKnobParams(entry.key, entry.value));
    }
    for (final entry in _dimensionValues.entries) {
      await _setSceneDimension(SetSceneDimensionParams(entry.key, entry.value));
    }
  }

  DopFocusOrbKnobs _orbKnobsFromScene() {
    return DopFocusOrbKnobs(
      drone: knobValue('drone'),
      rain: knobValue('rain'),
      pulse: knobValue('pulse'),
      bell: knobValue('bell'),
      cicada: knobValue('cicada'),
    );
  }

  static String _initialDimensionId(SceneConfig scene) {
    return scene.filters
        .firstWhere(
          (filter) => filter.initialValue > 0,
          orElse: () => scene.filters.first,
        )
        .id;
  }

  static DopFocusOrbDimension _orbDimensionFor(String dimensionId) {
    return DopFocusOrbDimension.values.firstWhere(
      (dimension) => dimension.name == dimensionId,
      orElse: () => DopFocusOrbDimension.room,
    );
  }
}
