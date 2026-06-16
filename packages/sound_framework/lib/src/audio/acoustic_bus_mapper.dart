import 'dart:math' as math;

import '../models/acoustic_profile.dart';
import 'audio_backend.dart';

/// Maps an engine-agnostic [AcousticProfile] plus a transient bend amount onto
/// concrete [BusSettings] for the shared audio bus.
///
/// Pure: all the clamping and `0..1` warp math lives here, so profile-to-bus
/// translation is testable without touching an audio engine.
class AcousticBusMapper {
  /// Creates a stateless mapper.
  const AcousticBusMapper();

  /// Resolves [profile] under a `0..1` [bend] into [BusSettings].
  ///
  /// At `distortion == 0` the profile passes through (clamped to engine ranges);
  /// as it rises the filter closes and resonates, reverb and echo swell, and
  /// the master gain dips.
  BusSettings map(AcousticProfile profile, double bend) {
    final amount = bend.clamp(0.0, 1.0).toDouble();

    final warpedCutoff = _mix(
      profile.cutoffHz,
      math.max(120, profile.cutoffHz * 0.38),
      amount,
    );
    final warpedResonance = _mix(
      profile.resonance,
      math.max(3.2, profile.resonance * 3.4),
      amount,
    );

    return BusSettings(
      filterType: profile.filterShape == AcousticFilterShape.lowpass ? 0 : 2,
      frequency: warpedCutoff.clamp(10.0, 16000.0),
      resonance: warpedResonance.clamp(0.1, 20.0),
      filterWet: 1,
      reverbWet: (profile.reverbWet + amount * 0.08).clamp(0.0, 1.0),
      roomSize: (profile.roomSize + amount * 0.08).clamp(0.0, 1.0),
      damp: 0.35,
      echoDelay: _mix(
        profile.delaySeconds,
        math.max(0.035, profile.delaySeconds * 0.62),
        amount,
      ).clamp(0.001, 1.0),
      echoDecay: (profile.delayDecay + amount * 0.22).clamp(0.0, 1.0),
      echoWet: (profile.delayWet + amount * 0.18).clamp(0.0, 1.0),
      globalVolume: (profile.masterGain * (1 - amount * 0.12)).clamp(0.0, 1.0),
    );
  }

  double _mix(double from, double to, double amount) =>
      from + (to - from) * amount;
}
