/// Synchronous-read, async-write key-value storage contract.
abstract class KeyValueStore {
  Future<void> setString(String key, String value);
  String? getString(String key);
  Future<void> setBool(String key, bool value);
  bool getBool(String key, {bool or = false});
}

/// Dev/test implementation; nothing survives a restart.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _values = {};

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  bool getBool(String key, {bool or = false}) => _values[key] as bool? ?? or;
}
