import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/context_ext.dart';

/// Below this pointer pressure the touch is treated as released.
const double _kSettleEps = 0.01;

/// Below this max particle speed (logical px/s) the orb is treated as settled.
const double _kEnergyEps = 6;

/// Quiet particle orb for the deprivation screen.
///
/// Tapping, dragging, or hovering over the orb repels and swirls the nearby
/// particles, which then spring back to their resting orbit.
class DopDeprivationOrb extends StatefulWidget {
  const DopDeprivationOrb({
    super.key,
    this.size = 360,
    this.particleCount = 360,
    this.particleSizeMin = 1.2,
    this.particleSizeMax = 3.8,
    this.opacity = 0.3,
    this.breathingSpeed = 0.45,
    this.rotationSpeed = 0.05,
    this.drift = 5,
    this.spread = 0.3,
    this.color,
    this.animate = true,
    this.seed = 120,
    this.interactive = true,
    this.repelRadius = 140,
    this.repelStrength = 1850,
    this.swirlStrength = 620,
    this.spring = 22,
    this.damping = 0.84,
    this.glowColor,
  }) : assert(size > 0),
       assert(particleCount > 0),
       assert(particleSizeMin > 0),
       assert(particleSizeMax >= particleSizeMin),
       assert(opacity >= 0),
       assert(spread > 0),
       assert(repelRadius > 0),
       assert(repelStrength >= 0),
       assert(swirlStrength >= 0),
       assert(spring > 0),
       assert(damping > 0 && damping <= 1);

  /// Preferred square size.
  final double size;

  /// Number of cross particles.
  final int particleCount;

  /// Smallest cross arm length.
  final double particleSizeMin;

  /// Largest cross arm length.
  final double particleSizeMax;

  /// Base particle opacity.
  final double opacity;

  /// Breathing pulse speed.
  final double breathingSpeed;

  /// Slow orbital rotation speed.
  final double rotationSpeed;

  /// Inner-particle drift in logical pixels.
  final double drift;

  /// Radius spread relative to the shortest side.
  final double spread;

  /// Particle color. Defaults to `context.colors.ink`.
  final Color? color;

  /// Whether the orb should tick. Platform reduced-motion settings still win.
  final bool animate;

  /// Seed used for deterministic particle placement.
  final int seed;

  /// Whether pointer touches repel and swirl the particles.
  final bool interactive;

  /// Pointer influence radius in logical pixels.
  final double repelRadius;

  /// Outward push applied to particles inside [repelRadius].
  final double repelStrength;

  /// Tangential swirl applied to particles inside [repelRadius].
  final double swirlStrength;

  /// Stiffness of the pull back toward each particle's resting orbit.
  final double spring;

  /// Velocity retained per frame; lower settles faster.
  final double damping;

  /// Color disturbed particles tint toward. Defaults to no tint (the calm
  /// look), brightening with [color] only.
  final Color? glowColor;

  @override
  State<DopDeprivationOrb> createState() => _DopDeprivationOrbState();
}

class _DopDeprivationOrbState extends State<DopDeprivationOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  late List<_DeprivationParticle> _particles;
  final _Pointer _pointer = _Pointer();
  final _OrbRuntime _runtime = _OrbRuntime();

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this)..addListener(_onTick);
    _particles = _buildParticles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant DopDeprivationOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount ||
        oldWidget.seed != widget.seed) {
      _particles = _buildParticles();
    }
    if (oldWidget.animate != widget.animate ||
        oldWidget.interactive != widget.interactive ||
        oldWidget.breathingSpeed != widget.breathingSpeed ||
        oldWidget.rotationSpeed != widget.rotationSpeed ||
        oldWidget.drift != widget.drift) {
      _syncTicker();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.colors.ink;
    final enabled = _interactionEnabled;

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: Listener(
          onPointerDown: enabled ? _handleDown : null,
          onPointerMove: enabled ? _handleMove : null,
          onPointerHover: enabled ? _handleHover : null,
          onPointerUp: enabled ? _handleUp : null,
          onPointerCancel: enabled ? _handleCancel : null,
          behavior: HitTestBehavior.opaque,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _DopDeprivationOrbPainter(
                ticker: _ticker,
                particles: _particles,
                pointer: _pointer,
                runtime: _runtime,
                interactive: enabled,
                particleSizeMin: widget.particleSizeMin,
                particleSizeMax: widget.particleSizeMax,
                opacity: widget.opacity,
                breathingSpeed: widget.breathingSpeed,
                rotationSpeed: widget.rotationSpeed,
                drift: widget.drift,
                spread: widget.spread,
                repelRadius: widget.repelRadius,
                repelStrength: widget.repelStrength,
                swirlStrength: widget.swirlStrength,
                spring: widget.spring,
                damping: widget.damping,
                color: color,
                glowColor: widget.glowColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _syncTicker() {
    final shouldAnimate = widget.animate && !_reducedMotion && _hasMotion;
    if (shouldAnimate) {
      if (!_ticker.isAnimating) {
        _ticker.repeat(period: const Duration(seconds: 1));
      }
    } else if (!_hasMotion) {
      // Leave any interaction-driven tick running; only stop the steady ticker.
      _ticker.stop();
    }
  }

  /// Starts ticking for an interaction when no steady motion already drives it.
  void _ensureTicking() {
    if (_hasMotion || _ticker.isAnimating) return;
    _runtime.reset();
    _ticker.repeat(period: const Duration(seconds: 1));
  }

  /// Stops the interaction-driven tick once the orb has fully settled.
  void _onTick() {
    if (_hasMotion) return;
    final t = _runtime.lastT;
    final live = _pointer.down || (t - _pointer.lastMove) < 0.9;
    if (!live &&
        _pointer.pressure < _kSettleEps &&
        _runtime.energy < _kEnergyEps) {
      _ticker.stop();
    }
  }

  void _handleDown(PointerDownEvent event) {
    _pointer.down = true;
    _setPointer(event.localPosition);
    _ensureTicking();
  }

  void _handleMove(PointerMoveEvent event) {
    _setPointer(event.localPosition);
    _ensureTicking();
  }

  void _handleHover(PointerHoverEvent event) {
    _setPointer(event.localPosition);
    _ensureTicking();
  }

  void _handleUp(PointerUpEvent event) {
    _pointer.down = false;
    _setPointer(event.localPosition);
  }

  void _handleCancel(PointerCancelEvent event) {
    _pointer.down = false;
  }

  void _setPointer(Offset position) {
    _pointer.velocity = position - _pointer.position;
    _pointer.position = position;
    _pointer.lastMove = _runtime.lastT;
  }

  bool get _interactionEnabled =>
      widget.interactive && widget.animate && !_reducedMotion;

  bool get _reducedMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  bool get _hasMotion =>
      widget.breathingSpeed != 0 ||
      widget.rotationSpeed != 0 ||
      widget.drift != 0;

  List<_DeprivationParticle> _buildParticles() {
    final random = math.Random(widget.seed);
    return List.generate(
      widget.particleCount,
      (_) => _DeprivationParticle(
        angle: random.nextDouble() * math.pi * 2,
        radius: math.sqrt(random.nextDouble()),
        phase: random.nextDouble() * math.pi * 2,
        sizeUnit: random.nextDouble(),
        weight: 0.5 + random.nextDouble() * 0.8,
        blink: 0.3 + random.nextDouble() * 0.7,
      ),
    );
  }
}

class _DopDeprivationOrbPainter extends CustomPainter {
  _DopDeprivationOrbPainter({
    required AnimationController ticker,
    required this.particles,
    required this.pointer,
    required this.runtime,
    required this.interactive,
    required this.particleSizeMin,
    required this.particleSizeMax,
    required this.opacity,
    required this.breathingSpeed,
    required this.rotationSpeed,
    required this.drift,
    required this.spread,
    required this.repelRadius,
    required this.repelStrength,
    required this.swirlStrength,
    required this.spring,
    required this.damping,
    required this.color,
    required this.glowColor,
  }) : _ticker = ticker,
       super(repaint: ticker);

  final AnimationController _ticker;
  final List<_DeprivationParticle> particles;
  final _Pointer pointer;
  final _OrbRuntime runtime;
  final bool interactive;
  final double particleSizeMin;
  final double particleSizeMax;
  final double opacity;
  final double breathingSpeed;
  final double rotationSpeed;
  final double drift;
  final double spread;
  final double repelRadius;
  final double repelStrength;
  final double swirlStrength;
  final double spring;
  final double damping;
  final Color color;
  final Color? glowColor;

  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = _ticker.lastElapsedDuration;
    final t = elapsed == null ? 0.0 : elapsed.inMicroseconds / 1000000;
    final dt = _step(t);

    final breathT = breathingSpeed == 0 ? 0.0 : t;
    final rotationT = rotationSpeed == 0 ? 0.0 : t;
    final driftT = drift == 0 ? 0.0 : t;
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * spread;
    final breath = 1 + math.sin(breathT * breathingSpeed) * 0.08;

    final pointerLive = interactive && (pointer.down || (t - pointer.lastMove) < 0.9);
    _updatePointer(t, pointerLive);
    final simulate =
        interactive &&
        (pointerLive ||
            pointer.pressure > _kSettleEps ||
            runtime.energy > _kEnergyEps);

    var maxSpeedSq = 0.0;

    for (final particle in particles) {
      final inner = 1 - particle.radius;
      final slowTurn = rotationT * rotationSpeed * (0.25 + inner * 1.4);
      final wave = math.sin(driftT * 0.65 + particle.phase) * drift * inner;
      final angleWobble = rotationSpeed == 0
          ? 0.0
          : math.sin(rotationT * 0.15 + particle.phase) * 0.03;
      final angle = particle.angle + slowTurn + angleWobble;
      final radius = baseRadius * (0.15 + particle.radius * 0.85) * breath;
      final pulse =
          0.5 + math.sin(breathT * particle.blink + particle.phase) * 0.5;

      final homeX = center.dx + math.cos(angle) * radius + wave;
      final homeY = center.dy + math.sin(angle) * radius + wave * 0.25;
      particle.homeX = homeX;
      particle.homeY = homeY;

      if (simulate) {
        _simulate(particle, dt);
        maxSpeedSq = math.max(
          maxSpeedSq,
          particle.vx * particle.vx + particle.vy * particle.vy,
        );
      } else {
        particle.x = homeX;
        particle.y = homeY;
        particle.vx = 0;
        particle.vy = 0;
        particle.pressure *= 0.9;
      }

      final pressure = particle.pressure;
      final alpha =
          (0.012 +
                  math.pow(inner, 1.1) * opacity +
                  pulse * 0.07 +
                  pressure * 0.16)
              .clamp(0.0, 0.7)
              .toDouble();
      final particleSize =
          (particleSizeMin +
              particle.sizeUnit * (particleSizeMax - particleSizeMin)) *
          (0.8 + pulse * 0.5) *
          (0.8 + inner * 0.45) *
          (1 + pressure * 0.65);

      var strokeColor = color;
      if (glowColor != null && pressure > 0.05) {
        strokeColor = Color.lerp(color, glowColor, pressure.clamp(0.0, 1.0))!;
      }

      _paint
        ..color = strokeColor.withValues(alpha: alpha)
        ..strokeWidth = particle.weight + pressure * 0.7
        ..maskFilter = pressure > 0.04
            ? MaskFilter.blur(BlurStyle.normal, pressure * 4)
            : null;

      _paintCross(
        canvas,
        Offset(particle.x, particle.y),
        particleSize,
        angle + math.pi / 4 + pressure * 0.65,
      );
    }

    runtime.energy = simulate ? math.sqrt(maxSpeedSq) : 0;
  }

  /// Returns the clamped frame delta and advances the runtime clock.
  double _step(double t) {
    final double dt;
    if (!runtime.primed) {
      runtime.primed = true;
      dt = 0.016;
    } else {
      final raw = t - runtime.lastT;
      dt = raw <= 0 ? 0.016 : math.min(raw, 0.033);
    }
    runtime.lastT = t;
    return dt;
  }

  void _updatePointer(double t, bool live) {
    if (!live) {
      pointer.pressure *= 0.9;
      return;
    }
    final age = t - pointer.lastMove;
    final target = pointer.down
        ? 1.0
        : math.max(0.0, 1 - age / 0.9) * 0.45;
    pointer.pressure += (target - pointer.pressure) * 0.18;
  }

  void _simulate(_DeprivationParticle p, double dt) {
    p.vx += (p.homeX - p.x) * spring * dt;
    p.vy += (p.homeY - p.y) * spring * dt;

    var pressure = 0.0;
    if (pointer.pressure > 0.001) {
      final dx = p.x - pointer.position.dx;
      final dy = p.y - pointer.position.dy;
      final distSq = dx * dx + dy * dy;
      final radius = repelRadius * (0.8 + pointer.pressure * 0.55);

      if (distSq < radius * radius) {
        final dist = math.sqrt(distSq) == 0 ? 1 : math.sqrt(distSq);
        final nx = dx / dist;
        final ny = dy / dist;

        final power = math.pow(1 - dist / radius, 2.15) * pointer.pressure;
        pressure = power.toDouble();

        final repel = repelStrength * power;
        final swirl = swirlStrength * power;

        p.vx += nx * repel * dt;
        p.vy += ny * repel * dt;
        p.vx += -ny * swirl * dt;
        p.vy += nx * swirl * dt;
        p.vx += pointer.velocity.dx * 0.018 * power;
        p.vy += pointer.velocity.dy * 0.018 * power;
      }
    }

    p.pressure += (pressure - p.pressure) * 0.18;

    final frameDamping = math.pow(damping, dt * 60).toDouble();
    p.vx *= frameDamping;
    p.vy *= frameDamping;

    p.x += p.vx * dt;
    p.y += p.vy * dt;
  }

  void _paintCross(Canvas canvas, Offset center, double size, double rotation) {
    final dx1 = math.cos(rotation) * size;
    final dy1 = math.sin(rotation) * size;
    final dx2 = math.cos(rotation + math.pi / 2) * size;
    final dy2 = math.sin(rotation + math.pi / 2) * size;

    canvas.drawLine(
      Offset(center.dx - dx1, center.dy - dy1),
      Offset(center.dx + dx1, center.dy + dy1),
      _paint,
    );
    canvas.drawLine(
      Offset(center.dx - dx2, center.dy - dy2),
      Offset(center.dx + dx2, center.dy + dy2),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DopDeprivationOrbPainter oldDelegate) {
    return oldDelegate.particles != particles ||
        oldDelegate.interactive != interactive ||
        oldDelegate.particleSizeMin != particleSizeMin ||
        oldDelegate.particleSizeMax != particleSizeMax ||
        oldDelegate.opacity != opacity ||
        oldDelegate.breathingSpeed != breathingSpeed ||
        oldDelegate.rotationSpeed != rotationSpeed ||
        oldDelegate.drift != drift ||
        oldDelegate.spread != spread ||
        oldDelegate.repelRadius != repelRadius ||
        oldDelegate.repelStrength != repelStrength ||
        oldDelegate.swirlStrength != swirlStrength ||
        oldDelegate.spring != spring ||
        oldDelegate.damping != damping ||
        oldDelegate.color != color ||
        oldDelegate.glowColor != glowColor;
  }
}

/// Live pointer state shared between gesture handlers and the painter.
class _Pointer {
  Offset position = Offset.zero;
  Offset velocity = Offset.zero;
  bool down = false;
  double lastMove = -9999;
  double pressure = 0;
}

/// Mutable per-frame clock and activity shared between handlers and painter.
class _OrbRuntime {
  double lastT = 0;
  double energy = 0;
  bool primed = false;

  void reset() {
    lastT = 0;
    energy = 0;
    primed = false;
  }
}

class _DeprivationParticle {
  _DeprivationParticle({
    required this.angle,
    required this.radius,
    required this.phase,
    required this.sizeUnit,
    required this.weight,
    required this.blink,
  });

  final double angle;
  final double radius;
  final double phase;
  final double sizeUnit;
  final double weight;
  final double blink;

  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double homeX = 0;
  double homeY = 0;
  double pressure = 0;
}
