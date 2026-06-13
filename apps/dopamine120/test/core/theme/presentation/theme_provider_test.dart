import 'package:dopamine120/core/theme/domain/entities/app_theme.dart';
import 'package:dopamine120/core/theme/domain/repositories/theme_repository.dart';
import 'package:dopamine120/core/theme/domain/usecases/save_theme.dart';
import 'package:dopamine120/core/theme/presentation/theme_controller.dart';
import 'package:dopamine120/core/theme/presentation/theme_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exposes theme state and controller through context', (
    tester,
  ) async {
    final repository = _FakeThemeRepository(AppTheme.light);
    final controller = ThemeController(
      initialTheme: repository.currentTheme,
      saveTheme: SaveTheme(repository),
    );

    await tester.pumpWidget(
      ThemeProvider(
        controller: controller,
        child: Builder(
          builder: (context) {
            return Text(
              context.appTheme.storageValue,
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('light'), findsOneWidget);

    await controller.useDark();
    await tester.pump();

    expect(find.text('dark'), findsOneWidget);
  });
}

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository(this._theme);

  AppTheme _theme;

  @override
  AppTheme get currentTheme => _theme;

  @override
  Future<void> saveTheme(AppTheme theme) async {
    _theme = theme;
  }
}
