import 'package:sound_framework/sound_framework.dart';

import 'dopamine_background_audio_session_stub.dart'
    if (dart.library.js_interop) 'dopamine_background_audio_session_web.dart'
    as impl;

BackgroundAudioSession createDopamineBackgroundAudioSession() =>
    impl.createDopamineBackgroundAudioSession();
