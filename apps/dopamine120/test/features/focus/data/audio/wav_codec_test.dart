import 'dart:typed_data';

import 'package:dopamine120/features/focus/data/datasources/audio/wav_codec.dart';
import 'package:flutter_test/flutter_test.dart';

int _u32(Uint8List b, int o) =>
    b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24);
int _u16(Uint8List b, int o) => b[o] | (b[o + 1] << 8);
String _ascii(Uint8List b, int o, int n) =>
    String.fromCharCodes(b.sublist(o, o + n));

void main() {
  group('WavCodec.encodeMono16', () {
    test('writes a canonical 44-byte mono 16-bit PCM header', () {
      final wav = WavCodec.encodeMono16(
        Float64List.fromList([0, 0, 0, 0]),
        sampleRate: 44100,
        gain: 1,
      );

      expect(_ascii(wav, 0, 4), 'RIFF');
      expect(_ascii(wav, 8, 4), 'WAVE');
      expect(_ascii(wav, 12, 4), 'fmt ');
      expect(_u16(wav, 20), 1, reason: 'PCM format');
      expect(_u16(wav, 22), 1, reason: 'mono');
      expect(_u32(wav, 24), 44100, reason: 'sample rate');
      expect(_u32(wav, 28), 44100 * 2, reason: 'byte rate');
      expect(_u16(wav, 32), 2, reason: 'block align');
      expect(_u16(wav, 34), 16, reason: 'bits per sample');
      expect(_ascii(wav, 36, 4), 'data');
      expect(_u32(wav, 40), 4 * 2, reason: 'data chunk size = samples * 2');
      expect(wav.length, WavCodec.headerBytes + 4 * 2);
    });

    test('applies gain and hard-clamps to the 16-bit range', () {
      final wav = WavCodec.encodeMono16(
        Float64List.fromList([1, -1, 0.5]),
        sampleRate: 8000,
        gain: 4, // pushes the first two samples well past full scale
      );
      final data = ByteData.sublistView(wav, WavCodec.headerBytes);

      expect(data.getInt16(0, Endian.little), 32767);
      expect(data.getInt16(2, Endian.little), -32767);
      expect(data.getInt16(4, Endian.little), (0.5 * 4).clamp(-1, 1) * 32767);
    });
  });

  group('WavCodec.pcmFromWav', () {
    test('strips exactly the 44-byte header', () {
      final wav = WavCodec.encodeMono16(
        Float64List.fromList([0.25, -0.25]),
        sampleRate: 8000,
        gain: 1,
      );
      final pcm = WavCodec.pcmFromWav(wav);

      expect(pcm.length, 2 * 2);
      expect(pcm, equals(wav.sublist(WavCodec.headerBytes)));
    });

    test('returns empty for a header-only buffer', () {
      expect(WavCodec.pcmFromWav(Uint8List(44)), isEmpty);
      expect(WavCodec.pcmFromWav(Uint8List(10)), isEmpty);
    });
  });
}
