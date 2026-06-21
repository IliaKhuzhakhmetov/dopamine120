abstract class MobilePwaInstallPromptRepository {
  bool get isDismissed;

  Future<void> markDismissed();
}
