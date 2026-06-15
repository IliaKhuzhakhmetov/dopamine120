import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/context_ext.dart';

const double _bellPulseLifetime = 0.8;

/// Visual spaces from the focus-mode HTML reference.
enum DopFocusOrbDimension {
  /// Dry and near.
  room,

  /// Vast stone halo.
  cathedral,

  /// Muffled deep wobble.
  underwater,

  /// Long orbit echo.
  cosmos,

  /// Humid canopy.
  jungle,

  /// Wet slap-back ghosting.
  cave,
}

/// Labels and motion metadata for [DopFocusOrbDimension].
extension DopFocusOrbDimensionInfo on DopFocusOrbDimension {
  /// Display label used by the reference UI.
  String get label => switch (this) {
    DopFocusOrbDimension.room => 'room',
    DopFocusOrbDimension.cathedral => 'cathedral',
    DopFocusOrbDimension.underwater => 'underwater',
    DopFocusOrbDimension.cosmos => 'cosmos',
    DopFocusOrbDimension.jungle => 'jungle',
    DopFocusOrbDimension.cave => 'cave',
  };

  /// Short helper copy from the reference UI.
  String get description => switch (this) {
    DopFocusOrbDimension.room => 'dry & near',
    DopFocusOrbDimension.cathedral => 'vast stone',
    DopFocusOrbDimension.underwater => 'muffled deep',
    DopFocusOrbDimension.cosmos => 'long orbit echo',
    DopFocusOrbDimension.jungle => 'humid canopy',
    DopFocusOrbDimension.cave => 'wet slap-back',
  };

  _FocusOrbDimensionVisual get _visual => switch (this) {
    DopFocusOrbDimension.room => const _FocusOrbDimensionVisual(
      speed: 1,
      amplitude: 1,
    ),
    DopFocusOrbDimension.cathedral => const _FocusOrbDimensionVisual(
      speed: 0.6,
      amplitude: 1.5,
      halo: 1,
    ),
    DopFocusOrbDimension.underwater => const _FocusOrbDimensionVisual(
      speed: 0.5,
      amplitude: 1.4,
      wobble: 1,
      drift: 0.3,
    ),
    DopFocusOrbDimension.cosmos => const _FocusOrbDimensionVisual(
      speed: 1.05,
      amplitude: 1,
      orbit: 1,
      drift: 1,
    ),
    DopFocusOrbDimension.jungle => const _FocusOrbDimensionVisual(
      speed: 0.72,
      amplitude: 1.22,
      wobble: 0.72,
      drift: 0.18,
    ),
    DopFocusOrbDimension.cave => const _FocusOrbDimensionVisual(
      speed: 1,
      amplitude: 1,
      ghost: 1,
    ),
  };
}

/// Five normalized inputs that warp the focus orb.
class DopFocusOrbKnobs {
  /// Creates a set of normalized focus-orb knobs.
  const DopFocusOrbKnobs({
    this.drone = 0,
    this.rain = 0,
    this.pulse = 0,
    this.bell = 0,
    this.cicada = 0,
  });

  /// Thickens and enlarges the loop.
  final double drone;

  /// Adds noisy edge vibration.
  final double rain;

  /// Adds breathing pulse.
  final double pulse;

  /// Adds lobes and short-lived ping dots.
  final double bell;

  /// Adds the strange high-frequency edge chatter.
  final double cicada;

  /// Returns a copy with changed knob values.
  DopFocusOrbKnobs copyWith({
    double? drone,
    double? rain,
    double? pulse,
    double? bell,
    double? cicada,
  }) {
    return DopFocusOrbKnobs(
      drone: drone ?? this.drone,
      rain: rain ?? this.rain,
      pulse: pulse ?? this.pulse,
      bell: bell ?? this.bell,
      cicada: cicada ?? this.cicada,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DopFocusOrbKnobs &&
        other.drone == drone &&
        other.rain == rain &&
        other.pulse == pulse &&
        other.bell == bell &&
        other.cicada == cicada;
  }

  @override
  int get hashCode => Object.hash(drone, rain, pulse, bell, cicada);
}

/// Event controller for synchronizing external focus-orb moments.
class DopFocusOrbController extends ChangeNotifier {
  int _bellStrikeSequence = 0;
  double _bellStrikeIntensity = 0;

  /// Monotonic id of the latest bell strike.
  int get bellStrikeSequence => _bellStrikeSequence;

  /// Normalized intensity of the latest bell strike.
  double get bellStrikeIntensity => _bellStrikeIntensity;

  /// Emits a visual bell particle burst from a real bell chime.
  void strikeBell({double intensity = 1}) {
    _bellStrikeIntensity = intensity.clamp(0.0, 1.0).toDouble();
    _bellStrikeSequence++;
    notifyListeners();
  }
}

/// Animated focus-mode orb recreated from the HTML canvas reference.
class DopFocusOrb extends StatefulWidget {
  const DopFocusOrb({
    super.key,
    this.size = 172,
    this.knobs = const DopFocusOrbKnobs(),
    this.controller,
    this.dimension = DopFocusOrbDimension.room,
    this.color,
    this.animate = true,
    this.distortionOnPress = true,
    this.onDistortionChanged,
    this.seed = 120,
  }) : assert(size > 0);

  /// Preferred square size.
  final double size;

  /// Normalized controls that bend the loop and warp the orb.
  final DopFocusOrbKnobs knobs;

  /// Optional event controller for externally synchronized orb particles.
  final DopFocusOrbController? controller;

  /// Visual dimension that changes motion space.
  final DopFocusOrbDimension dimension;

  /// Stroke/fill color. Defaults to `context.colors.ink`.
  final Color? color;

  /// Whether the orb should tick. Platform reduced-motion settings still win.
  final bool animate;

  /// Whether pressing the orb should bend it until the pointer is released.
  final bool distortionOnPress;

  /// Called with `1` on press and `0` on release/cancel.
  final ValueChanged<double>? onDistortionChanged;

  /// Seed used for deterministic rain and bell pings.
  final int seed;

  @override
  State<DopFocusOrb> createState() => _DopFocusOrbState();
}

class _DopFocusOrbState extends State<DopFocusOrb>
    with TickerProviderStateMixin {
  late final AnimationController _ticker;
  late final AnimationController _distortionTicker;
  final List<_OrbBellPulse> _bellPulses = [];
  bool _distorting = false;
  int _observedBellStrikeSequence = 0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this);
    _distortionTicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _attachController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant DopFocusOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleBellStrike);
      _bellPulses.clear();
      _observedBellStrikeSequence = widget.controller?.bellStrikeSequence ?? 0;
      _attachController();
    }
    if (oldWidget.animate != widget.animate) _syncTicker();
    if (oldWidget.distortionOnPress && !widget.distortionOnPress) {
      _setDistorting(false);
    }
  }

  @override
  void dispose() {
    if (_distorting) widget.onDistortionChanged?.call(0);
    widget.controller?.removeListener(_handleBellStrike);
    _distortionTicker.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.colors.ink;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setDistorting(true),
      onPointerUp: (_) => _setDistorting(false),
      onPointerCancel: (_) => _setDistorting(false),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: widget.size,
          child: RepaintBoundary(
            child: _DopFocusOrbRenderWidget(
              ticker: _ticker,
              distortionTicker: _distortionTicker,
              preferredSize: widget.size,
              knobs: widget.knobs,
              bellPulses: List<_OrbBellPulse>.unmodifiable(_bellPulses),
              syncBellPulses: widget.controller != null,
              dimension: widget.dimension,
              color: color,
              seed: widget.seed,
            ),
          ),
        ),
      ),
    );
  }

  void _syncTicker() {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldAnimate = widget.animate && !disableAnimations;
    if (shouldAnimate) {
      if (!_ticker.isAnimating) {
        _ticker.repeat(period: const Duration(seconds: 1));
      }
    } else {
      _ticker.stop();
    }
  }

  void _attachController() {
    final controller = widget.controller;
    if (controller == null) return;
    _observedBellStrikeSequence = controller.bellStrikeSequence;
    controller.addListener(_handleBellStrike);
  }

  void _handleBellStrike() {
    final controller = widget.controller;
    if (controller == null) return;
    final sequence = controller.bellStrikeSequence;
    if (sequence == _observedBellStrikeSequence) return;
    _observedBellStrikeSequence = sequence;
    final t = _elapsedSeconds;
    setState(() {
      _pruneBellPulses(t);
      _bellPulses.add(
        _OrbBellPulse(
          start: t,
          sequence: sequence,
          intensity: controller.bellStrikeIntensity,
        ),
      );
    });
  }

  double get _elapsedSeconds {
    final elapsed = _ticker.lastElapsedDuration;
    return elapsed == null ? 0.0 : elapsed.inMicroseconds / 1000000;
  }

  void _pruneBellPulses(double t) {
    _bellPulses.removeWhere((pulse) => t - pulse.start > _bellPulseLifetime);
  }

  void _setDistorting(bool value) {
    if (!widget.distortionOnPress && value) return;
    if (value == _distorting) return;
    _distorting = value;
    widget.onDistortionChanged?.call(value ? 1 : 0);

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _distortionTicker.value = value ? 1 : 0;
    } else if (value) {
      _distortionTicker.forward();
    } else {
      _distortionTicker.reverse();
    }
  }
}

class _DopFocusOrbRenderWidget extends LeafRenderObjectWidget {
  const _DopFocusOrbRenderWidget({
    required this.ticker,
    required this.distortionTicker,
    required this.preferredSize,
    required this.knobs,
    required this.bellPulses,
    required this.syncBellPulses,
    required this.dimension,
    required this.color,
    required this.seed,
  });

  final AnimationController ticker;
  final Animation<double> distortionTicker;
  final double preferredSize;
  final DopFocusOrbKnobs knobs;
  final List<_OrbBellPulse> bellPulses;
  final bool syncBellPulses;
  final DopFocusOrbDimension dimension;
  final Color color;
  final int seed;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDopFocusOrb(
      ticker: ticker,
      distortionTicker: distortionTicker,
      preferredSize: preferredSize,
      knobs: knobs,
      bellPulses: bellPulses,
      syncBellPulses: syncBellPulses,
      dimension: dimension,
      color: color,
      seed: seed,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderDopFocusOrb renderObject,
  ) {
    renderObject
      ..ticker = ticker
      ..distortionTicker = distortionTicker
      ..preferredSize = preferredSize
      ..knobs = knobs
      ..bellPulses = bellPulses
      ..syncBellPulses = syncBellPulses
      ..dimension = dimension
      ..color = color
      ..seed = seed;
  }
}

class _RenderDopFocusOrb extends RenderBox {
  _RenderDopFocusOrb({
    required AnimationController ticker,
    required Animation<double> distortionTicker,
    required double preferredSize,
    required DopFocusOrbKnobs knobs,
    required List<_OrbBellPulse> bellPulses,
    required bool syncBellPulses,
    required DopFocusOrbDimension dimension,
    required Color color,
    required int seed,
  }) : _ticker = ticker,
       _distortionTicker = distortionTicker,
       _preferredSize = preferredSize,
       _knobs = knobs,
       _bellPulses = bellPulses,
       _syncBellPulses = syncBellPulses,
       _dimension = dimension,
       _color = color,
       _seed = seed;

  final Path _blobPath = Path();
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  final Paint _fillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  AnimationController _ticker;
  Animation<double> _distortionTicker;
  double _preferredSize;
  DopFocusOrbKnobs _knobs;
  List<_OrbBellPulse> _bellPulses;
  bool _syncBellPulses;
  DopFocusOrbDimension _dimension;
  Color _color;
  int _seed;

  AnimationController get ticker => _ticker;
  set ticker(AnimationController value) {
    if (identical(value, _ticker)) return;
    if (attached) _ticker.removeListener(markNeedsPaint);
    _ticker = value;
    if (attached) _ticker.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  Animation<double> get distortionTicker => _distortionTicker;
  set distortionTicker(Animation<double> value) {
    if (identical(value, _distortionTicker)) return;
    if (attached) _distortionTicker.removeListener(markNeedsPaint);
    _distortionTicker = value;
    if (attached) _distortionTicker.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  double get preferredSize => _preferredSize;
  set preferredSize(double value) {
    if (value == _preferredSize) return;
    _preferredSize = value;
    markNeedsLayout();
  }

  DopFocusOrbKnobs get knobs => _knobs;
  set knobs(DopFocusOrbKnobs value) {
    if (value == _knobs) return;
    _knobs = value;
    markNeedsPaint();
  }

  List<_OrbBellPulse> get bellPulses => _bellPulses;
  set bellPulses(List<_OrbBellPulse> value) {
    if (identical(value, _bellPulses)) return;
    _bellPulses = value;
    markNeedsPaint();
  }

  bool get syncBellPulses => _syncBellPulses;
  set syncBellPulses(bool value) {
    if (value == _syncBellPulses) return;
    _syncBellPulses = value;
    markNeedsPaint();
  }

  DopFocusOrbDimension get dimension => _dimension;
  set dimension(DopFocusOrbDimension value) {
    if (value == _dimension) return;
    _dimension = value;
    markNeedsPaint();
  }

  Color get color => _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  int get seed => _seed;
  set seed(int value) {
    if (value == _seed) return;
    _seed = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _ticker.addListener(markNeedsPaint);
    _distortionTicker.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _distortionTicker.removeListener(markNeedsPaint);
    _ticker.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(Size.square(_preferredSize));
  }

  @override
  void performResize() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final side = math.min(size.width, size.height);
    if (side <= 0) return;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final elapsed = _ticker.lastElapsedDuration;
    final t = elapsed == null ? 0.0 : elapsed.inMicroseconds / 1000000;
    final frame = (t * 60).floor();
    final distortion = _distortionLevel;
    final visual = _dimension._visual;
    final unit = _UnitKnobs.from(_knobs);
    var center = Offset(size.width / 2, size.height / 2);
    final radius = side * 0.26 * (1 + unit.drone * 0.22);

    if (visual.drift > 0) {
      center += Offset(
        math.sin(t * 0.5) * side * 0.04 * visual.drift,
        math.cos(t * 0.37) * side * 0.035 * visual.drift,
      );
    }

    if (distortion > 0) {
      center += Offset(
        math.sin(t * 4.1) * side * 0.012 * distortion,
        math.cos(t * 3.2) * side * 0.01 * distortion,
      );
    }

    if (visual.halo > 0) _paintHalo(canvas, center, radius, side, t);

    if (visual.ghost > 0) {
      final ghostKnobs = unit.withoutRain();
      _paintBlob(
        canvas,
        center,
        radius * 1.16,
        t - 0.34,
        ghostKnobs,
        visual,
        alpha: 0.12,
        strokeWidth: 1,
        frame: frame,
        distortion: 0,
      );
      _paintBlob(
        canvas,
        center,
        radius * 1.08,
        t - 0.17,
        ghostKnobs,
        visual,
        alpha: 0.2,
        strokeWidth: 1,
        frame: frame,
        distortion: 0,
      );
    }

    final breath = _paintBlob(
      canvas,
      center,
      radius,
      t,
      unit,
      visual,
      alpha: 0.88,
      strokeWidth: 1.5 + unit.drone * 3.5,
      frame: frame,
      distortion: distortion,
    );

    final coreRadius = math.max(
      2.0,
      side * 0.05 * (1 + unit.drone * 1.8) + breath * side * 0.08,
    );
    _fillPaint.color = _color;
    canvas.drawCircle(center, coreRadius, _fillPaint);

    if (visual.orbit > 0) _paintOrbit(canvas, center, radius, t);
    if (_syncBellPulses) {
      _paintSyncedPings(canvas, center, radius, t);
    } else if (unit.bell > 0) {
      _paintPings(canvas, center, radius, t, unit.bell);
    }

    canvas.restore();
  }

  double _paintBlob(
    Canvas canvas,
    Offset center,
    double baseRadius,
    double t,
    _UnitKnobs knobs,
    _FocusOrbDimensionVisual visual, {
    required double alpha,
    required double strokeWidth,
    required int frame,
    required double distortion,
  }) {
    const points = 150;
    final breath =
        math.sin(t * (0.5 + knobs.pulse * 3) * visual.speed) *
        (0.05 + knobs.pulse * 0.16) *
        visual.amplitude;
    final lobes = 2 + (knobs.bell * 6).round();

    _blobPath.reset();
    for (var i = 0; i <= points; i++) {
      final theta = i / points * math.pi * 2;
      var deform =
          knobs.bell * 0.16 * math.cos(lobes * theta) +
          knobs.cicada * 0.05 * math.sin(17 * theta + t * 9) +
          knobs.rain * (_hashUnit(i + frame * 17, _seed, 7) - 0.5) * 0.07;

      if (distortion > 0) {
        deform +=
            distortion *
            (0.12 * math.sin(3 * theta + t * 2.3) +
                0.08 * math.cos(6 * theta - t * 1.7) +
                0.035 * math.sin(11 * theta + t * 5.1));
      }

      if (visual.wobble > 0) {
        deform +=
            visual.wobble *
            (0.11 * math.sin(3 * theta + t * 0.8) +
                0.07 * math.sin(2 * theta - t * 0.5));
      }

      final r = baseRadius * (1 + breath + deform);
      final point = Offset(
        center.dx + math.cos(theta) * r,
        center.dy + math.sin(theta) * r,
      );
      if (i == 0) {
        _blobPath.moveTo(point.dx, point.dy);
      } else {
        _blobPath.lineTo(point.dx, point.dy);
      }
    }

    _blobPath.close();
    _strokePaint
      ..color = _color.withValues(alpha: alpha)
      ..strokeWidth = strokeWidth;
    canvas.drawPath(_blobPath, _strokePaint);
    return breath;
  }

  double get _distortionLevel =>
      Curves.easeOutCubic.transform(_distortionTicker.value);

  void _paintHalo(
    Canvas canvas,
    Offset center,
    double radius,
    double side,
    double t,
  ) {
    const interval = 0.8;
    const lifetime = 1.35;
    final first = ((t - lifetime) / interval).floor();
    final last = (t / interval).floor();

    for (var i = first; i <= last; i++) {
      final age = t - i * interval;
      if (age < 0 || age > lifetime) continue;
      final life = 1 - age / lifetime;
      _strokePaint
        ..color = _color.withValues(alpha: life * 0.32)
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius + age * side * 0.72, _strokePaint);
    }
  }

  void _paintOrbit(Canvas canvas, Offset center, double radius, double t) {
    final orbitRadius = radius * 2.2;
    _strokePaint
      ..color = _color.withValues(alpha: 0.16)
      ..strokeWidth = 1;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: orbitRadius * 2,
        height: orbitRadius,
      ),
      _strokePaint,
    );
    canvas.restore();

    _fillPaint.color = _color;
    _paintOrbitDot(canvas, center, radius * 1.7, t, 1, 0, 1);
    _paintOrbitDot(canvas, center, radius * 2, t, -0.7, 2, 0.6);
    _paintOrbitDot(canvas, center, radius * 1.95, t, 1.4, 4, 1);
  }

  void _paintOrbitDot(
    Canvas canvas,
    Offset center,
    double radius,
    double t,
    double speed,
    double phase,
    double yScale,
  ) {
    final angle = t * speed + phase;
    canvas.drawCircle(
      Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius * yScale,
      ),
      2.4,
      _fillPaint,
    );
  }

  void _paintPings(
    Canvas canvas,
    Offset center,
    double radius,
    double t,
    double bell,
  ) {
    const interval = 0.43;
    const lifetime = 0.8;
    final first = ((t - lifetime) / interval).floor();
    final last = (t / interval).floor();

    for (var i = first; i <= last; i++) {
      final age = t - i * interval;
      if (age < 0 || age > lifetime) continue;
      if (_hashUnit(i, _seed, 13) >= bell * 0.6) continue;

      final life = 1 - age / lifetime;
      final angle = _hashUnit(i, _seed, 29) * math.pi * 2;
      final pingRadius = radius * (1.15 + (1 - life) * 0.9);
      _fillPaint.color = _color.withValues(alpha: life * 0.8);
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * pingRadius,
          center.dy + math.sin(angle) * pingRadius,
        ),
        2 + (1 - life) * 3,
        _fillPaint,
      );
    }
  }

  void _paintSyncedPings(
    Canvas canvas,
    Offset center,
    double radius,
    double t,
  ) {
    for (final pulse in _bellPulses) {
      final age = t - pulse.start;
      if (age < 0 || age > _bellPulseLifetime) continue;

      final life = 1 - age / _bellPulseLifetime;
      final angle = _hashUnit(pulse.sequence, _seed, 29) * math.pi * 2;
      final pingRadius =
          radius * (1.15 + (1 - life) * (0.55 + pulse.intensity * 0.45));
      _fillPaint.color = _color.withValues(
        alpha: life * (0.35 + pulse.intensity * 0.45),
      );
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * pingRadius,
          center.dy + math.sin(angle) * pingRadius,
        ),
        2 + (1 - life) * (2 + pulse.intensity * 3),
        _fillPaint,
      );
    }
  }

  double _hashUnit(int a, int b, int c) {
    final value = math.sin(a * 12.9898 + b * 78.233 + c * 37.719) * 43758.5453;
    return value - value.floorToDouble();
  }
}

class _OrbBellPulse {
  const _OrbBellPulse({
    required this.start,
    required this.sequence,
    required this.intensity,
  });

  final double start;
  final int sequence;
  final double intensity;
}

class _UnitKnobs {
  const _UnitKnobs({
    required this.drone,
    required this.rain,
    required this.pulse,
    required this.bell,
    required this.cicada,
  });

  factory _UnitKnobs.from(DopFocusOrbKnobs knobs) {
    return _UnitKnobs(
      drone: _unit(knobs.drone),
      rain: _unit(knobs.rain),
      pulse: _unit(knobs.pulse),
      bell: _unit(knobs.bell),
      cicada: _unit(knobs.cicada),
    );
  }

  final double drone;
  final double rain;
  final double pulse;
  final double bell;
  final double cicada;

  _UnitKnobs withoutRain() {
    return _UnitKnobs(
      drone: drone,
      rain: 0,
      pulse: pulse,
      bell: bell,
      cicada: cicada,
    );
  }
}

class _FocusOrbDimensionVisual {
  const _FocusOrbDimensionVisual({
    required this.speed,
    required this.amplitude,
    this.wobble = 0,
    this.halo = 0,
    this.orbit = 0,
    this.ghost = 0,
    this.drift = 0,
  });

  final double speed;
  final double amplitude;
  final double wobble;
  final double halo;
  final double orbit;
  final double ghost;
  final double drift;
}

double _unit(double value) => value.clamp(0, 1).toDouble();
