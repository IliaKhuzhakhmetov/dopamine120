import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

import 'fake_audio_backend.dart';

void main() {
  const loopAsset = 'assets/sound/loop.wav';
  const hitAsset = 'assets/sound/hit.wav';

  late FakeAudioBackend backend;
  late SoundEngine engine;

  SceneConfig scene() => const SceneConfig(
    id: 'test',
    buses: [BusConfig(id: 'main', volume: 0.5)],
    sounds: [
      SceneSoundConfig(
        id: 'bed',
        type: SceneSoundType.loop,
        busId: 'main',
        assetKey: loopAsset,
        volume: 0.25,
      ),
      SceneSoundConfig(
        id: 'hit',
        type: SceneSoundType.randomOneShot,
        busId: 'main',
        assetKey: hitAsset,
        minDelay: Duration(milliseconds: 100),
        maxDelay: Duration(milliseconds: 100),
      ),
    ],
    knobs: [
      KnobConfig(
        id: 'bed',
        mappings: [
          SoundControlMapping(
            target: SoundMappingTarget.soundVolume,
            soundId: 'bed',
            min: 0,
            max: 0.8,
          ),
        ],
      ),
    ],
    filters: [
      FilterConfig(
        id: 'dream',
        mappings: [
          SoundControlMapping(
            target: SoundMappingTarget.busVolume,
            busId: 'main',
            min: 0.2,
            max: 1,
          ),
        ],
      ),
    ],
  );

  setUp(() {
    backend = FakeAudioBackend();
    engine = SoundEngine(
      registry: SceneRegistry(
        scenes: [scene()],
        soundPacks: const [
          SoundPackConfig(
            id: 'ui',
            sounds: [TriggerSoundConfig(id: 'ui.hit', assetKey: hitAsset)],
          ),
        ],
      ),
      backend: backend,
    );
  });

  test('initializes once, preloads, starts, and stops a scene', () async {
    await engine.init();
    await engine.init();
    await engine.preloadScene('test');
    await engine.startScene('test');

    expect(backend.initCount, 1);
    expect(backend.loadedAssets, [loopAsset, hitAsset]);
    expect(backend.createdBuses, ['main']);
    expect(engine.currentState.preloadedSceneIds, contains('test'));
    expect(engine.currentState.activeSceneId, 'test');
    expect(backend.plays.first.looping, isTrue);

    await engine.stopScene(fadeOut: const Duration(milliseconds: 250));

    expect(engine.currentState.activeSceneId, isNull);
    expect(backend.stoppedVoices, isNotEmpty);
    expect(backend.fades.first.time, const Duration(milliseconds: 250));
  });

  test('command queue preserves start stop start order', () async {
    final first = engine.startScene('test');
    final second = engine.stopScene();
    final third = engine.startScene('test');

    await Future.wait([first, second, third]);

    expect(engine.currentState.activeSceneId, 'test');
    expect(backend.createdBuses, ['main', 'main']);
    expect(backend.stoppedVoices, isNotEmpty);
  });

  test('setKnob and setFilter apply configured mappings', () async {
    await engine.startScene('test');
    await engine.setKnob('bed', 0.5);
    await engine.setFilter('dream', 0.5);

    expect(backend.volumes[backend.plays.first.handleId], 0.4);
    expect(backend.busVolumes[0], closeTo(0.6, 0.0001));
    expect(engine.currentState.knobs['bed'], 0.5);
    expect(engine.currentState.filters['dream'], 0.5);
  });

  test('decibel gain mappings resolve to linear backend volume', () {
    const mapping = SoundControlMapping(
      target: SoundMappingTarget.soundVolume,
      soundId: 'bed',
      min: -121,
      max: 0,
      scale: SoundMappingScale.decibelGain,
    );

    expect(mapping.resolve(1), 1);
    expect(mapping.resolve(0), 0);
    expect(mapping.resolve(100 / 121), closeTo(0.089125, 0.000001));
  });

  test('trigger reuses cached asset and records state errors', () async {
    await engine.trigger('ui.hit');
    await engine.trigger('ui.hit');

    expect(backend.loadedAssets, [hitAsset]);
    expect(backend.plays.length, 2);

    await expectLater(engine.trigger('missing'), throwsArgumentError);
    expect(engine.currentState.errors, hasLength(1));
  });

  test('asset cache releases retained sources on dispose', () async {
    await engine.startScene('test');
    await engine.dispose();

    expect(backend.disposedSources, containsAll(<int>[0, 1]));
    expect(backend.disposeCount, 1);
  });

  test('random one-shot schedules within bounds and cancels on stop', () {
    fakeAsync((async) {
      final fakeBackend = FakeAudioBackend();
      final fakeEngine = SoundEngine(
        registry: SceneRegistry(scenes: [scene()]),
        backend: fakeBackend,
      );

      fakeEngine.startScene('test');
      async.flushMicrotasks();
      async.flushMicrotasks();
      async.flushMicrotasks();

      final before = fakeBackend.plays.length;
      expect(before, 1);
      async.elapse(const Duration(milliseconds: 100));
      async.flushMicrotasks();
      async.flushMicrotasks();

      expect(fakeBackend.plays.length, before + 1);

      fakeEngine.stopScene();
      async.flushMicrotasks();
      final stoppedAt = fakeBackend.plays.length;
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();

      expect(fakeBackend.plays.length, stoppedAt);
    });
  });
}
