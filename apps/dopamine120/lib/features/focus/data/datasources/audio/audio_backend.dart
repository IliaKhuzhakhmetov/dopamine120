import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart' show WaveForm;

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
/// whatever drives the speakers. `SoLoudBackend` adapts it onto `flutter_soloud`
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
  Future<VoiceSource> loadWaveform(WaveForm waveform);

  /// Retunes a waveform [source] to [freq] Hz.
  void setWaveformFreq(VoiceSource source, double freq);

  /// Loads an in-memory WAV [bytes] as a source, tagged with [name] for the
  /// engine's cache.
  Future<VoiceSource> loadNoise(String name, Uint8List bytes);

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

  /// Starts [source] and returns its handle.
  VoiceHandle play(
    VoiceSource source, {
    double volume = 1,
    bool looping = false,
  });

  /// Sets the audible level of [handle] in `0..1`.
  void setVolume(VoiceHandle handle, double volume);

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
