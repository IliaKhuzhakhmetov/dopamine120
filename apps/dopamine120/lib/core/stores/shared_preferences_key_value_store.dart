import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent app implementation of the shared key-value store contract.
class SharedPreferencesKeyValueStore implements KeyValueStore {
  const SharedPreferencesKeyValueStore(this._preferences);

  final SharedPreferencesWithCache _preferences;

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  bool getBool(String key, {bool or = false}) =>
      _preferences.getBool(key) ?? or;
}
