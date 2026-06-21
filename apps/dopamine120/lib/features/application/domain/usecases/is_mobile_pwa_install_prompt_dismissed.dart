import 'package:core/core.dart';

import '../repositories/mobile_pwa_install_prompt_repository.dart';

class IsMobilePwaInstallPromptDismissed implements UseCase<bool, NoParams> {
  IsMobilePwaInstallPromptDismissed(this._repository);

  final MobilePwaInstallPromptRepository _repository;

  @override
  Future<bool> call(NoParams params) async => _repository.isDismissed;
}
