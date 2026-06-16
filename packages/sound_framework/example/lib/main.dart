import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sound_framework/sound_framework.dart';

import 'sample_voices.dart';

void main() {
  runApp(const SoundFrameworkExampleApp());
}

class SoundFrameworkExampleApp extends StatelessWidget {
  const SoundFrameworkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Framework',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2d6cdf),
          brightness: Brightness.light,
        ),
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.onDrag,
        ),
      ),
      home: const SoundFrameworkHome(),
    );
  }
}

class SoundFrameworkHome extends StatefulWidget {
  const SoundFrameworkHome({super.key});

  @override
  State<SoundFrameworkHome> createState() => _SoundFrameworkHomeState();
}

class _SoundFrameworkHomeState extends State<SoundFrameworkHome> {
  late final ProceduralSoundEngine _engine;
  late final StreamSubscription<ProceduralSoundEvent> _soundEvents;

  bool _running = false;
  double _profileBend = 0;
  SampleSpace _space = SampleSpace.room;
  ProceduralSoundEvent? _lastEvent;
  Object? _lastError;

  final Map<String, double> _levels = {
    for (final sound in sampleSounds) sound.id: 0,
  };

  @override
  void initState() {
    super.initState();
    _engine = ProceduralSoundEngine(
      voices: buildExampleVoices(),
      onBuildError: _recordError,
    );
    _soundEvents = _engine.soundEvents.listen((event) {
      if (mounted) setState(() => _lastEvent = event);
    });
  }

  @override
  void dispose() {
    _soundEvents.cancel();
    unawaited(_engine.dispose());
    super.dispose();
  }

  Future<void> _start() async {
    try {
      await _engine.start();
      await _applySpace(_space);
      for (final entry in _levels.entries) {
        await _engine.setSound(entry.key, entry.value);
      }
      await _engine.setProfileBend(_profileBend);
      if (mounted) {
        setState(() {
          _running = true;
          _lastError = null;
        });
      }
    } catch (error) {
      _recordError(error, StackTrace.current);
    }
  }

  Future<void> _stop() async {
    await _engine.stop();
    if (mounted) setState(() => _running = false);
  }

  Future<void> _applySpace(SampleSpace space) async {
    await _engine.applyProfile(space.profile);
  }

  void _recordError(Object error, StackTrace stackTrace) {
    if (mounted) setState(() => _lastError = error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Framework'),
        actions: [
          IconButton(
            tooltip: _running ? 'Stop' : 'Start',
            onPressed: _running ? _stop : _start,
            icon: Icon(_running ? Icons.stop : Icons.play_arrow),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<SampleSpace>(
            segments: [
              for (final space in SampleSpace.values)
                ButtonSegment(
                  value: space,
                  label: Text(space.label),
                  icon: Icon(space.icon),
                ),
            ],
            selected: {_space},
            onSelectionChanged: (selection) async {
              final next = selection.single;
              setState(() => _space = next);
              if (_running) await _applySpace(next);
            },
          ),
          const SizedBox(height: 18),
          _StatusPanel(
            running: _running,
            lastEvent: _lastEvent,
            lastError: _lastError,
          ),
          const SizedBox(height: 18),
          Text('Sounds', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final sound in sampleSounds)
            _SoundSlider(
              sound: sound,
              value: _levels[sound.id] ?? 0,
              onChanged: (value) async {
                setState(() => _levels[sound.id] = value);
                if (_running) await _engine.setSound(sound.id, value);
              },
            ),
          const SizedBox(height: 18),
          Text('Profile Bend', style: theme.textTheme.titleMedium),
          Slider(
            value: _profileBend,
            label: _profileBend.toStringAsFixed(2),
            onChanged: (value) async {
              setState(() => _profileBend = value);
              if (_running) await _engine.setProfileBend(value);
            },
          ),
        ],
      ),
    );
  }
}

class _SoundSlider extends StatelessWidget {
  const _SoundSlider({
    required this.sound,
    required this.value,
    required this.onChanged,
  });

  final SampleSound sound;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(message: sound.label, child: Icon(sound.icon)),
        const SizedBox(width: 12),
        SizedBox(width: 76, child: Text(sound.label)),
        Expanded(
          child: Slider(
            value: value,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.running,
    required this.lastEvent,
    required this.lastError,
  });

  final bool running;
  final ProceduralSoundEvent? lastEvent;
  final Object? lastError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = lastEvent;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  running ? Icons.graphic_eq : Icons.volume_off,
                  color: running
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  running ? 'Running' : 'Stopped',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event == null
                  ? 'Sound event: none'
                  : 'Sound event: ${event.soundId} ${event.frequencyHz?.toStringAsFixed(1) ?? '-'} Hz at ${event.intensity.toStringAsFixed(2)}',
            ),
            if (lastError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: $lastError',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum SampleSpace { room, hall, deep }

extension SampleSpaceX on SampleSpace {
  String get label => switch (this) {
    SampleSpace.room => 'Room',
    SampleSpace.hall => 'Hall',
    SampleSpace.deep => 'Deep',
  };

  IconData get icon => switch (this) {
    SampleSpace.room => Icons.crop_square,
    SampleSpace.hall => Icons.account_balance,
    SampleSpace.deep => Icons.water,
  };

  AcousticProfile get profile => switch (this) {
    SampleSpace.room => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 16000,
      resonance: 0.1,
      reverbWet: 0.07,
      roomSize: 0.4,
      delaySeconds: 0.30,
      delayDecay: 0,
      delayWet: 0,
      masterGain: 0.55,
    ),
    SampleSpace.hall => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 9000,
      resonance: 0.1,
      reverbWet: 0.55,
      roomSize: 0.9,
      delaySeconds: 0.34,
      delayDecay: 0.25,
      delayWet: 0.06,
      masterGain: 0.5,
    ),
    SampleSpace.deep => const AcousticProfile(
      filterShape: AcousticFilterShape.lowpass,
      cutoffHz: 680,
      resonance: 1.2,
      reverbWet: 0.2,
      roomSize: 0.6,
      delaySeconds: 0.30,
      delayDecay: 0,
      delayWet: 0,
      masterGain: 0.62,
    ),
  };
}

const sampleSounds = [
  SampleSound('drone', 'Drone', Icons.graphic_eq),
  SampleSound('rain', 'Rain', Icons.grain),
  SampleSound('pulse', 'Pulse', Icons.show_chart),
  SampleSound('bell', 'Bell', Icons.notifications_none),
  SampleSound('cicada', 'Cicada', Icons.blur_on),
];

class SampleSound {
  const SampleSound(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
}
