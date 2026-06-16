import 'dart:math' as math;
import 'dart:typed_data';

import 'wav_codec.dart';

/// Per-sample transform used while rendering a generated buffer.
typedef SampleTransform = double Function(double sample, double timeSeconds);

/// Source spectrum used by [SampleSynth.bandNoiseWav].
enum NoiseColor {
  /// Flat random source.
  white,

  /// Approximate 1/f source.
  pink,
}

/// Generates procedural sample buffers.
///
/// Pure DSP with no audio-engine dependency: given the same parameters (and, for
/// noise, the same seeded [math.Random]) it produces byte-identical WAVs, so the
/// synthesis is testable in isolation.
class SampleSynth {
  /// Creates a synth that renders at [sampleRate] Hz.
  const SampleSynth({this.sampleRate = 44100});

  /// Output sample rate in Hz.
  final int sampleRate;

  /// Builds a 1 s seamlessly looping mono 16-bit WAV from a harmonic series.
  ///
  /// [harmonicGains] weights the fundamental ([fundamentalHz]) and its integer
  /// overtones; choosing [fundamentalHz] as a whole number of Hz keeps every
  /// partial phase-aligned at the loop boundary so the tone is click-free.
  Uint8List harmonicWav({
    required double fundamentalHz,
    required List<double> harmonicGains,
  }) {
    const seconds = 1;
    final length = sampleRate * seconds;
    final samples = Float64List(length);
    var peak = 1e-9;

    for (var i = 0; i < length; i++) {
      final t = i / sampleRate;
      var sample = 0.0;
      for (var h = 0; h < harmonicGains.length; h++) {
        final freq = fundamentalHz * (h + 1);
        sample += harmonicGains[h] * math.sin(2 * math.pi * freq * t);
      }
      samples[i] = sample;
      final magnitude = sample.abs();
      if (magnitude > peak) peak = magnitude;
    }

    return WavCodec.encodeMono16(
      samples,
      sampleRate: sampleRate,
      gain: 0.85 / peak,
    );
  }

  /// Builds a ~2 s looping mono 16-bit WAV of band-shaped noise.
  ///
  /// A state-variable filter centers the noise around [centerHz] with the given
  /// [q]. [color] chooses the source spectrum. [transform] can apply an
  /// app-owned envelope or modulation to each sample without baking those
  /// choices into the framework. [random] is injected so tests stay
  /// deterministic.
  Uint8List bandNoiseWav({
    required double centerHz,
    required double q,
    required math.Random random,
    NoiseColor color = NoiseColor.white,
    SampleTransform? transform,
  }) {
    const seconds = 2;
    final length = sampleRate * seconds;
    final samples = Float64List(length);

    // State-variable bandpass over the noise source.
    final f = 2 * math.sin(math.pi * centerHz / sampleRate);
    final damping = (1 / q).clamp(0.0, 1.0);
    var low = 0.0;
    var band = 0.0;
    var peak = 1e-9;

    // Paul Kellet's economy pink-noise filter state.
    var b0 = 0.0;
    var b1 = 0.0;
    var b2 = 0.0;

    for (var i = 0; i < length; i++) {
      final white = random.nextDouble() * 2 - 1;
      double input;
      if (color == NoiseColor.pink) {
        b0 = 0.99765 * b0 + white * 0.0990460;
        b1 = 0.96300 * b1 + white * 0.2965164;
        b2 = 0.57000 * b2 + white * 1.0526913;
        input = (b0 + b1 + b2 + white * 0.1848) * 0.25;
      } else {
        input = white;
      }
      low += f * band;
      final high = input - low - damping * band;
      band += f * high;
      var sample = band;

      final t = i / sampleRate;
      if (transform != null) sample = transform(sample, t);

      samples[i] = sample;
      final magnitude = sample.abs();
      if (magnitude > peak) peak = magnitude;
    }

    return WavCodec.encodeMono16(
      samples,
      sampleRate: sampleRate,
      gain: 0.9 / peak,
    );
  }
}
