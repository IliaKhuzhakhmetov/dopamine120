import 'package:core/core.dart';

import '../../domain/entities/app_theme.dart';

/// Theme persistence over the injected [KeyValueStore].
class ThemeLocalDs {
  ThemeLocalDs(this._store);

  static const _themeKey = 'app_theme';

  static const storageKeys = {_themeKey};

  final KeyValueStore _store;

  AppTheme get currentTheme =>
      AppTheme.fromStorageValue(_store.getString(_themeKey));

  Future<void> saveTheme(AppTheme theme) =>
      _store.setString(_themeKey, theme.storageValue);
}
