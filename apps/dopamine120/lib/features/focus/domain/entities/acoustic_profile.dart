/// Filter response applied to the whole mix in a given space.
enum AcousticFilterShape {
  /// Attenuates everything above the cutoff.
  lowpass,

  /// Keeps a narrow band around the cutoff.
  bandpass,
}

/// The acoustic signature of a [focus dimension]: how the shared filter,
/// reverb, echo and master gain are set so a space sounds like a room, a
/// cathedral, underwater, and so on.
///
/// Values are engine-agnostic and live in normalized/Hz units; the data layer
/// maps them onto the concrete audio engine (clamping to its ranges).
class AcousticProfile {
  /// Creates an immutable acoustic signature.
  const AcousticProfile({
    required this.filterShape,
    required this.cutoffHz,
    required this.resonance,
    required this.reverbWet,
    required this.roomSize,
    required this.delaySeconds,
    required this.delayDecay,
    required this.delayWet,
    required this.masterGain,
  });

  /// Shape of the shared master filter.
  final AcousticFilterShape filterShape;

  /// Filter corner/centre frequency in Hz.
  final double cutoffHz;

  /// Filter resonance/Q.
  final double resonance;

  /// Reverb mix in `0..1`.
  final double reverbWet;

  /// Reverb room size in `0..1`.
  final double roomSize;

  /// Echo delay time in seconds.
  final double delaySeconds;

  /// Echo feedback/decay in `0..1`.
  final double delayDecay;

  /// Echo mix in `0..1`.
  final double delayWet;

  /// Master output gain in `0..1`.
  final double masterGain;
}
