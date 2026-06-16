import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';
import 'package:sound_framework/src/audio/acoustic_bus_mapper.dart';

const _room = AcousticProfile(
  filterShape: AcousticFilterShape.lowpass,
  cutoffHz: 16000,
  resonance: 0.1,
  reverbWet: 0.07,
  roomSize: 0.4,
  delaySeconds: 0.30,
  delayDecay: 0,
  delayWet: 0,
  masterGain: 0.55,
);

const _jungle = AcousticProfile(
  filterShape: AcousticFilterShape.bandpass,
  cutoffHz: 2100,
  resonance: 0.8,
  reverbWet: 0.18,
  roomSize: 0.5,
  delaySeconds: 0.22,
  delayDecay: 0.3,
  delayWet: 0.12,
  masterGain: 0.55,
);

void main() {
  const mapper = AcousticBusMapper();

  group('without distortion', () {
    test('passes the profile through, clamped to engine ranges', () {
      final bus = mapper.map(_room, 0);

      expect(bus.filterType, 0, reason: 'lowpass');
      expect(bus.frequency, 16000);
      expect(bus.resonance, 0.1);
      expect(bus.filterWet, 1);
      expect(bus.reverbWet, closeTo(0.07, 1e-9));
      expect(bus.roomSize, closeTo(0.4, 1e-9));
      expect(bus.damp, 0.35);
      expect(bus.echoDelay, closeTo(0.30, 1e-9));
      expect(bus.globalVolume, closeTo(0.55, 1e-9));
    });

    test('maps bandpass profiles to filter type 2', () {
      expect(mapper.map(_jungle, 0).filterType, 2);
    });
  });

  group('with bend', () {
    test('closes the filter and lifts resonance', () {
      final bus = mapper.map(_room, 1);

      expect(bus.frequency, lessThan(16000));
      expect(bus.resonance, greaterThan(0.1));
      expect(bus.reverbWet, greaterThan(0.07));
      expect(bus.roomSize, greaterThan(0.4));
      expect(bus.echoDelay, lessThan(0.30));
      expect(bus.globalVolume, lessThan(0.55), reason: 'gain dips under bend');
    });

    test('clamps to engine limits and treats >1 bend as 1', () {
      final atOne = mapper.map(_room, 1);
      final overshoot = mapper.map(_room, 5);

      expect(overshoot.frequency, atOne.frequency);
      expect(overshoot.reverbWet, lessThanOrEqualTo(1.0));
      expect(overshoot.resonance, lessThanOrEqualTo(20.0));
      expect(overshoot.frequency, greaterThanOrEqualTo(10.0));
    });
  });
}
