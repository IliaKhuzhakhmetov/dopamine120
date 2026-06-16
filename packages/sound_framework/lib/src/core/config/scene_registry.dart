import 'sound_config.dart';

/// Lookup table for typed scene and sound-pack configs.
class SceneRegistry {
  /// Creates a registry.
  SceneRegistry({
    Iterable<SceneConfig> scenes = const [],
    Iterable<SoundPackConfig> soundPacks = const [],
  }) : _scenes = {for (final scene in scenes) scene.id: scene},
       _triggers = {
         for (final pack in soundPacks)
           for (final sound in pack.sounds) sound.id: sound,
       };

  final Map<String, SceneConfig> _scenes;
  final Map<String, TriggerSoundConfig> _triggers;

  /// Returns the scene with [id], or throws if it is missing.
  SceneConfig scene(String id) {
    final config = _scenes[id];
    if (config == null) throw ArgumentError.value(id, 'id', 'Unknown scene');
    return config;
  }

  /// Returns the trigger with [id], or throws if it is missing.
  TriggerSoundConfig trigger(String id) {
    final config = _triggers[id];
    if (config == null) throw ArgumentError.value(id, 'id', 'Unknown trigger');
    return config;
  }
}
