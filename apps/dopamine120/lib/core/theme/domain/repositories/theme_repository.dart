import '../entities/app_theme.dart';

/// Stores and reads the app theme preference.
abstract class ThemeRepository {
  AppTheme get currentTheme;

  Future<void> saveTheme(AppTheme theme);
}
