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

  /// Builds a looping mono 16-bit WAV from a harmonic series.
  ///
  /// [harmonicGains] weights the fundamental ([fundamentalHz]) and its integer
  /// overtones. [seconds] controls the rendered buffer length; choosing
  /// [fundamentalHz] and [seconds] so every partial phase-aligns at the loop
  /// boundary keeps the tone click-free. [transform] can apply app-owned
  /// envelope or modulation. For a seam that can't be phase-aligned, prefer
  /// [crossfadeSeconds] (a click-free equal-power loop); [loopFadeFraction]
  /// instead fades to silence at the edges when a voice deliberately wants a
  /// pulsing body.
  Uint8List harmonicWav({
    required double fundamentalHz,
    required List<double> harmonicGains,
    double seconds = 1,
    SampleTransform? transform,
    double loopFadeFraction = 0,
    double crossfadeSeconds = 0,
  }) {
    assert(seconds > 0);
    final length = (sampleRate * seconds).round().clamp(1, 1 << 31).toInt();
    final crossfade = _crossfadeSamples(crossfadeSeconds, length);
    final raw = Float64List(length + crossfade);

    for (var i = 0; i < raw.length; i++) {
      final t = i / sampleRate;
      var sample = 0.0;
      for (var h = 0; h < harmonicGains.length; h++) {
        final freq = fundamentalHz * (h + 1);
        sample += harmonicGains[h] * math.sin(2 * math.pi * freq * t);
      }
      if (transform != null) sample = transform(sample, t);
      raw[i] = sample;
    }

    final samples = _finishLoop(raw, length, crossfade, loopFadeFraction);
    return WavCodec.encodeMono16(
      samples,
      sampleRate: sampleRate,
      gain: 0.85 / _peak(samples),
    );
  }

  /// Builds a looping mono 16-bit WAV of band-shaped noise.
  ///
  /// A state-variable filter centers the noise around [centerHz] with the given
  /// [q]. [color] chooses the source spectrum. [transform] can apply an
  /// app-owned envelope or modulation to each sample without baking those
  /// choices into the framework. [seconds] controls the rendered buffer length.
  /// Because noise has no phase-aligned seam, prefer [crossfadeSeconds] for a
  /// click-free loop: an extra tail is rendered past the loop point and
  /// equal-power crossfaded back into the head, so the seam becomes an interior,
  /// continuous point of the signal. [loopFadeFraction] instead fades to silence
  /// at the edges (a deliberate pulse). [random] is injected so tests stay
  /// deterministic.
  Uint8List bandNoiseWav({
    required double centerHz,
    required double q,
    required math.Random random,
    NoiseColor color = NoiseColor.white,
    double seconds = 2,
    SampleTransform? transform,
    double loopFadeFraction = 0,
    double crossfadeSeconds = 0,
  }) {
    assert(seconds > 0);
    final length = (sampleRate * seconds).round().clamp(1, 1 << 31).toInt();
    final crossfade = _crossfadeSamples(crossfadeSeconds, length);
    final raw = Float64List(length + crossfade);

    // State-variable bandpass over the noise source.
    final f = 2 * math.sin(math.pi * centerHz / sampleRate);
    final damping = (1 / q).clamp(0.0, 1.0);
    var low = 0.0;
    var band = 0.0;

    // Paul Kellet's economy pink-noise filter state.
    var b0 = 0.0;
    var b1 = 0.0;
    var b2 = 0.0;

    for (var i = 0; i < raw.length; i++) {
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
      raw[i] = sample;
    }

    final samples = _finishLoop(raw, length, crossfade, loopFadeFraction);
    return WavCodec.encodeMono16(
      samples,
      sampleRate: sampleRate,
      gain: 0.9 / _peak(samples),
    );
  }

  /// Crossfade length in samples for [seconds], clamped below half the loop so
  /// the fade region never overlaps itself.
  int _crossfadeSamples(double seconds, int length) {
    if (seconds <= 0) return 0;
    final samples = (sampleRate * seconds).round();
    return samples.clamp(1, length ~/ 2);
  }

  /// Turns the [length]+[crossfade] [raw] render into a seamless length-[length]
  /// loop. With a crossfade, the tail past the loop point is equal-power mixed
  /// back into the head so the seam is continuous; otherwise an optional
  /// fade-to-silence edge ([fadeFraction]) is applied.
  Float64List _finishLoop(
    Float64List raw,
    int length,
    int crossfade,
    double fadeFraction,
  ) {
    if (crossfade > 0) {
      final out = Float64List(length);
      for (var i = 0; i < length; i++) {
        if (i < crossfade) {
          final phase = (i / crossfade) * (math.pi / 2);
          // Equal-power: sin^2 + cos^2 == 1 keeps noise energy flat across the
          // seam, so there is no audible dip where head meets tail.
          out[i] = raw[i] * math.sin(phase) + raw[length + i] * math.cos(phase);
        } else {
          out[i] = raw[i];
        }
      }
      return out;
    }

    if (fadeFraction > 0) {
      final fraction = fadeFraction.clamp(0.0, 0.5);
      for (var i = 0; i < length; i++) {
        raw[i] *= _loopEdgeGain(i, length, fraction);
      }
    }
    return raw;
  }

  double _peak(Float64List samples) {
    var peak = 1e-9;
    for (final sample in samples) {
      final magnitude = sample.abs();
      if (magnitude > peak) peak = magnitude;
    }
    return peak;
  }

  double _loopEdgeGain(int index, int length, double fraction) {
    if (fraction <= 0) return 1;
    final fadeSamples = math.max(1, (length * fraction).round());
    if (index < fadeSamples) {
      final phase = index / fadeSamples;
      return _smoothstep(phase);
    }
    final tailStart = length - fadeSamples;
    if (index >= tailStart) {
      final phase = (length - index - 1) / fadeSamples;
      return _smoothstep(phase.clamp(0.0, 1.0));
    }
    return 1;
  }

  double _smoothstep(double value) {
    final x = value.clamp(0.0, 1.0);
    return x * x * (3 - 2 * x);
  }
}
