import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/usecases/get_app_info.dart';

/// Exposes the app version to the UI. `null` until [load] resolves.
class AppVersionController extends ValueNotifier<String?> {
  AppVersionController(this._getAppInfo) : super(null);

  final GetAppInfo _getAppInfo;

  Future<void> load() async {
    final info = await _getAppInfo(const NoParams());
    value = info.version;
  }
}
