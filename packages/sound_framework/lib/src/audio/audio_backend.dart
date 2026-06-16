import 'dart:typed_data';

/// Procedural waveform families supported by the backend.
enum WaveFormType {
  /// Sine wave.
  sin,

  /// Triangle wave.
  triangle,
}

/// Opaque reference to a loaded audio source.
///
/// The orchestration layer never inspects [raw]; only the concrete
/// [AudioBackend] that produced it knows how to interpret the payload (a real
/// `AudioSource` for SoLoud, a plain int for the fake). Keeping the token
/// opaque is what lets the engine and voices stay free of any SoLoud type.
class VoiceSource {
  /// Wraps the backend-specific [raw] payload.
  const VoiceSource(this.raw);

  /// Backend-private payload — never read outside the owning backend.
  ///
  /// Typed `dynamic` because SoLoud's handles are extension types (not
  /// subtypes of `Object`), so they cannot be stored as `Object`.
  final dynamic raw;
}

/// Opaque reference to a single playing voice (a started [VoiceSource]).
class VoiceHandle {
  /// Wraps the backend-specific [raw] payload.
  const VoiceHandle(this.raw);

  /// Backend-private payload — never read outside the owning backend.
  ///
  /// Typed `dynamic` because SoLoud's handles are extension types (not
  /// subtypes of `Object`), so they cannot be stored as `Object`.
  final dynamic raw;
}

/// Opaque reference to a loaded asset/procedural source in the scene engine.
class AudioSourceRef extends VoiceSource {
  /// Wraps the backend-specific [raw] payload.
  const AudioSourceRef(super.raw);
}

/// Opaque reference to a playing voice in the scene engine.
class VoiceRef extends VoiceHandle {
  /// Wraps the backend-specific [raw] payload.
  const VoiceRef(super.raw);
}

/// Opaque reference to a backend mixing bus.
class BusRef {
  /// Wraps the backend-specific [raw] payload.
  const BusRef(this.raw);

  /// Backend-private payload.
  final dynamic raw;
}

/// Asset loading strategy selected by the backend capability layer.
enum LoadModePolicy {
  /// Decode and keep the sound in memory.
  memory,

  /// Stream from disk when the backend supports it.
  disk,
}

/// Backend-level configuration for scene playback.
class AudioBackendConfig {
  /// Creates backend policy configuration.
  const AudioBackendConfig({this.defaultLoadMode = LoadModePolicy.memory});

  /// Default load mode used when a request does not override it.
  final LoadModePolicy defaultLoadMode;
}

/// Address for a backend parameter.
class AudioParamAddress {
  /// Creates a parameter address.
  const AudioParamAddress({required this.name, this.bus, this.soundId});

  /// Parameter name, for example `volume`, `pan`, or an effect parameter.
  final String name;

  /// Optional bus target.
  final BusRef? bus;

  /// Optional logical sound target.
  final String? soundId;
}

/// A complete request to start one source.
class PlayRequest {
  /// Creates a play request.
  const PlayRequest({
    required this.source,
    this.bus,
    this.volume = 1,
    this.pan = 0,
    this.looping = false,
  });

  /// Source to play.
  final AudioSourceRef source;

  /// Optional bus to route through.
  final BusRef? bus;

  /// Start volume.
  final double volume;

  /// Stereo pan in `-1..1`, if supported.
  final double pan;

  /// Whether the voice loops.
  final bool looping;
}

/// Fully-resolved settings for the shared filter → reverb → echo bus.
///
/// Produced by a pure mapper from an `AcousticProfile` and applied verbatim by
/// the backend, so the Hz/normalized math is testable without any audio engine.
class BusSettings {
  /// Bundles the resolved bus parameters.
  const BusSettings({
    required this.filterType,
    required this.frequency,
    required this.resonance,
    required this.filterWet,
    required this.reverbWet,
    required this.roomSize,
    required this.damp,
    required this.echoDelay,
    required this.echoDecay,
    required this.echoWet,
    required this.globalVolume,
  });

  /// Biquad type code: `0` lowpass, `2` bandpass (SoLoud's enumeration).
  final int filterType;

  /// Biquad corner/centre frequency in Hz.
  final double frequency;

  /// Biquad resonance/Q.
  final double resonance;

  /// Biquad wet mix in `0..1`.
  final double filterWet;

  /// Reverb wet mix in `0..1`.
  final double reverbWet;

  /// Reverb room size in `0..1`.
  final double roomSize;

  /// Reverb damping in `0..1`.
  final double damp;

  /// Echo delay time in seconds.
  final double echoDelay;

  /// Echo feedback/decay in `0..1`.
  final double echoDecay;

  /// Echo wet mix in `0..1`.
  final double echoWet;

  /// Master output gain in `0..1`.
  final double globalVolume;
}

/// The narrow audio capabilities the focus synth relies on.
///
/// This is the port (in the hexagonal sense) between the procedural engine and
/// whatever drives the speakers. `SoLoudAudioBackend` adapts it onto
/// `flutter_soloud`
/// in production; tests supply a recording fake, so every layer above this
/// interface is unit-testable without native audio.
abstract class AudioBackend {
  /// Whether the underlying engine has been booted.
  bool get isInitialized;

  /// Boots the engine and configures the platform audio session.
  Future<void> init();

  /// Releases all native resources.
  void dispose();

  /// Loads a procedural waveform source (frequency set later via
  /// [setWaveformFreq]).
  Future<VoiceSource> loadWaveform(WaveFormType waveform);

  /// Retunes a waveform [source] to [freq] Hz.
  void setWaveformFreq(VoiceSource source, double freq);

  /// Loads an in-memory WAV [bytes] as a source, tagged with [name] for the
  /// engine's cache.
  Future<VoiceSource> loadNoise(String name, Uint8List bytes);

  /// Loads an app asset into a backend source.
  Future<AudioSourceRef> loadAsset(
    String assetKey, {
    LoadModePolicy policy = LoadModePolicy.memory,
  });

  /// Opens a PCM (s16le, mono) streaming source for the web fallback path.
  VoiceSource openPcmStream({
    required int maxBufferSizeBytes,
    required double bufferingTimeNeeds,
    required int sampleRate,
  });

  /// Appends raw PCM [bytes] to a streaming [source].
  void pushPcm(VoiceSource source, Uint8List bytes);

  /// Signals that no more PCM will be pushed to [source].
  void endPcm(VoiceSource source);

  /// Releases [source] and stops any voices still playing from it.
  void disposeSource(VoiceSource source);

  /// Starts [source] and returns its handle.
  VoiceHandle play(
    VoiceSource source, {
    double volume = 1,
    double pan = 0,
    bool looping = false,
  });

  /// Creates a mixing bus for grouped scene control.
  Future<BusRef> createBus(String id);

  /// Starts a scene-engine [request] and returns its handle.
  VoiceRef playRequest(PlayRequest request);

  /// Stops a scene-engine [voice], optionally after a fade.
  Future<void> stop(VoiceRef voice, {Duration fadeOut = Duration.zero});

  /// Sets the audible level of [handle] in `0..1`.
  void setVolume(VoiceHandle handle, double volume);

  /// Sets the audible level of [bus] in `0..1`.
  void setBusVolume(BusRef bus, double volume);

  /// Sets an addressed backend parameter when the backend supports it.
  void setParam(AudioParamAddress address, double value);

  /// Pauses or resumes [handle].
  void setPause(VoiceHandle handle, bool pause);

  /// Sweeps [handle]'s volume between [from] and [to] every [period].
  void oscillateVolume(
    VoiceHandle handle,
    double from,
    double to,
    Duration period,
  );

  /// Fades [handle]'s volume to [to] over [time].
  void fadeVolume(VoiceHandle handle, double to, Duration time);

  /// Stops [handle] after [time].
  void scheduleStop(VoiceHandle handle, Duration time);

  /// Keeps a looping, inaudible [handle] from being culled by the voice mixer.
  void keepLoopAlive(VoiceHandle handle);

  /// Pushes [settings] onto the shared filter/reverb/echo bus and master gain.
  void applyBus(BusSettings settings);

  /// Activates the shared bus filters so they start processing.
  void activateBus();
}
