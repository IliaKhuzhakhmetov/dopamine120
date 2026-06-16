import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../audio/audio_backend.dart';
import '../audio/soloud_audio_backend.dart';
import '../core/command/sound_command_queue.dart';
import '../core/config/scene_registry.dart';
import '../core/config/sound_config.dart';
import '../core/filter/filter_controller.dart';
import '../core/knob/knob_controller.dart';
import '../core/scene/asset_cache.dart';
import '../core/scene/scene_runner.dart';
import '../core/state/sound_engine_state.dart';

/// Scene-first sound facade for apps.
class SoundEngine {
  /// Creates a sound engine.
  SoundEngine({
    required SceneRegistry registry,
    AudioBackend? backend,
    math.Random? random,
  }) : _registry = registry,
       _backend = backend ?? SoLoudAudioBackend(),
       _random = random ?? math.Random() {
    _assets = AssetCache(_backend);
  }

  final SceneRegistry _registry;
  final AudioBackend _backend;
  final math.Random _random;
  final SoundCommandQueue _queue = SoundCommandQueue();
  final KnobController _knobs = const KnobController();
  final FilterController _filters = const FilterController();
  late final AssetCache _assets;
  final _state = ValueNotifier<SoundEngineState>(const SoundEngineState());
  final _states = StreamController<SoundEngineState>.broadcast();

  SceneRunner? _runner;
  SceneConfig? _activeScene;

  /// Current immutable state.
  SoundEngineState get currentState => _state.value;

  /// Listenable state for UI.
  ValueListenable<SoundEngineState> get stateListenable => _state;

  /// Stream of state snapshots.
  Stream<SoundEngineState> get states => _states.stream;

  /// Initializes the backend once.
  Future<void> init() => _run(() async {
    await _ensureInitialized();
  });

  /// Preloads all assets for [sceneId].
  Future<void> preloadScene(String sceneId) => _run(() async {
    await _ensureInitialized();
    final config = _registry.scene(sceneId);
    final runner = SceneRunner(
      config: config,
      backend: _backend,
      assets: _assets,
      random: _random,
    );
    await runner.preload();
    _emit(
      currentState.copyWith(
        preloadedSceneIds: {...currentState.preloadedSceneIds, sceneId},
      ),
    );
  });

  /// Starts [sceneId], replacing any active scene.
  Future<void> startScene(
    String sceneId, {
    Duration fadeIn = Duration.zero,
  }) => _run(() async {
    await _ensureInitialized();
    await _runner?.stop();

    final config = _registry.scene(sceneId);
    final runner = SceneRunner(
      config: config,
      backend: _backend,
      assets: _assets,
      random: _random,
    );
    await runner.preload();
    await runner.start(fadeIn: fadeIn);
    _runner = runner;
    _activeScene = config;
    _emit(
      currentState.copyWith(
        activeSceneId: sceneId,
        preloadedSceneIds: {...currentState.preloadedSceneIds, sceneId},
        knobs: {for (final knob in config.knobs) knob.id: knob.initialValue},
        filters: {
          for (final filter in config.filters) filter.id: filter.initialValue,
        },
      ),
    );
  });

  /// Stops the active scene.
  Future<void> stopScene({Duration fadeOut = Duration.zero}) => _run(() async {
    await _runner?.stop(fadeOut: fadeOut);
    _runner = null;
    _activeScene = null;
    _emit(currentState.copyWith(activeSceneId: null));
  });

  /// Applies [value] to the active scene knob with [id].
  Future<void> setKnob(String id, double value) => _run(() async {
    final scene = _activeScene;
    final runner = _runner;
    if (scene == null || runner == null) return;
    final knob = scene.knobs.firstWhere((item) => item.id == id);
    final normalized = value.clamp(0.0, 1.0).toDouble();
    _knobs.apply(knob, normalized, runner);
    _emit(
      currentState.copyWith(knobs: {...currentState.knobs, id: normalized}),
    );
  });

  /// Applies [value] to the active scene filter with [id].
  Future<void> setFilter(String id, double value) => _run(() async {
    final scene = _activeScene;
    final runner = _runner;
    if (scene == null || runner == null) return;
    final filter = scene.filters.firstWhere((item) => item.id == id);
    final normalized = value.clamp(0.0, 1.0).toDouble();
    _filters.apply(filter, normalized, runner);
    _emit(
      currentState.copyWith(filters: {...currentState.filters, id: normalized}),
    );
  });

  /// Plays a short configured sound by trigger id.
  Future<void> trigger(String id) => _run(() async {
    await _ensureInitialized();
    final config = _registry.trigger(id);
    await _assets.preload(config);
    final source = await _assets.retain(
      config.assetKey,
      policy: config.loadModePolicy,
    );
    _backend.playRequest(
      PlayRequest(source: source, volume: config.volume, pan: config.pan),
    );
  });

  /// Releases resources.
  Future<void> dispose() => _run(() async {
    await _runner?.stop();
    _assets.dispose();
    _backend.dispose();
    _emit(currentState.copyWith(disposed: true));
    _state.dispose();
    await _states.close();
  });

  Future<T> _run<T>(Future<T> Function() command) {
    return _queue.enqueue(() async {
      try {
        return await command();
      } catch (error) {
        _emit(currentState.copyWith(errors: [...currentState.errors, error]));
        rethrow;
      }
    });
  }

  Future<void> _ensureInitialized() async {
    if (!_backend.isInitialized) await _backend.init();
    if (!currentState.initialized) {
      _emit(currentState.copyWith(initialized: true));
    }
  }

  void _emit(SoundEngineState state) {
    if (_state.value.disposed) return;
    _state.value = state;
    if (!_states.isClosed) _states.add(state);
  }
}
