import 'package:flutter/foundation.dart';

import '../domain/entities/app_theme.dart';
import '../domain/usecases/save_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    required AppTheme initialTheme,
    required SaveTheme saveTheme,
  }) : _theme = initialTheme,
       _saveTheme = saveTheme;

  final SaveTheme _saveTheme;

  AppTheme _theme;

  AppTheme get theme => _theme;

  bool get isDark => _theme == AppTheme.dark;

  Future<void> useLight() => setTheme(AppTheme.light);

  Future<void> useDark() => setTheme(AppTheme.dark);

  Future<void> toggle() {
    return setTheme(isDark ? AppTheme.light : AppTheme.dark);
  }

  Future<void> setTheme(AppTheme theme) async {
    if (_theme == theme) return;

    _theme = theme;
    notifyListeners();
    await _saveTheme(theme);
  }
}
