/// A bell chime that was actually emitted by the focus ambience engine.
class BellStrike {
  const BellStrike({required this.intensity, required this.frequency});

  /// Current bell layer level in `0..1`.
  final double intensity;

  /// Frequency of the struck note after the active dimension transpose.
  final double frequency;
}
