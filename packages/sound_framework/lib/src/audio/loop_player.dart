import 'dart:typed_data';

import 'audio_backend.dart';
import 'wav_codec.dart';

/// A started looping voice: its playing [handle] plus the [source] it came from.
///
/// The source is retained so the voice can be disposed when a parameter change
/// re-renders it, instead of leaking a buffer per switch.
class LoopVoice {
  /// Bundles the playing [handle] with its backing [source].
  const LoopVoice(this.handle, this.source);

  /// The playing, looping voice handle.
  final VoiceHandle handle;

  /// The source the handle was started from.
  final VoiceSource source;
}

/// Starts the engine's always-on looping voices, isolating the one place where
/// web and native diverge.
///
/// Every loop is created once at zero (or a tiny web-unlock) volume and kept
/// alive by the mixer, so mixing a sound later is just a volume nudge. On web,
/// in-memory WAVs are pushed through a PCM stream instead of [AudioBackend.loadNoise].
class LoopPlayer {
  /// Wires the player to [_backend]; [isWeb] selects the streaming fallback.
  LoopPlayer(
    this._backend, {
    required this.isWeb,
    this.sampleRate = 44100,
    this.unlockVolume = 0.0001,
  });

  final AudioBackend _backend;

  /// Whether to use the web PCM-stream fallback instead of in-memory loading.
  final bool isWeb;

  /// Sample rate of the supplied WAV buffers, in Hz.
  final int sampleRate;

  /// Tiny non-zero start volume that satisfies the browser autoplay unlock.
  final double unlockVolume;

  double get _startVolume => isWeb ? unlockVolume : 0;

  /// Starts a looping oscillator [waveform] tuned to [freq] Hz.
  Future<LoopVoice> oscillator(
    WaveFormType waveform,
    double freq, {
    double pan = 0,
  }) async {
    final source = await _backend.loadWaveform(waveform);
    _backend.setWaveformFreq(source, freq);
    return _startLoop(source, pan: pan);
  }

  /// Starts a looping voice from an in-memory [wav] noise buffer.
  Future<LoopVoice> noise(Uint8List wav, {double pan = 0}) async {
    if (isWeb) return _pcmStream(WavCodec.pcmFromWav(wav), pan: pan);

    final source = await _backend.loadNoise(
      'focus_noise_${wav.hashCode}.wav',
      wav,
    );
    return _startLoop(source, pan: pan);
  }

  LoopVoice _pcmStream(Uint8List pcm, {required double pan}) {
    // SoLoud stores stream samples as f32 internally (4 bytes/sample), so the
    // buffer ceiling must be sized against the decoded float length, not the
    // incoming s16le bytes. Our PCM is 2 bytes/sample, so the float buffer needs
    // ~2x the byte count; under-sizing it makes the stream overflow mid-add.
    final sampleCount = pcm.length ~/ 2;
    final source = _backend.openPcmStream(
      maxBufferSizeBytes: sampleCount * 4 + 1024,
      bufferingTimeNeeds: 0.05,
      sampleRate: sampleRate,
    );
    _backend.pushPcm(source, pcm);
    _backend.endPcm(source);
    return _startLoop(source, volume: unlockVolume, pan: pan);
  }

  LoopVoice _startLoop(VoiceSource source, {double? volume, double pan = 0}) {
    final handle = _backend.play(
      source,
      volume: volume ?? _startVolume,
      pan: pan,
      looping: true,
    );
    _backend.keepLoopAlive(handle);
    return LoopVoice(handle, source);
  }
}
