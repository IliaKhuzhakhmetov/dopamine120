import 'package:flutter/material.dart';
import 'package:platform_bridge/platform_bridge.dart';

void main() {
  runApp(const HarnessApp());
}

/// Dev harness for platform_bridge — exercises every method and falls back
/// to [PlatformBridgeFake] when the native side is unsupported.
class HarnessApp extends StatefulWidget {
  const HarnessApp({super.key});

  @override
  State<HarnessApp> createState() => _HarnessAppState();
}

class _HarnessAppState extends State<HarnessApp> {
  PlatformBridge _bridge = PlatformBridge();
  bool _usingFake = false;

  BridgeSupport? _support;
  PermissionResult? _blockingAccess;
  PermissionResult? _healthAccess;
  BlockSelection _selection = BlockSelection.empty;
  bool _blocking = false;
  HealthSnapshot? _snapshot;
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final support = await _bridge.support();
    // No native capabilities at all (desktop, web, missing plugin): use the
    // fake so the harness stays usable.
    if (!_usingFake &&
        !support.canList &&
        !support.canBlock &&
        !support.canReadHealth) {
      _say('native unsupported, switching to fake');
      _switchToFake();
      return;
    }
    setState(() => _support = support);
    _say('support: $support');
  }

  void _switchToFake() {
    setState(() {
      _bridge = PlatformBridge.fake();
      _usingFake = true;
      _selection = BlockSelection.empty;
      _blocking = false;
      _snapshot = null;
    });
    _init();
  }

  void _say(String message) {
    setState(() => _log.insert(0, message));
  }

  Future<void> _requestBlockingAccess() async {
    final result = await _bridge.requestBlockingAccess();
    setState(() => _blockingAccess = result);
    _say('blocking access: ${result.name}');
    if (result == PermissionResult.unsupported && !_usingFake) {
      _say('blocking unsupported here — try "Use fake"');
    }
  }

  Future<void> _pickApps() async {
    final selection = await _bridge.pickApps(current: _selection);
    setState(() => _selection = selection);
    final names = selection.apps
        .map((a) => a.name ?? '<opaque token>')
        .take(5)
        .join(', ');
    _say(
      'picked ${selection.apps.length} apps, '
      '${selection.categoryCount} categories'
      '${names.isEmpty ? '' : ' — $names…'}',
    );
  }

  Future<void> _toggleBlocking(bool enabled) async {
    await _bridge.setBlocking(_selection, enabled: enabled);
    final blocking = await _bridge.isBlocking();
    setState(() => _blocking = blocking);
    _say('setBlocking($enabled) -> isBlocking: $blocking');
  }

  Future<void> _readHealth() async {
    const metrics = {
      HealthMetric.sleep,
      HealthMetric.restingHeartRate,
      HealthMetric.hrv,
    };
    final access = await _bridge.requestHealthAccess(metrics);
    setState(() => _healthAccess = access);
    _say('health access: ${access.name}');
    final snapshot = await _bridge.readHealth(
      metrics,
      range: DateRange.lastNight(),
    );
    setState(() => _snapshot = snapshot);
    _say(
      'last night — sleep: ${_fmt(snapshot, HealthMetric.sleep)} min, '
      'resting HR: ${_fmt(snapshot, HealthMetric.restingHeartRate)} bpm, '
      'HRV: ${_fmt(snapshot, HealthMetric.hrv)} ms',
    );
  }

  String _fmt(HealthSnapshot snapshot, HealthMetric metric) {
    final value = snapshot.values[metric];
    return value == null ? '–' : value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('platform_bridge ${_usingFake ? '(fake)' : ''}'),
          actions: [
            if (!_usingFake)
              TextButton(
                onPressed: _switchToFake,
                child: const Text('Use fake'),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('support: ${_support ?? 'loading…'}'),
            const Divider(),
            FilledButton(
              onPressed: _requestBlockingAccess,
              child: Text(
                'Request blocking access'
                '${_blockingAccess == null ? '' : ' (${_blockingAccess!.name})'}',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _pickApps,
              child: Text('Pick apps (${_selection.apps.length} selected)'),
            ),
            SwitchListTile(
              title: const Text('Blocking enabled'),
              subtitle: Text('isBlocking: $_blocking'),
              value: _blocking,
              onChanged: _selection.isEmpty ? null : _toggleBlocking,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _readHealth,
              child: Text(
                'Read last-night health'
                '${_healthAccess == null ? '' : ' (${_healthAccess!.name})'}',
              ),
            ),
            if (_snapshot != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'sleep: ${_fmt(_snapshot!, HealthMetric.sleep)} min · '
                  'resting HR: ${_fmt(_snapshot!, HealthMetric.restingHeartRate)} bpm · '
                  'HRV: ${_fmt(_snapshot!, HealthMetric.hrv)} ms',
                ),
              ),
            const Divider(),
            for (final line in _log)
              Text(line, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
