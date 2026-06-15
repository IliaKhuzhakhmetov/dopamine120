import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/src/audio/sample_synth.dart';
import 'package:sound_framework/src/audio/wav_codec.dart';

int _u32(Uint8List b, int o) =>
    b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24);

int _peakAmplitude(Uint8List wav) {
  final data = ByteData.sublistView(wav, WavCodec.headerBytes);
  var peak = 0;
  for (var o = 0; o + 1 < data.lengthInBytes; o += 2) {
    final magnitude = data.getInt16(o, Endian.little).abs();
    if (magnitude > peak) peak = magnitude;
  }
  return peak;
}

void main() {
  const synth = SampleSynth(sampleRate: 8000);

  group('harmonicWav', () {
    test('renders exactly one second of mono 16-bit samples', () {
      final wav = synth.harmonicWav(
        fundamentalHz: 55,
        harmonicGains: const [1, 0.5],
      );

      expect(_u32(wav, 24), 8000, reason: 'header sample rate');
      expect(_u32(wav, 40), 8000 * 2, reason: '1 s of 16-bit samples');
    });

    test('normalises near full scale without clipping', () {
      final wav = synth.harmonicWav(
        fundamentalHz: 55,
        harmonicGains: const [1, 0.5, 0.25],
      );
      final peak = _peakAmplitude(wav);

      // Synth targets 0.85 of full scale; assert it is loud but not clipped.
      expect(peak, lessThanOrEqualTo(32767));
      expect(peak, greaterThan((0.85 * 32767 * 0.95).round()));
    });
  });

  group('bandNoiseWav', () {
    test('renders two seconds of samples', () {
      final wav = synth.bandNoiseWav(
        centreHz: 1050,
        q: 0.5,
        pink: true,
        random: Random(1),
      );
      expect(_u32(wav, 40), 8000 * 2 * 2, reason: '2 s of 16-bit samples');
    });

    test('is deterministic for a given seed', () {
      Uint8List render() => synth.bandNoiseWav(
        centreHz: 4800,
        q: 9,
        amplitudeModulated: true,
        random: Random(42),
      );
      expect(render(), equals(render()));
    });

    test('differs across seeds', () {
      final a = synth.bandNoiseWav(centreHz: 1050, q: 0.5, random: Random(1));
      final b = synth.bandNoiseWav(centreHz: 1050, q: 0.5, random: Random(2));
      expect(a, isNot(equals(b)));
    });
  });
}
