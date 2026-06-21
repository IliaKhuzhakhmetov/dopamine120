import 'package:flutter/foundation.dart';

enum BackgroundAudioSessionRequest { start, stop }

abstract interface class BackgroundAudioSession {
  ValueListenable<BackgroundAudioSessionRequest?> get requests;

  Future<void> start();

  Future<void> stop();
}

class NoopBackgroundAudioSession implements BackgroundAudioSession {
  const NoopBackgroundAudioSession();

  static final ValueNotifier<BackgroundAudioSessionRequest?> _requests =
      ValueNotifier(null);

  @override
  ValueListenable<BackgroundAudioSessionRequest?> get requests => _requests;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}
