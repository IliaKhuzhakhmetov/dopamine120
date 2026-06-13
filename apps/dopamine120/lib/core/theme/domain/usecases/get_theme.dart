import 'package:core/core.dart';

import '../entities/app_theme.dart';
import '../repositories/theme_repository.dart';

/// Reads the current app theme preference.
class GetTheme implements UseCase<AppTheme, NoParams> {
  GetTheme(this._repository);

  final ThemeRepository _repository;

  @override
  Future<AppTheme> call(NoParams params) async => _repository.currentTheme;
}
