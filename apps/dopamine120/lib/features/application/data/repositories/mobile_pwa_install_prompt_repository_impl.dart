import '../../domain/repositories/mobile_pwa_install_prompt_repository.dart';
import '../datasources/mobile_pwa_install_prompt_local_ds.dart';

class MobilePwaInstallPromptRepositoryImpl
    implements MobilePwaInstallPromptRepository {
  MobilePwaInstallPromptRepositoryImpl(this._local);

  final MobilePwaInstallPromptLocalDs _local;

  @override
  bool get isDismissed => _local.isDismissed;

  @override
  Future<void> markDismissed() => _local.markDismissed();
}
