/// Immutable observable state for [SoundEngine].
class SoundEngineState {
  /// Creates engine state.
  const SoundEngineState({
    this.initialized = false,
    this.activeSceneId,
    this.preloadedSceneIds = const {},
    this.knobs = const {},
    this.filters = const {},
    this.errors = const [],
    this.disposed = false,
  });

  /// Whether the backend has been initialized.
  final bool initialized;

  /// Currently active ambient scene, if any.
  final String? activeSceneId;

  /// Scene ids that have been preloaded.
  final Set<String> preloadedSceneIds;

  /// Current knob values by id.
  final Map<String, double> knobs;

  /// Current filter values by id.
  final Map<String, double> filters;

  /// Non-fatal command failures.
  final List<Object> errors;

  /// Whether [SoundEngine.dispose] has run.
  final bool disposed;

  /// Returns a modified copy.
  SoundEngineState copyWith({
    bool? initialized,
    Object? activeSceneId = _sentinel,
    Set<String>? preloadedSceneIds,
    Map<String, double>? knobs,
    Map<String, double>? filters,
    List<Object>? errors,
    bool? disposed,
  }) {
    return SoundEngineState(
      initialized: initialized ?? this.initialized,
      activeSceneId: identical(activeSceneId, _sentinel)
          ? this.activeSceneId
          : activeSceneId as String?,
      preloadedSceneIds: preloadedSceneIds ?? this.preloadedSceneIds,
      knobs: knobs ?? this.knobs,
      filters: filters ?? this.filters,
      errors: errors ?? this.errors,
      disposed: disposed ?? this.disposed,
    );
  }

  static const Object _sentinel = Object();
}
