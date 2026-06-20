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

    test('supports app-owned length and modulation controls', () {
      final wav = synth.harmonicWav(
        fundamentalHz: 52,
        harmonicGains: const [1, 0.4],
        seconds: 2.5,
        transform: (sample, timeSeconds) => sample * (0.5 + timeSeconds * 0.1),
        loopFadeFraction: 0.02,
      );

      expect(_u32(wav, 40), 8000 * 2.5 * 2, reason: '2.5 s of samples');
      expect(_peakAmplitude(wav), lessThanOrEqualTo(32767));
    });
  });

  group('bandNoiseWav', () {
    test('renders two seconds of samples', () {
      final wav = synth.bandNoiseWav(
        centerHz: 1050,
        q: 0.5,
        color: NoiseColor.pink,
        random: Random(1),
      );
      expect(_u32(wav, 40), 8000 * 2 * 2, reason: '2 s of 16-bit samples');
    });

    test('is deterministic for a given seed', () {
      Uint8List render() => synth.bandNoiseWav(
        centerHz: 4800,
        q: 9,
        transform: (sample, _) => sample * 0.5,
        random: Random(42),
      );
      expect(render(), equals(render()));
    });

    test('differs across seeds', () {
      final a = synth.bandNoiseWav(centerHz: 1050, q: 0.5, random: Random(1));
      final b = synth.bandNoiseWav(centerHz: 1050, q: 0.5, random: Random(2));
      expect(a, isNot(equals(b)));
    });

    test('supports longer buffers with a softened loop edge', () {
      final wav = synth.bandNoiseWav(
        centerHz: 920,
        q: 0.38,
        seconds: 5.5,
        loopFadeFraction: 0.035,
        random: Random(1),
      );

      expect(_u32(wav, 40), 8000 * 5.5 * 2, reason: '5.5 s of samples');
      expect(_peakAmplitude(wav), lessThanOrEqualTo(32767));
    });

    test('crossfade keeps the loop length and joins the seam continuously', () {
      final wav = synth.bandNoiseWav(
        centerHz: 1050,
        q: 0.5,
        seconds: 2,
        crossfadeSeconds: 0.25,
        random: Random(7),
      );

      // Output is still exactly the loop length; the extra tail is consumed.
      expect(_u32(wav, 40), 8000 * 2 * 2, reason: '2 s loop, tail folded in');

      // The wrap (last sample -> first sample) must be a small step, not the
      // large jump a raw noise seam produces.
      final data = ByteData.sublistView(wav, WavCodec.headerBytes);
      final first = data.getInt16(0, Endian.little);
      final last = data.getInt16(data.lengthInBytes - 2, Endian.little);
      final neighbour = data.getInt16(2, Endian.little);
      final seamStep = (first - last).abs();
      // The seam jump is on the order of an ordinary sample-to-sample step.
      expect(seamStep, lessThanOrEqualTo(4 * (neighbour - first).abs() + 200));
    });

    test(
      'brown noise is deterministic, non-clipping, and distinct from pink',
      () {
        Uint8List brown() => synth.bandNoiseWav(
          centerHz: 160,
          q: 0.32,
          color: NoiseColor.brown,
          random: Random(9),
        );

        final a = brown();
        final b = brown();
        final pink = synth.bandNoiseWav(
          centerHz: 160,
          q: 0.32,
          color: NoiseColor.pink,
          random: Random(9),
        );

        expect(a, equals(b));
        expect(_peakAmplitude(a), lessThanOrEqualTo(32767));
        expect(_peakAmplitude(a), greaterThan(0));
        expect(a, isNot(equals(pink)));
      },
    );
  });
}
