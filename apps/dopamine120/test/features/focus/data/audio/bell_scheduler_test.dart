import 'dart:math';

import 'package:dopamine120/features/focus/data/datasources/audio/bell_scheduler.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_audio_backend.dart';

/// Deterministic [Random] that replays scripted values.
class _ScriptedRandom implements Random {
  _ScriptedRandom(this.doubles);

  final List<double> doubles;
  int _cursor = 0;

  @override
  double nextDouble() => doubles[_cursor++ % doubles.length];

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}

const _tick = Duration(milliseconds: 430);

void main() {
  test('rings both bell voices on a tick when the probability passes', () {
    fakeAsync((async) {
      final backend = FakeAudioBackend();
      // 0.1 < level*0.6, so the ping fires; note index 0 is selected.
      final bell = BellScheduler(backend, random: _ScriptedRandom([0.1]));

      bell.build();
      async.flushMicrotasks();
      bell.level = 1;
      bell.start();

      async.elapse(_tick);

      expect(backend.plays, hasLength(2), reason: 'strike + shimmer');
      expect(backend.plays[0].volume, closeTo(0.15, 1e-9), reason: 'strike');
      expect(backend.plays[1].volume, closeTo(0.05, 1e-9), reason: 'shimmer');
      expect(backend.fades, hasLength(2));
      expect(backend.scheduledStops, hasLength(2));

      bell.dispose();
    });
  });

  test('stays silent when the level is zero', () {
    fakeAsync((async) {
      final backend = FakeAudioBackend();
      final bell = BellScheduler(backend, random: _ScriptedRandom([0.1]));

      bell.build();
      async.flushMicrotasks();
      bell.level = 0;
      bell.start();
      async.elapse(_tick * 3);

      expect(backend.plays, isEmpty);
      bell.dispose();
    });
  });

  test('skips a tick when the probability roll misses', () {
    fakeAsync((async) {
      final backend = FakeAudioBackend();
      // 0.9 >= level*0.6, so no ping.
      final bell = BellScheduler(backend, random: _ScriptedRandom([0.9]));

      bell.build();
      async.flushMicrotasks();
      bell.level = 1;
      bell.start();
      async.elapse(_tick);

      expect(backend.plays, isEmpty);
      bell.dispose();
    });
  });

  test('stop halts further pings', () {
    fakeAsync((async) {
      final backend = FakeAudioBackend();
      final bell = BellScheduler(backend, random: _ScriptedRandom([0.1]));

      bell.build();
      async.flushMicrotasks();
      bell.level = 1;
      bell.start();
      async.elapse(_tick);
      final after1 = backend.plays.length;

      bell.stop();
      async.elapse(_tick * 5);

      expect(backend.plays, hasLength(after1), reason: 'no pings after stop');
      bell.dispose();
    });
  });
}
