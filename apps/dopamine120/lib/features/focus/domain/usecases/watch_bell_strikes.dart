import 'package:core/core.dart';

import '../entities/bell_strike.dart';
import '../repositories/ambience_repository.dart';

/// Watches bell chimes that were actually emitted by the ambience engine.
class WatchBellStrikes implements UseCase<Stream<BellStrike>, NoParams> {
  WatchBellStrikes(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<Stream<BellStrike>> call(NoParams params) async {
    return _repository.bellStrikes;
  }
}
