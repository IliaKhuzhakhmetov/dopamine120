import 'dart:math' as math;

import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../widgets/onboarding_eyebrow.dart';
import '../widgets/onboarding_motion.dart';

class AttentionStep extends StatefulWidget {
  const AttentionStep({
    super.key,
    required this.active,
    required this.onGathered,
  });

  final bool active;
  final VoidCallback onGathered;

  @override
  State<AttentionStep> createState() => _AttentionStepState();
}

class _AttentionStepState extends State<AttentionStep>
    with TickerProviderStateMixin {
  static const _particleCount = 120;
  static const _pullGain = 0.20;

  late final AnimationController _entrance;
  late final Ticker _ticker;
  final List<_AttentionParticle> _particles = [];
  final math.Random _random = math.Random(120);

  Size _fieldSize = Size.zero;
  Offset _pointer = Offset.zero;
  Offset? _convergenceCenter;
  Duration? _lastTick;
  double _maxSpread = 1;
  double _settle = 0;
  double _breathPhase = 0;
  double _smoothGather = 0;
  bool _pointerActive = false;
  bool _gathered = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.active && !_gathered) _startTicking();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AttentionStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active && !_gathered) {
      _startTicking();
    } else if (!widget.active && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _seed(Size size) {
    _fieldSize = size;
    _particles
      ..clear()
      ..addAll(
        List.generate(_particleCount, (_) {
          final x = _random.nextDouble() * size.width;
          final y = _random.nextDouble() * size.height;
          return _AttentionParticle(
            x: x,
            y: y,
            vx: (_random.nextDouble() - 0.5) * 0.25,
            vy: (_random.nextDouble() - 0.5) * 0.25,
            radius: 1.6 + _random.nextDouble() * 2,
            alpha: 0.28 + _random.nextDouble() * 0.45,
          );
        }),
      );
    _maxSpread = math.max(1, _metrics().spread);
    _smoothGather = 0;
    _convergenceCenter = null;
  }

  void _ensureSeeded(Size size) {
    if (size.isEmpty) return;
    final changed =
        (_fieldSize.width - size.width).abs() > 1 ||
        (_fieldSize.height - size.height).abs() > 1;
    if (_particles.isEmpty || changed) {
      _seed(size);
    }
  }

  void _startTicking() {
    _lastTick = null;
    if (!_ticker.isActive) _ticker.start();
  }

  void _stopTickingIfIdle() {
    if (!widget.active && !_pointerActive && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _tick(Duration elapsed) {
    final previous = _lastTick ?? elapsed;
    _lastTick = elapsed;
    final dt = ((elapsed - previous).inMicroseconds / 16667).clamp(0.35, 2.4);
    if (_particles.isEmpty) return;

    var metrics = _metrics();
    if (metrics.spread > _maxSpread) _maxSpread = metrics.spread;
    var gather = _gatherProgress(metrics);
    _breathPhase += dt / 216;

    if (_gathered) {
      final target = _convergenceCenter ?? metrics.center;
      for (final dot in _particles) {
        dot.x += (target.dx - dot.x) * 0.14 * dt;
        dot.y += (target.dy - dot.y) * 0.14 * dt;
      }
      _settle = (_settle + 0.035 * dt).clamp(0, 1);
    } else if (_pointerActive) {
      final pullRadius = 26 * _fieldScale;
      for (final dot in _particles) {
        final dx = _pointer.dx - dot.x;
        final dy = _pointer.dy - dot.y;
        final distance = math.sqrt(dx * dx + dy * dy).clamp(1, double.infinity);
        final pull = math.min(0.9, pullRadius / distance);
        final directionX = dx / distance;
        final directionY = dy / distance;

        dot.vx =
            (dot.vx + directionX * pull * _pullGain * dt) * math.pow(0.86, dt);
        dot.vy =
            (dot.vy + directionY * pull * _pullGain * dt) * math.pow(0.86, dt);
        dot.x += dot.vx * dt;
        dot.y += dot.vy * dt;
      }
      metrics = _metrics();
      gather = _gatherProgress(metrics);
      if (gather > 0.93 || metrics.spread < pullRadius) {
        _gathered = true;
        _pointerActive = false;
        _convergenceCenter = metrics.center;
        HapticFeedback.lightImpact();
        widget.onGathered();
      }
    } else {
      for (final dot in _particles) {
        dot.vx =
            (dot.vx + (_random.nextDouble() - 0.5) * 0.06 * dt) *
            math.pow(0.97, dt);
        dot.vy =
            (dot.vy + (_random.nextDouble() - 0.5) * 0.06 * dt) *
            math.pow(0.97, dt);
        dot.x += dot.vx * dt;
        dot.y += dot.vy * dt;
        dot.bounceWithin(_fieldSize);
      }
      metrics = _metrics();
      gather = _gatherProgress(metrics);
    }

    final targetGather = _gathered ? 1.0 : gather;
    _smoothGather += (targetGather - _smoothGather) * 0.08 * dt;
    _smoothGather = _smoothGather.clamp(0, 1);
    if (mounted) setState(() {});
  }

  double _gatherProgress(_AttentionMetrics metrics) {
    return (1 - (metrics.spread / (_maxSpread * 0.85))).clamp(0.0, 1.0);
  }

  double get _fieldScale {
    final widthScale = math.max(1.0, _fieldSize.longestSide / 393);
    return math.pow(widthScale, 2).clamp(1, 4).toDouble();
  }

  _AttentionMetrics _metrics() {
    var cx = 0.0;
    var cy = 0.0;
    for (final dot in _particles) {
      cx += dot.x;
      cy += dot.y;
    }
    cx /= _particles.length;
    cy /= _particles.length;

    var spread = 0.0;
    for (final dot in _particles) {
      final dx = dot.x - cx;
      final dy = dot.y - cy;
      spread += math.sqrt(dx * dx + dy * dy);
    }

    return _AttentionMetrics(
      center: Offset(cx, cy),
      spread: spread / _particles.length,
    );
  }

  void _movePointer(Offset localPosition) {
    _pointer = Offset(
      localPosition.dx.clamp(0, _fieldSize.width),
      localPosition.dy.clamp(0, _fieldSize.height),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredText(
          animation: _entrance,
          start: 0,
          child: OnboardingEyebrow(
            label: l10n.onboardingAttentionEyebrow,
            step: 2,
          ),
        ),
        const SizedBox(height: 14),
        StaggeredText(
          animation: _entrance,
          start: 0.06,
          child: _AttentionTitle(
            firstPrefix: l10n.onboardingAttentionTitleFirstPrefix,
            firstAccent: l10n.onboardingAttentionTitleFirstAccent,
            secondPrefix: l10n.onboardingAttentionTitleSecondPrefix,
            secondAccent: l10n.onboardingAttentionTitleSecondAccent,
          ),
        ),
        const SizedBox(height: 16),
        StaggeredText(
          animation: _entrance,
          start: 0.14,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            child: _gathered
                ? DopText.body(
                    l10n.onboardingAttentionGatheredBody,
                    key: const ValueKey('attention-gathered-body'),
                    color: colors.inkSoft,
                  )
                : DopText.body(
                    l10n.onboardingAttentionBody,
                    key: const ValueKey('attention-body'),
                    color: colors.inkSoft,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: math.max(190, MediaQuery.sizeOf(context).height * 0.34),
          child: StaggeredText(
            animation: _entrance,
            start: 0.28,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                _ensureSeeded(size);
                final metrics = _particles.isEmpty ? null : _metrics();
                final center = _gathered
                    ? (_convergenceCenter ??
                          metrics?.center ??
                          size.center(Offset.zero))
                    : metrics?.center ?? size.center(Offset.zero);

                return Semantics(
                  container: true,
                  label: l10n.onboardingAttentionSemantic,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (event) {
                      if (_gathered) return;
                      _pointerActive = true;
                      _movePointer(event.localPosition);
                      _startTicking();
                    },
                    onPointerMove: (event) {
                      if (_gathered) return;
                      _movePointer(event.localPosition);
                    },
                    onPointerUp: (_) {
                      _pointerActive = false;
                      _stopTickingIfIdle();
                    },
                    onPointerCancel: (_) {
                      _pointerActive = false;
                      _stopTickingIfIdle();
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: _AttentionAura(
                              progress: _smoothGather,
                              breathPhase: _breathPhase,
                              breathIntensity: _gathered ? _settle : 0,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            key: const ValueKey('attention-field'),
                            painter: _AttentionPainter(
                              particles: _particles,
                              colors: colors,
                              gathered: _gathered,
                              settle: _settle,
                              metrics: metrics,
                              maxSpread: _maxSpread,
                            ),
                          ),
                        ),
                        if (_gathered)
                          Positioned(
                            left: center.dx - 64,
                            top: center.dy - 64,
                            width: 128,
                            height: 128,
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 220),
                                opacity: _settle,
                                child: Transform.scale(
                                  scale: 0.6 + _settle * 0.4,
                                  child: _BreathingTarget(
                                    breathPhase: _breathPhase,
                                    intensity: _settle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 360),
                            opacity: _pointerActive || _gathered ? 0 : 1,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: DopText.label(
                                l10n.onboardingAttentionHint,
                                color: colors.inkFaint,
                                align: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AttentionAura extends StatelessWidget {
  const _AttentionAura({
    required this.progress,
    required this.breathPhase,
    required this.breathIntensity,
  });

  final double progress;
  final double breathPhase;
  final double breathIntensity;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final phase = math.sin(breathPhase * math.pi * 2);
    final breathingScale = 1 + phase * 0.018 * breathIntensity.clamp(0, 1);

    return Opacity(
      opacity: 0.84 * eased,
      child: Transform.scale(
        scale: (1.12 + eased * 0.04) * breathingScale,
        child: Assets.icons.attentionAura.svg(fit: BoxFit.cover),
      ),
    );
  }
}

class _BreathingTarget extends StatelessWidget {
  const _BreathingTarget({required this.breathPhase, required this.intensity});

  final double breathPhase;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final phase = math.sin(breathPhase * math.pi * 2);
    return Transform.scale(
      scale: 1 + phase * 0.018 * intensity.clamp(0, 1),
      child: Assets.icons.attentionRipple.svg(),
    );
  }
}

class _AttentionTitle extends StatelessWidget {
  const _AttentionTitle({
    required this.firstPrefix,
    required this.firstAccent,
    required this.secondPrefix,
    required this.secondAccent,
  });

  final String firstPrefix;
  final String firstAccent;
  final String secondPrefix;
  final String secondAccent;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;
    final base = typo.header.copyWith(height: 1.04);
    final accent = typo.headerAccent.copyWith(height: 1.04);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$firstPrefix ', style: base),
          TextSpan(text: firstAccent, style: accent),
          const TextSpan(text: '\n'),
          TextSpan(text: '$secondPrefix ', style: base),
          TextSpan(text: secondAccent, style: accent),
        ],
      ),
    );
  }
}

class _AttentionPainter extends CustomPainter {
  const _AttentionPainter({
    required this.particles,
    required this.colors,
    required this.gathered,
    required this.settle,
    required this.metrics,
    required this.maxSpread,
  });

  final List<_AttentionParticle> particles;
  final DopColors colors;
  final bool gathered;
  final double settle;
  final _AttentionMetrics? metrics;
  final double maxSpread;

  @override
  void paint(Canvas canvas, Size size) {
    final center = metrics?.center ?? size.center(Offset.zero);
    final blurScale = math.max(1, maxSpread * 0.72);
    final metricSnapshot = metrics;
    final gather = metricSnapshot == null
        ? 0.0
        : (1 - (metricSnapshot.spread / (maxSpread * 0.85))).clamp(0.0, 1.0);
    final effectiveGather = gathered ? 1.0 : gather;
    final maxBlur = (1 - effectiveGather) * 5.5 * (1 - settle * 0.9);
    for (final dot in particles) {
      final alpha = gathered ? dot.alpha * (1 - settle) : dot.alpha;
      if (alpha <= 0.01) continue;
      final position = Offset(dot.x, dot.y);
      final distance = (position - center).distance;
      final blur = gathered
          ? 0.0
          : (distance / blurScale).clamp(0.0, 1.0) * maxBlur;
      canvas.drawCircle(
        position,
        dot.radius,
        Paint()
          ..color = colors.ink.withValues(alpha: alpha.clamp(0, 1))
          ..maskFilter = blur <= 0.05
              ? null
              : MaskFilter.blur(BlurStyle.normal, blur),
      );
    }
  }

  @override
  bool shouldRepaint(_AttentionPainter oldDelegate) => true;
}

class _AttentionParticle {
  _AttentionParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.alpha,
  });

  double x;
  double y;
  double vx;
  double vy;
  final double radius;
  final double alpha;

  void bounceWithin(Size size) {
    if (x < 0) {
      x = 0;
      vx *= -0.6;
    } else if (x > size.width) {
      x = size.width;
      vx *= -0.6;
    }
    if (y < 0) {
      y = 0;
      vy *= -0.6;
    } else if (y > size.height) {
      y = size.height;
      vy *= -0.6;
    }
  }
}

class _AttentionMetrics {
  const _AttentionMetrics({required this.center, required this.spread});

  final Offset center;
  final double spread;
}
