/// App-agnostic procedural sound framework.
library;

export 'src/audio/audio_backend.dart'
    show AudioBackend, BusSettings, VoiceHandle, VoiceSource, WaveFormType;
export 'src/audio/soloud_audio_backend.dart' show SoLoudAudioBackend;
export 'src/models/acoustic_profile.dart'
    show AcousticFilterShape, AcousticProfile;
export 'src/models/bell_strike.dart' show BellStrike;
export 'src/models/sound_layer.dart' show SoundLayer;
export 'src/models/voice_timbre.dart' show VoiceTimbre;
export 'src/procedural_sound_engine.dart' show ProceduralSoundEngine;
