import 'package:core/core.dart';

class MobilePwaInstallPromptLocalDs {
  MobilePwaInstallPromptLocalDs(this._store);

  static const _dismissedKey = 'mobile_pwa_install_prompt_dismissed';

  static const storageKeys = {_dismissedKey};

  final KeyValueStore _store;

  bool get isDismissed => _store.getBool(_dismissedKey);

  Future<void> markDismissed() => _store.setBool(_dismissedKey, true);
}
