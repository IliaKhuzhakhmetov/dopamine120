import 'package:core/core.dart';

import '../entities/focus_dimension.dart';
import '../repositories/ambience_repository.dart';

/// Re-tunes the shared acoustic bus to a chosen [FocusDimension].
class SelectDimension implements UseCase<void, FocusDimension> {
  SelectDimension(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<void> call(FocusDimension params) =>
      _repository.selectDimension(params);
}
