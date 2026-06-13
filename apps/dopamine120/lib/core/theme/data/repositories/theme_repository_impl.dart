import '../../domain/entities/app_theme.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_ds.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._local);

  final ThemeLocalDs _local;

  @override
  AppTheme get currentTheme => _local.currentTheme;

  @override
  Future<void> saveTheme(AppTheme theme) => _local.saveTheme(theme);
}
