import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sound_framework/sound_framework.dart';

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
  late final StreamSubscription<BellStrike> _bellStrikes;

  bool _running = false;
  double _distortion = 0;
  SampleSpace _space = SampleSpace.room;
  BellStrike? _lastStrike;
  Object? _lastError;

  final Map<SoundLayer, double> _levels = {
    for (final layer in SoundLayer.values) layer: 0,
  };

  @override
  void initState() {
    super.initState();
    _engine = ProceduralSoundEngine(onBuildError: _recordError);
    _bellStrikes = _engine.bellStrikes.listen((strike) {
      if (mounted) setState(() => _lastStrike = strike);
    });
  }

  @override
  void dispose() {
    _bellStrikes.cancel();
    unawaited(_engine.dispose());
    super.dispose();
  }

  Future<void> _start() async {
    try {
      await _engine.start();
      await _applySpace(_space);
      for (final entry in _levels.entries) {
        await _engine.setLayer(entry.key, entry.value);
      }
      await _engine.setTemporalDistortion(_distortion);
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
    await _engine.applyTimbre(space.timbre);
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
            lastStrike: _lastStrike,
            lastError: _lastError,
          ),
          const SizedBox(height: 18),
          Text('Layers', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final layer in SoundLayer.values)
            _LayerSlider(
              layer: layer,
              value: _levels[layer] ?? 0,
              onChanged: (value) async {
                setState(() => _levels[layer] = value);
                if (_running) await _engine.setLayer(layer, value);
              },
            ),
          const SizedBox(height: 18),
          Text('Temporal Distortion', style: theme.textTheme.titleMedium),
          Slider(
            value: _distortion,
            label: _distortion.toStringAsFixed(2),
            onChanged: (value) async {
              setState(() => _distortion = value);
              if (_running) await _engine.setTemporalDistortion(value);
            },
          ),
        ],
      ),
    );
  }
}

class _LayerSlider extends StatelessWidget {
  const _LayerSlider({
    required this.layer,
    required this.value,
    required this.onChanged,
  });

  final SoundLayer layer;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(message: layer.label, child: Icon(layer.icon)),
        const SizedBox(width: 12),
        SizedBox(width: 76, child: Text(layer.label)),
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
    required this.lastStrike,
    required this.lastError,
  });

  final bool running;
  final BellStrike? lastStrike;
  final Object? lastError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strike = lastStrike;

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
              strike == null
                  ? 'Bell strike: none'
                  : 'Bell strike: ${strike.frequency.toStringAsFixed(1)} Hz at ${strike.intensity.toStringAsFixed(2)}',
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

  VoiceTimbre get timbre => switch (this) {
    SampleSpace.room => VoiceTimbre.standard,
    SampleSpace.hall => const VoiceTimbre(
      droneRatio: 0.5,
      rainCentreHz: 650,
      rainQ: 0.4,
      pulseHz: 41.2,
      cicadaCentreHz: 6200,
      bellTranspose: 2.0,
    ),
    SampleSpace.deep => const VoiceTimbre(
      droneRatio: 0.75,
      rainCentreHz: 400,
      rainQ: 0.35,
      pulseHz: 36.7,
      cicadaCentreHz: 1500,
      cicadaQ: 6,
      bellTranspose: 0.5,
    ),
  };
}

extension SoundLayerExampleX on SoundLayer {
  String get label => switch (this) {
    SoundLayer.drone => 'Drone',
    SoundLayer.rain => 'Rain',
    SoundLayer.pulse => 'Pulse',
    SoundLayer.bell => 'Bell',
    SoundLayer.cicada => 'Cicada',
  };

  IconData get icon => switch (this) {
    SoundLayer.drone => Icons.graphic_eq,
    SoundLayer.rain => Icons.grain,
    SoundLayer.pulse => Icons.show_chart,
    SoundLayer.bell => Icons.notifications_none,
    SoundLayer.cicada => Icons.blur_on,
  };
}
