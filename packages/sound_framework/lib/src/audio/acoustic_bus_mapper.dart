import 'dart:math' as math;

import '../models/acoustic_profile.dart';
import 'audio_backend.dart';

/// Maps an engine-agnostic [AcousticProfile] (plus a transient temporal-
/// distortion bend) onto concrete [BusSettings] for the shared audio bus.
///
/// Pure: all the clamping and `0..1` warp math lives here, so the dimension →
/// bus translation is testable without touching an audio engine.
class AcousticBusMapper {
  /// Creates a stateless mapper.
  const AcousticBusMapper();

  /// Resolves [profile] under a `0..1` [distortion] bend into [BusSettings].
  ///
  /// At `distortion == 0` the profile passes through (clamped to engine ranges);
  /// as it rises the filter closes and resonates, reverb and echo swell, and the
  /// master gain dips — the "orb pressed" warp.
  BusSettings map(AcousticProfile profile, double distortion) {
    final bend = distortion.clamp(0.0, 1.0).toDouble();

    final warpedCutoff = _mix(
      profile.cutoffHz,
      math.max(120, profile.cutoffHz * 0.38),
      bend,
    );
    final warpedResonance = _mix(
      profile.resonance,
      math.max(3.2, profile.resonance * 3.4),
      bend,
    );

    return BusSettings(
      filterType: profile.filterShape == AcousticFilterShape.lowpass ? 0 : 2,
      frequency: warpedCutoff.clamp(10.0, 16000.0),
      resonance: warpedResonance.clamp(0.1, 20.0),
      filterWet: 1,
      reverbWet: (profile.reverbWet + bend * 0.08).clamp(0.0, 1.0),
      roomSize: (profile.roomSize + bend * 0.08).clamp(0.0, 1.0),
      damp: 0.35,
      echoDelay: _mix(
        profile.delaySeconds,
        math.max(0.035, profile.delaySeconds * 0.62),
        bend,
      ).clamp(0.001, 1.0),
      echoDecay: (profile.delayDecay + bend * 0.22).clamp(0.0, 1.0),
      echoWet: (profile.delayWet + bend * 0.18).clamp(0.0, 1.0),
      globalVolume: (profile.masterGain * (1 - bend * 0.12)).clamp(0.0, 1.0),
    );
  }

  double _mix(double from, double to, double amount) =>
      from + (to - from) * amount;
}
