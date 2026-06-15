import 'package:flutter/foundation.dart';

/// The *voices* of a [focus dimension]: how the rain, pulse, bell, cicada and
/// drone are synthesized, as opposed to the [AcousticProfile] which only colours
/// the shared filter/reverb/echo bus.
///
/// Changing a timbre re-renders the affected voices, so each space has its own
/// rainfall, chimes and breathing — not just the same mix behind a new filter.
/// The defaults reproduce the original `room` sound, so [standard] is the
/// baseline every other dimension deviates from.
@immutable
class VoiceTimbre {
  /// Creates an immutable voice signature; the defaults are the `room` timbre.
  const VoiceTimbre({
    this.droneRatio = 1.0,
    this.rainCentreHz = 1050,
    this.rainQ = 0.5,
    this.pulseHz = 55,
    this.pulseHarmonics = const [0.35, 1.0, 0.65, 0.4, 0.2],
    this.cicadaCentreHz = 4800,
    this.cicadaQ = 9,
    this.bellTranspose = 1.0,
  });

  /// Multiplies the whole drone chord, shifting the bed's pitch/octave.
  final double droneRatio;

  /// Centre frequency of the rain noise band in Hz (higher reads brighter/closer).
  final double rainCentreHz;

  /// Rain band Q (lower is wider/airier).
  final double rainQ;

  /// Fundamental of the breathing pulse in Hz.
  final double pulseHz;

  /// Harmonic weights of the pulse, fundamental first.
  final List<double> pulseHarmonics;

  /// Centre frequency of the cicada chatter band in Hz.
  final double cicadaCentreHz;

  /// Cicada band Q (high keeps it narrow and insect-like).
  final double cicadaQ;

  /// Multiplies every bell note, transposing the chimes for the space.
  final double bellTranspose;

  /// The baseline `room` timbre other dimensions deviate from.
  static const VoiceTimbre standard = VoiceTimbre();

  @override
  bool operator ==(Object other) =>
      other is VoiceTimbre &&
      other.droneRatio == droneRatio &&
      other.rainCentreHz == rainCentreHz &&
      other.rainQ == rainQ &&
      other.pulseHz == pulseHz &&
      listEquals(other.pulseHarmonics, pulseHarmonics) &&
      other.cicadaCentreHz == cicadaCentreHz &&
      other.cicadaQ == cicadaQ &&
      other.bellTranspose == bellTranspose;

  @override
  int get hashCode => Object.hash(
    droneRatio,
    rainCentreHz,
    rainQ,
    pulseHz,
    Object.hashAll(pulseHarmonics),
    cicadaCentreHz,
    cicadaQ,
    bellTranspose,
  );
}
