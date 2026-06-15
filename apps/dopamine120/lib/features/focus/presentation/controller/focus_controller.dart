import 'dart:async';

import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../domain/entities/focus_dimension.dart';
import '../../domain/usecases/select_dimension.dart';
import '../../domain/usecases/set_layer_level.dart';
import '../../domain/usecases/set_temporal_distortion.dart';
import '../../domain/usecases/start_ambience.dart';
import '../../domain/usecases/stop_ambience.dart';
import '../../domain/usecases/watch_bell_strikes.dart';

/// Drives the focus screen: the orb knobs, the active dimension, the task line
/// and the session timer, all backed by the ambient sound engine.
///
/// Audio starts lazily on the first knob or dimension interaction, matching the
/// reference UI (which boots its audio context on the first gesture).
class FocusController extends ChangeNotifier {
  FocusController({
    required StartAmbience startAmbience,
    required SetLayerLevel setLayerLevel,
    required SetTemporalDistortion setTemporalDistortion,
    required SelectDimension selectDimension,
    required StopAmbience stopAmbience,
    required WatchBellStrikes watchBellStrikes,
    Duration sessionLength = const Duration(minutes: 25),
  }) : _startAmbience = startAmbience,
       _setLayerLevel = setLayerLevel,
       _setTemporalDistortion = setTemporalDistortion,
       _selectDimension = selectDimension,
       _stopAmbience = stopAmbience,
       _watchBellStrikes = watchBellStrikes,
       _sessionLength = sessionLength {
    unawaited(_bindBellStrikes());
  }

  final StartAmbience _startAmbience;
  final SetLayerLevel _setLayerLevel;
  final SetTemporalDistortion _setTemporalDistortion;
  final SelectDimension _selectDimension;
  final StopAmbience _stopAmbience;
  final WatchBellStrikes _watchBellStrikes;
  final Duration _sessionLength;

  DopFocusOrbKnobs _knobs = const DopFocusOrbKnobs();
  final DopFocusOrbController _orbController = DopFocusOrbController();
  FocusDimension _dimension = FocusDimension.room;
  String _task = '';
  bool _muted = false;
  late final ValueNotifier<Duration> _remaining = ValueNotifier(_sessionLength);
  Timer? _timer;
  StreamSubscription<BellStrike>? _bellStrikes;
  bool _started = false;
  bool _disposed = false;
  Future<void>? _startOp;
  Future<void> _distortionOp = Future.value();

  /// Normalized knob levels that warp the orb.
  DopFocusOrbKnobs get knobs => _knobs;

  /// Event controller that syncs orb particles to real bell chimes.
  DopFocusOrbController get orbController => _orbController;

  /// The active acoustic dimension.
  FocusDimension get dimension => _dimension;

  /// The task the user is committing to.
  String get task => _task;

  /// Whether the ambient mix is currently silenced.
  bool get isMuted => _muted;

  /// Time left in the current session. Ticks every second on its own, so the
  /// timer chip can repaint without rebuilding the rest of the screen.
  ValueListenable<Duration> get remaining => _remaining;

  /// `mm:ss` view of [remaining].
  String get remainingLabel => formatDuration(_remaining.value);

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

  /// Current level of [layer] in `0..1`.
  double levelOf(SoundLayer layer) => switch (layer) {
    SoundLayer.drone => _knobs.drone,
    SoundLayer.rain => _knobs.rain,
    SoundLayer.pulse => _knobs.pulse,
    SoundLayer.bell => _knobs.bell,
    SoundLayer.cicada => _knobs.cicada,
  };

  /// Mixes [layer] to [level] and warps the orb to match.
  Future<void> setLayer(SoundLayer layer, double level) async {
    final value = level.clamp(0.0, 1.0);
    _knobs = switch (layer) {
      SoundLayer.drone => _knobs.copyWith(drone: value),
      SoundLayer.rain => _knobs.copyWith(rain: value),
      SoundLayer.pulse => _knobs.copyWith(pulse: value),
      SoundLayer.bell => _knobs.copyWith(bell: value),
      SoundLayer.cicada => _knobs.copyWith(cicada: value),
    };
    notifyListeners();
    await _ensureStarted();
    await _setLayerLevel(SetLayerLevelParams(layer, value));
  }

  /// Switches to [dimension], re-tuning both the orb and the mix.
  Future<void> selectDimension(FocusDimension dimension) async {
    if (dimension == _dimension) return;
    _dimension = dimension;
    notifyListeners();
    await _ensureStarted();
    await _selectDimension(dimension);
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
    } else {
      await _ensureStarted();
      await _startAmbience(const NoParams());
    }
  }

  /// Temporarily bends the audio bus while the orb is being pressed.
  void setTemporalDistortion(double amount) {
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
    unawaited(_bellStrikes?.cancel());
    _orbController.dispose();
    _remaining.dispose();
    unawaited(_setTemporalDistortion(0));
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
      if (!_started) _startOp = null;
    });
  }

  Future<void> _start() async {
    await _startAmbience(const NoParams());
    await _selectDimension(_dimension);
    _started = true;
  }

  Future<void> _bindBellStrikes() async {
    final strikes = await _watchBellStrikes(const NoParams());
    if (_disposed) return;
    _bellStrikes = strikes.listen((strike) {
      if (_disposed) return;
      _orbController.strikeBell(intensity: strike.intensity);
    });
  }
}
