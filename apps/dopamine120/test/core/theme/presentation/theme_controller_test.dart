import 'package:dopamine120/core/theme/domain/entities/app_theme.dart';
import 'package:dopamine120/core/theme/domain/repositories/theme_repository.dart';
import 'package:dopamine120/core/theme/domain/usecases/save_theme.dart';
import 'package:dopamine120/core/theme/presentation/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeController', () {
    test('exposes initial theme and persists changes', () async {
      final repository = _FakeThemeRepository(AppTheme.light);
      final controller = ThemeController(
        initialTheme: repository.currentTheme,
        saveTheme: SaveTheme(repository),
      );

      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.useDark();

      expect(controller.theme, AppTheme.dark);
      expect(controller.isDark, isTrue);
      expect(repository.currentTheme, AppTheme.dark);
      expect(notifications, 1);

      await controller.useLight();

      expect(controller.theme, AppTheme.light);
      expect(repository.currentTheme, AppTheme.light);
      expect(notifications, 2);
    });

    test('does not notify when theme is unchanged', () async {
      final repository = _FakeThemeRepository(AppTheme.light);
      final controller = ThemeController(
        initialTheme: repository.currentTheme,
        saveTheme: SaveTheme(repository),
      );

      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.useLight();

      expect(notifications, 0);
      expect(repository.saves, 0);
    });
  });
}

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository(this._theme);

  AppTheme _theme;
  var saves = 0;

  @override
  AppTheme get currentTheme => _theme;

  @override
  Future<void> saveTheme(AppTheme theme) async {
    saves++;
    _theme = theme;
  }
}
