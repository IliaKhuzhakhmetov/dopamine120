import 'dart:math';

import 'package:dopamine120/features/focus/data/datasources/audio/ambient_voice.dart';
import 'package:dopamine120/features/focus/data/datasources/audio/loop_player.dart';
import 'package:dopamine120/features/focus/data/datasources/audio/sample_synth.dart';
import 'package:dopamine120/features/focus/domain/entities/sound_layer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_audio_backend.dart';

void main() {
  late FakeAudioBackend backend;
  late VoiceBuildContext context;

  setUp(() {
    backend = FakeAudioBackend();
    context = VoiceBuildContext(
      player: LoopPlayer(backend, isWeb: false),
      synth: const SampleSynth(sampleRate: 8000),
      random: Random(7),
    );
  });

  test('DroneVoice opens five oscillators and scales level by 0.15', () async {
    final voice = DroneVoice();
    await voice.build(context);

    expect(voice.layer, SoundLayer.drone);
    expect(voice.handles, hasLength(5));

    voice.applyLevel(backend, 1);
    for (final handle in voice.handles) {
      expect(backend.volumeOf(handle), closeTo(0.15, 1e-9));
    }
  });

  test('RainVoice scales level by 0.20', () async {
    final voice = RainVoice();
    await voice.build(context);

    voice.applyLevel(backend, 0.5);
    expect(backend.volumeOf(voice.handles.single), closeTo(0.10, 1e-9));
  });

  test('CicadaVoice scales level by 0.26', () async {
    final voice = CicadaVoice();
    await voice.build(context);

    voice.applyLevel(backend, 1);
    expect(backend.volumeOf(voice.handles.single), closeTo(0.26, 1e-9));
  });

  group('PulseVoice', () {
    test('oscillates around the level when audible', () async {
      final voice = PulseVoice();
      await voice.build(context);

      voice.applyLevel(backend, 1);
      final osc = backend.oscillations.single;
      expect(osc.from, closeTo(0.16, 1e-9));
      expect(osc.to, closeTo(0.46, 1e-9));
      expect(osc.period, const Duration(milliseconds: 1400));
    });

    test('hard-zeroes instead of oscillating when silent', () async {
      final voice = PulseVoice();
      await voice.build(context);

      voice.applyLevel(backend, 0);
      expect(backend.oscillations, isEmpty);
      expect(backend.volumeOf(voice.handles.single), 0);
    });
  });

  test('setPaused toggles every handle of the voice', () async {
    final voice = DroneVoice();
    await voice.build(context);

    voice.setPaused(backend, true);
    expect(voice.handles.every((h) => backend.pausedOf(h) == true), isTrue);

    voice.setPaused(backend, false);
    expect(voice.handles.every((h) => backend.pausedOf(h) == false), isTrue);
  });
}
