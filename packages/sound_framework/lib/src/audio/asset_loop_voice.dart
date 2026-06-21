import 'audio_backend.dart';
import 'loop_player.dart';
import 'procedural_voice.dart';

/// A [ProceduralVoice] that loops a bundled audio recording instead of
/// synthesizing one.
///
/// The recording carries its own texture and phrasing; the mix level simply
/// sets playback volume (scaled by [gain]).
class AssetLoopVoice extends ProceduralVoice {
  /// Creates a looping voice for the recording at [assetKey].
  AssetLoopVoice({
    required this.id,
    required this.assetKey,
    this.pan = 0,
    this.gain = 1,
    this.loadModePolicy = LoadModePolicy.memory,
  });

  @override
  final String id;

  /// App asset key of the recording to loop.
  final String assetKey;

  /// Stereo pan in `-1..1`.
  final double pan;

  /// Constant multiplier applied to the mix level before it reaches the voice.
  final double gain;

  /// Asset load policy.
  final LoadModePolicy loadModePolicy;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    return [
      await context.player.asset(assetKey, pan: pan, policy: loadModePolicy),
    ];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * gain);
    }
  }
}
