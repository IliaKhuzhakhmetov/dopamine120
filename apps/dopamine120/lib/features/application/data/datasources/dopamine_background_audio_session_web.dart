import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:sound_framework/sound_framework.dart';

@JS('dopamineBackgroundAudio.start')
external JSPromise<JSAny?> _start();

@JS('dopamineBackgroundAudio.stop')
external JSPromise<JSAny?> _stop();

@JS('dopamineBackgroundAudio.onStopRequested')
external set _onStopRequested(JSFunction value);

@JS('dopamineBackgroundAudio.onStartRequested')
external set _onStartRequested(JSFunction value);

class DopamineWebBackgroundAudioSession implements BackgroundAudioSession {
  DopamineWebBackgroundAudioSession() {
    _onStartRequested = (() {
      _request(BackgroundAudioSessionRequest.start);
    }).toJS;
    _onStopRequested = (() {
      _request(BackgroundAudioSessionRequest.stop);
    }).toJS;
  }

  final _requests = ValueNotifier<BackgroundAudioSessionRequest?>(null);

  @override
  ValueListenable<BackgroundAudioSessionRequest?> get requests => _requests;

  @override
  Future<void> start() => _start().toDart;

  @override
  Future<void> stop() => _stop().toDart;

  void _request(BackgroundAudioSessionRequest request) {
    _requests.value = null;
    _requests.value = request;
  }
}

BackgroundAudioSession createDopamineBackgroundAudioSession() =>
    DopamineWebBackgroundAudioSession();
