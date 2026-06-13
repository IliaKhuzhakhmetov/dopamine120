import 'package:core/core.dart';
import 'package:dopamine120/core/theme/data/datasources/theme_local_ds.dart';
import 'package:dopamine120/core/theme/domain/entities/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeLocalDs', () {
    test('defaults to light', () {
      final ds = ThemeLocalDs(InMemoryKeyValueStore());

      expect(ds.currentTheme, AppTheme.light);
    });

    test('persists selected theme', () async {
      final ds = ThemeLocalDs(InMemoryKeyValueStore());

      await ds.saveTheme(AppTheme.dark);

      expect(ds.currentTheme, AppTheme.dark);
    });
  });
}
