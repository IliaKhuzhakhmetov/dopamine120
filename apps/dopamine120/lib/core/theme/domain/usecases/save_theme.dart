import 'package:core/core.dart';

import '../entities/app_theme.dart';
import '../repositories/theme_repository.dart';

/// Persists a new app theme preference.
class SaveTheme implements UseCase<void, AppTheme> {
  SaveTheme(this._repository);

  final ThemeRepository _repository;

  @override
  Future<void> call(AppTheme params) => _repository.saveTheme(params);
}
