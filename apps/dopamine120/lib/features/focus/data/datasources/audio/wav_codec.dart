import 'dart:typed_data';

/// Encodes/decodes the tiny mono 16-bit PCM WAV files the synth loops.
///
/// Pure and engine-agnostic: every method is a deterministic byte transform, so
/// the whole codec is unit-testable without any audio backend.
class WavCodec {
  const WavCodec._();

  /// Size of a canonical PCM WAV header in bytes.
  static const int headerBytes = 44;

  /// Encodes [samples] (in `-1..1`) to a mono 16-bit PCM WAV at [sampleRate].
  ///
  /// Each sample is scaled by [gain] and hard-clamped to the 16-bit range, so
  /// callers normalize by passing `0.9 / peak` rather than pre-scaling.
  static Uint8List encodeMono16(
    Float64List samples, {
    required int sampleRate,
    required double gain,
  }) {
    final dataBytes = samples.length * 2;
    final bytes = ByteData(headerBytes + dataBytes);
    var offset = 0;

    void writeString(String value) {
      for (final unit in value.codeUnits) {
        bytes.setUint8(offset++, unit);
      }
    }

    writeString('RIFF');
    bytes.setUint32(offset, 36 + dataBytes, Endian.little);
    offset += 4;
    writeString('WAVE');
    writeString('fmt ');
    bytes.setUint32(offset, 16, Endian.little);
    offset += 4;
    bytes.setUint16(offset, 1, Endian.little); // PCM
    offset += 2;
    bytes.setUint16(offset, 1, Endian.little); // mono
    offset += 2;
    bytes.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    bytes.setUint32(offset, sampleRate * 2, Endian.little); // byte rate
    offset += 4;
    bytes.setUint16(offset, 2, Endian.little); // block align
    offset += 2;
    bytes.setUint16(offset, 16, Endian.little); // bits per sample
    offset += 2;
    writeString('data');
    bytes.setUint32(offset, dataBytes, Endian.little);
    offset += 4;

    for (final sample in samples) {
      final clamped = (sample * gain).clamp(-1.0, 1.0);
      bytes.setInt16(offset, (clamped * 32767).round(), Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Strips the [headerBytes] header, returning just the raw PCM payload.
  static Uint8List pcmFromWav(Uint8List wav) {
    if (wav.length <= headerBytes) return Uint8List(0);
    return Uint8List.sublistView(wav, headerBytes);
  }
}
