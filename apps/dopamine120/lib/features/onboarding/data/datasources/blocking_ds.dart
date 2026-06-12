import 'package:app_logger/app_logger.dart';
import 'package:platform_bridge/platform_bridge.dart';

/// App listing and blocking permission over the injected [PlatformBridge].
/// Unsupported or failed paths come back empty / false, never throw.
class BlockingDs {
  BlockingDs(this._bridge);

  final PlatformBridge _bridge;
  BlockSelection _lastSelection = BlockSelection.empty;

  Future<List<AppInfo>> pickApps() async {
    try {
      final selection = await _bridge.pickApps();
      _lastSelection = selection;
      return selection.apps;
    } catch (e, s) {
      Log.e('BlockingDs.pickApps failed', error: e, stackTrace: s);
      return const [];
    }
  }

  Future<void> setBlockedApps(List<AppInfo> apps) async {
    try {
      final selection = BlockSelection(
        apps: apps,
        categoryIds: _lastSelection.categoryIds,
        categoryCount: _lastSelection.categoryCount,
      );
      await _bridge.setBlocking(selection, enabled: !selection.isEmpty);
    } catch (e, s) {
      Log.e('BlockingDs.setBlockedApps failed', error: e, stackTrace: s);
    }
  }

  Future<PermissionResult> requestBlockingAccess() async {
    try {
      return _bridge.requestBlockingAccess();
    } catch (e, s) {
      Log.e('BlockingDs.requestBlockingAccess failed', error: e, stackTrace: s);
      return PermissionResult.unsupported;
    }
  }
}
