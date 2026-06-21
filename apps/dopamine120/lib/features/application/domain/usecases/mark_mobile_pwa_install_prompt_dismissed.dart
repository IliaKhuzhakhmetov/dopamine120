import 'package:core/core.dart';

import '../repositories/mobile_pwa_install_prompt_repository.dart';

class MarkMobilePwaInstallPromptDismissed implements UseCase<void, NoParams> {
  MarkMobilePwaInstallPromptDismissed(this._repository);

  final MobilePwaInstallPromptRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.markDismissed();
}
