import 'package:dopamine_ui/dopamine_ui.dart';

import 'acoustic_profile.dart';

/// The acoustic spaces the focus session can inhabit. Each one warps both the
/// orb visuals ([orbDimension]) and the sound mix ([profile]).
///
/// Names mirror [DopFocusOrbDimension] one-to-one so the orb and the engine
/// stay in lockstep.
enum FocusDimension {
  /// Dry and near.
  room,

  /// Vast stone halo.
  cathedral,

  /// Muffled deep wobble.
  underwater,

  /// Long orbit echo.
  cosmos,

  /// Humid canopy.
  jungle,

  /// Wet slap-back ghosting.
  cave,
}

/// Presentation labels, orb mapping and acoustic signature for a dimension.
extension FocusDimensionX on FocusDimension {
  /// Lower-case display label used by the dimension selector.
  String get label => orbDimension.label;

  /// One-line texture description shown under the label.
  String get description => orbDimension.description;

  /// The matching visual dimension consumed by [DopFocusOrb].
  DopFocusOrbDimension get orbDimension => switch (this) {
    FocusDimension.room => DopFocusOrbDimension.room,
    FocusDimension.cathedral => DopFocusOrbDimension.cathedral,
    FocusDimension.underwater => DopFocusOrbDimension.underwater,
    FocusDimension.cosmos => DopFocusOrbDimension.cosmos,
    FocusDimension.jungle => DopFocusOrbDimension.jungle,
    FocusDimension.cave => DopFocusOrbDimension.cave,
  };

  /// The acoustic signature applied to the shared filter/reverb/echo bus.
  ///
  /// Values are adapted from the reference UI's `DIMS` table.
  AcousticProfile get profile => switch (this) {
    FocusDimension.room => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 16000,
      resonance: 0.1,
      reverbWet: 0.07,
      roomSize: 0.4,
      delaySeconds: 0.30,
      delayDecay: 0,
      delayWet: 0,
      masterGain: 0.55,
    ),
    FocusDimension.cathedral => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 9000,
      resonance: 0.1,
      reverbWet: 0.55,
      roomSize: 0.9,
      delaySeconds: 0.34,
      delayDecay: 0.25,
      delayWet: 0.06,
      masterGain: 0.5,
    ),
    FocusDimension.underwater => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 680,
      resonance: 1.2,
      reverbWet: 0.2,
      roomSize: 0.6,
      delaySeconds: 0.30,
      delayDecay: 0,
      delayWet: 0,
      masterGain: 0.62,
    ),
    FocusDimension.cosmos => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 14000,
      resonance: 0.1,
      reverbWet: 0.4,
      roomSize: 0.85,
      delaySeconds: 0.52,
      delayDecay: 0.55,
      delayWet: 0.34,
      masterGain: 0.5,
    ),
    FocusDimension.jungle => const AcousticProfile(
      filterShape: AcousticFilterShape.bandpass,
      cutoffHz: 2100,
      resonance: 0.8,
      reverbWet: 0.18,
      roomSize: 0.5,
      delaySeconds: 0.22,
      delayDecay: 0.3,
      delayWet: 0.12,
      masterGain: 0.55,
    ),
    FocusDimension.cave => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 5200,
      resonance: 0.1,
      reverbWet: 0.3,
      roomSize: 0.7,
      delaySeconds: 0.27,
      delayDecay: 0.45,
      delayWet: 0.3,
      masterGain: 0.52,
    ),
  };
}
