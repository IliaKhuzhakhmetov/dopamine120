/// App-agnostic sound framework.
library;

export 'src/application/sound_engine.dart' show SoundEngine;
export 'src/audio/audio_backend.dart'
    show
        AudioBackend,
        AudioBackendConfig,
        AudioParamAddress,
        AudioSourceRef,
        BusRef,
        BusSettings,
        LoadModePolicy,
        PlayRequest,
        VoiceHandle,
        VoiceRef,
        VoiceSource,
        WaveFormType;
export 'src/audio/asset_loop_voice.dart' show AssetLoopVoice;
export 'src/audio/shuffled_asset_loop_voice.dart' show ShuffledAssetLoopVoice;
export 'src/audio/background_audio_session.dart'
    show
        BackgroundAudioSession,
        BackgroundAudioSessionRequest,
        NoopBackgroundAudioSession;
export 'src/audio/soloud_audio_backend.dart' show SoLoudAudioBackend;
export 'src/audio/loop_player.dart' show LoopPlayer, LoopVoice;
export 'src/audio/procedural_voice.dart'
    show ProceduralVoice, ProceduralVoiceBuildContext;
export 'src/audio/sample_synth.dart'
    show NoiseColor, SampleSynth, SampleTransform;
export 'src/core/command/sound_command_queue.dart' show SoundCommandQueue;
export 'src/core/config/scene_registry.dart' show SceneRegistry;
export 'src/core/config/sound_config.dart'
    show
        BusConfig,
        FilterConfig,
        KnobConfig,
        SceneConfig,
        SceneSoundConfig,
        SceneSoundType,
        SoundControlMapping,
        SoundMappingScale,
        SoundMappingTarget,
        SoundPackConfig,
        TriggerSoundConfig;
export 'src/core/scene/asset_cache.dart' show AssetCache;
export 'src/core/state/sound_engine_state.dart' show SoundEngineState;
export 'src/models/acoustic_profile.dart'
    show AcousticFilterShape, AcousticProfile;
export 'src/models/procedural_sound_event.dart' show ProceduralSoundEvent;
export 'src/procedural_sound_engine.dart' show ProceduralSoundEngine;
