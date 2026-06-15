import 'dart:typed_data';

import 'package:dopamine120/features/focus/data/datasources/audio/loop_player.dart';
import 'package:dopamine120/features/focus/data/datasources/audio/wav_codec.dart';
import 'package:flutter_soloud/flutter_soloud.dart' show WaveForm;
import 'package:flutter_test/flutter_test.dart';

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
        final voice = await player.oscillator(WaveForm.triangle, 110);

        expect(backend.loadedWaveforms, [WaveForm.triangle]);
        expect(backend.waveformFreq.values, contains(110));
        final play = backend.plays.single;
        expect(play.looping, isTrue);
        expect(play.volume, 0, reason: 'native loops start silent');
        expect(backend.isKeptAlive(voice.handle), isTrue);
      },
    );

    test('noise loads in-memory and never opens a PCM stream', () async {
      await player.noise(_wav(8));

      expect(backend.loadedNoises, hasLength(1));
      expect(backend.pcmStreamCount, 0);
      expect(backend.plays.single.volume, 0);
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
      await player.oscillator(WaveForm.sin, 55);
      expect(backend.plays.single.volume, 0.0001);
    });
  });
}
