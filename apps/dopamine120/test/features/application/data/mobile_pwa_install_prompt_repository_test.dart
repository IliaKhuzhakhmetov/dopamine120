import 'package:core/core.dart';
import 'package:dopamine120/features/application/data/datasources/mobile_pwa_install_prompt_local_ds.dart';
import 'package:dopamine120/features/application/data/repositories/mobile_pwa_install_prompt_repository_impl.dart';
import 'package:dopamine120/features/application/domain/usecases/is_mobile_pwa_install_prompt_dismissed.dart';
import 'package:dopamine120/features/application/domain/usecases/mark_mobile_pwa_install_prompt_dismissed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists dismissed state through usecases', () async {
    final repository = MobilePwaInstallPromptRepositoryImpl(
      MobilePwaInstallPromptLocalDs(InMemoryKeyValueStore()),
    );
    final isDismissed = IsMobilePwaInstallPromptDismissed(repository);
    final markDismissed = MarkMobilePwaInstallPromptDismissed(repository);

    expect(await isDismissed(const NoParams()), isFalse);

    await markDismissed(const NoParams());

    expect(await isDismissed(const NoParams()), isTrue);
  });
}
