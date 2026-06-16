import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';
import 'package:sound_framework/src/audio/wav_codec.dart';

import 'fake_audio_backend.dart';

Uint8List _wav(int samples) =>
    WavCodec.encodeMono16(Float64List(samples), sampleRate: 44100, gain: 1);

void main() {
  group('native', () {
    late FakeAudioBackend backend;
    late LoopPlayer player;

    setUp(() {
      backend = FakeAudioBackend();
      player = LoopPlayer(backend, isWeb: false);
    });

    test(
      'oscillator loads a tuned, looping, protected voice at zero volume',
      () async {
        final voice = await player.oscillator(WaveFormType.triangle, 110);

        expect(backend.loadedWaveforms, [WaveFormType.triangle]);
        expect(backend.waveformFreq.values, contains(110));
        final play = backend.plays.single;
        expect(play.looping, isTrue);
        expect(play.volume, 0, reason: 'native loops start silent');
        expect(backend.isKeptAlive(voice.handle), isTrue);
      },
    );

    test('noise loads in-memory and never opens a PCM stream', () async {
      await player.noise(_wav(8), pan: -0.25);

      expect(backend.loadedNoises, hasLength(1));
      expect(backend.pcmStreamCount, 0);
      expect(backend.plays.single.volume, 0);
      expect(backend.plays.single.pan, -0.25);
    });
  });

  group('web', () {
    late FakeAudioBackend backend;
    late LoopPlayer player;

    setUp(() {
      backend = FakeAudioBackend();
      player = LoopPlayer(backend, isWeb: true, unlockVolume: 0.0001);
    });

    test('noise streams PCM and starts at the unlock volume', () async {
      await player.noise(_wav(8));

      expect(backend.loadedNoises, isEmpty);
      expect(backend.pcmStreamCount, 1);
      expect(backend.pushedPcm.single.length, 8 * 2, reason: 'header stripped');
      expect(backend.plays.single.volume, 0.0001);
      expect(backend.plays.single.looping, isTrue);
    });

    test('oscillator starts at the unlock volume', () async {
      await player.oscillator(WaveFormType.sin, 55, pan: 0.2);
      expect(backend.plays.single.volume, 0.0001);
      expect(backend.plays.single.pan, 0.2);
    });
  });
}
