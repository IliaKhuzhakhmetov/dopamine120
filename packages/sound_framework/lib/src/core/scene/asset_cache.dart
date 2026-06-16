import '../../audio/audio_backend.dart';
import '../config/sound_config.dart';

/// Reference-counted cache for loaded audio assets.
class AssetCache {
  /// Creates an asset cache backed by [backend].
  AssetCache(this._backend);

  final AudioBackend _backend;
  final Map<String, _CachedAsset> _assets = {};

  /// Loads [config] if needed without changing its reference count.
  Future<AudioSourceRef> preload(TriggerSoundConfig config) =>
      _load(config.assetKey, config.loadModePolicy);

  /// Loads [config] if needed without changing its reference count.
  Future<AudioSourceRef> preloadSound(SceneSoundConfig config) {
    final assetKey = config.assetKey;
    if (assetKey == null) {
      throw ArgumentError.value(config.id, 'config', 'Sound has no asset');
    }
    return _load(assetKey, config.loadModePolicy);
  }

  /// Retains [assetKey] and returns its source.
  Future<AudioSourceRef> retain(
    String assetKey, {
    LoadModePolicy policy = LoadModePolicy.memory,
  }) async {
    final cached = await _load(assetKey, policy);
    _assets[assetKey] = _assets[assetKey]!.increment();
    return cached;
  }

  /// Releases [assetKey] and disposes it when the count reaches zero.
  void release(String assetKey) {
    final cached = _assets[assetKey];
    if (cached == null) return;
    final next = cached.decrement();
    if (next.refCount <= 0) {
      _backend.disposeSource(next.source);
      _assets.remove(assetKey);
    } else {
      _assets[assetKey] = next;
    }
  }

  /// Disposes all cached sources.
  void dispose() {
    for (final cached in _assets.values) {
      _backend.disposeSource(cached.source);
    }
    _assets.clear();
  }

  Future<AudioSourceRef> _load(String assetKey, LoadModePolicy policy) async {
    final cached = _assets[assetKey];
    if (cached != null) return cached.source;

    final source = await _backend.loadAsset(assetKey, policy: policy);
    _assets[assetKey] = _CachedAsset(source: source, refCount: 0);
    return source;
  }
}

class _CachedAsset {
  const _CachedAsset({required this.source, required this.refCount});

  final AudioSourceRef source;
  final int refCount;

  _CachedAsset increment() =>
      _CachedAsset(source: source, refCount: refCount + 1);

  _CachedAsset decrement() =>
      _CachedAsset(source: source, refCount: refCount - 1);
}
