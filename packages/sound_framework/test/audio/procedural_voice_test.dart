import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

import 'fake_audio_backend.dart';

void main() {
  late FakeAudioBackend backend;
  late ProceduralVoiceBuildContext context;

  setUp(() {
    backend = FakeAudioBackend();
    context = ProceduralVoiceBuildContext(
      backend: backend,
      player: LoopPlayer(backend, isWeb: false),
      synth: const SampleSynth(sampleRate: 8000),
      random: Random(7),
      emit: (_) {},
    );
  });

  test('build wires the created looping handles', () async {
    final voice = _TestVoice('tone', scale: 0.25);
    await voice.build(context);

    expect(voice.id, 'tone');
    expect(voice.handles, hasLength(1));
    expect(backend.loadedWaveforms, [WaveFormType.sin]);
  });

  test('applyLevel remembers and applies the voice level', () async {
    final voice = _TestVoice('tone', scale: 0.25);
    await voice.build(context);

    voice.applyLevel(backend, 0.8);
    expect(backend.volumeOf(voice.handles.single), closeTo(0.20, 1e-9));
  });

  test('setPaused toggles every handle of the voice', () async {
    final voice = _TestVoice('tone', scale: 0.25);
    await voice.build(context);

    voice.setPaused(backend, true);
    expect(voice.handles.every((h) => backend.pausedOf(h) == true), isTrue);

    voice.setPaused(backend, false);
    expect(voice.handles.every((h) => backend.pausedOf(h) == false), isTrue);
  });

  test(
    'retune crossfades old handles and applies the remembered level',
    () async {
      final voice = _TestVoice('tone', scale: 0.5);
      await voice.build(context);
      final oldHandle = voice.handles.single;

      voice.applyLevel(backend, 0.4);
      await voice.retune(context, const {'frequencyHz': 330}, backend);

      expect(voice.handles.single, isNot(oldHandle));
      expect(backend.fades.single.handleId, oldHandle.raw);
      expect(backend.volumeOf(voice.handles.single), closeTo(0.20, 1e-9));
      expect(backend.waveformFreq.values, contains(330));
    },
  );
}

class _TestVoice extends ProceduralVoice {
  _TestVoice(this.id, {required this.scale});

  @override
  final String id;

  final double scale;

  @override
  Future<List<LoopVoice>> create(
    ProceduralVoiceBuildContext context,
    Map<String, double> params,
  ) async {
    return [
      await context.player.oscillator(
        WaveFormType.sin,
        params['frequencyHz'] ?? 220,
      ),
    ];
  }

  @override
  void apply(AudioBackend backend, double level) {
    for (final handle in handles) {
      backend.setVolume(handle, level * scale);
    }
  }
}
