import 'dart:math' as math;

import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../../l10n/l10n.dart';
import '../widgets/onboarding_eyebrow.dart';
import '../widgets/onboarding_motion.dart';

class RewardStep extends StatefulWidget {
  const RewardStep({
    super.key,
    this.active = true,
    this.onRewardReady = _noopRewardStepCallback,
  });

  final bool active;
  final VoidCallback onRewardReady;

  @override
  State<RewardStep> createState() => _RewardStepState();
}

class _RewardStepState extends State<RewardStep> with TickerProviderStateMixin {
  static const _ignite = 100.0;
  static const _gainPerPx = 0.034;
  static const _gainCap = 1.1;
  static const _decayDrag = 0.009;
  static const _decayIdle = 0.018;

  late final AnimationController _entrance;
  late final Ticker _ticker;
  late final DopConfettiController _confettiController;
  final List<_HeatDab> _dabs = [];
  final List<_HeatSpark> _sparks = [];
  final math.Random _random = math.Random(120);

  Size _padSize = Size.zero;
  Offset? _previousPointer;
  Duration? _lastTick;
  double _heat = 0;
  double _moved = 0;
  double _slowMs = 0;
  double _pulse = 0;
  bool _dragging = false;
  bool _done = false;
  bool _warned = false;
  _RewardHint _hint = _RewardHint.idle;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _confettiController = DopConfettiController(
      duration: const Duration(milliseconds: 900),
    );
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.active && !_done) _startTicking();
    });
  }

  @override
  void didUpdateWidget(covariant RewardStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active && !_done) {
      _startTicking();
    } else if (!widget.active && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _confettiController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _startTicking() {
    _lastTick = null;
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration elapsed) {
    final previous = _lastTick ?? elapsed;
    _lastTick = elapsed;
    final dtMs = ((elapsed - previous).inMicroseconds / 1000).clamp(1.0, 40.0);

    if (!_done) {
      final gain = math.min(_gainCap, _moved * _gainPerPx);
      _moved = 0;
      _heat += gain;
      _heat -= (_dragging ? _decayDrag : _decayIdle) * dtMs;
      _heat = _heat.clamp(0, _ignite);

      if (_dragging) {
        if (gain < 0.15) {
          _slowMs += dtMs;
          if (_slowMs > 320 && _heat > 12 && !_warned) {
            _setHint(_RewardHint.slow, haptic: true);
          }
        } else {
          _slowMs = 0;
          if (_hint == _RewardHint.slow) _setHint(_RewardHint.active);
        }
      }

      if (_heat > 82) {
        _pulse += dtMs * 0.02;
      }

      if (_heat >= _ignite) _finishReward();
    }

    for (var i = _dabs.length - 1; i >= 0; i--) {
      _dabs[i].alpha *= 0.9;
      if (_dabs[i].alpha < 0.02) _dabs.removeAt(i);
    }
    for (var i = _sparks.length - 1; i >= 0; i--) {
      final spark = _sparks[i];
      spark.x += spark.vx;
      spark.y += spark.vy;
      spark.life -= 0.011;
      if (spark.life <= 0) _sparks.removeAt(i);
    }

    if (mounted) setState(() {});
  }

  void _setHint(_RewardHint value, {bool haptic = false}) {
    _hint = value;
    _warned = value == _RewardHint.slow || value == _RewardHint.stopped;
    if (haptic) DopHapticFeedback.light();
  }

  void _finishReward() {
    _done = true;
    _dragging = false;
    _heat = _ignite;
    _previousPointer = null;
    // The ticker stops here, so any lingering dabs/sparks would freeze on the
    // pad as a warm blob. Clear them now for a clean "done" surface.
    _dabs.clear();
    _sparks.clear();
    _setHint(_RewardHint.ready);
    _ticker.stop();
    DopHapticFeedback.medium();
    _confettiController.play();
    widget.onRewardReady();
  }

  void _onPanStart(DragStartDetails details) {
    if (_done) return;
    _dragging = true;
    _previousPointer = _clampPointer(details.localPosition);
    _slowMs = 0;
    _warned = false;
    _setHint(_RewardHint.active);
    DopHapticFeedback.selection();
    _startTicking();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_dragging || _done) return;
    final point = _clampPointer(details.localPosition);
    final previous = _previousPointer;
    if (previous != null) {
      final distance = (point - previous).distance;
      _moved += distance;
      _dabs.add(
        _HeatDab(
          x: point.dx,
          y: point.dy,
          radius: 24 + distance * 0.4,
          alpha: math.min(0.9, 0.22 + distance * 0.03),
        ),
      );
      if (_dabs.length > 70) _dabs.removeAt(0);

      if (_heat > 32 && distance > 2 && _random.nextDouble() < 0.35) {
        _sparks.add(
          _HeatSpark(
            x: point.dx + (_random.nextDouble() - 0.5) * 16,
            y: point.dy,
            vx: (_random.nextDouble() - 0.5) * 0.3,
            vy: -(0.35 + _random.nextDouble() * 0.7),
            size: 1.3 + _random.nextDouble() * 2.2,
          ),
        );
        if (_sparks.length > 46) _sparks.removeAt(0);
      }
    }
    _previousPointer = point;
  }

  void _onPanEnd() {
    if (_done) return;
    _dragging = false;
    _previousPointer = null;
    if (_heat > 10) {
      _setHint(_RewardHint.stopped, haptic: true);
    } else {
      _setHint(_RewardHint.idle);
    }
  }

  Offset _clampPointer(Offset point) {
    return Offset(
      point.dx.clamp(0, _padSize.width),
      point.dy.clamp(0, _padSize.height),
    );
  }

  String _hintText(AppLocalizations l10n) => switch (_hint) {
    _RewardHint.idle => l10n.onboardingRewardHintIdle,
    _RewardHint.active => l10n.onboardingRewardHintActive,
    _RewardHint.slow => l10n.onboardingRewardHintSlow,
    _RewardHint.stopped => l10n.onboardingRewardHintStopped,
    _RewardHint.ready => '',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final shake = !_done && _heat > 82
        ? math.sin(_pulse) * (0.6 + 1.4 * ((_heat - 82) / 18))
        : 0.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaggeredText(
              animation: _entrance,
              start: 0,
              child: OnboardingEyebrow(
                label: l10n.onboardingRewardEyebrow,
                step: 3,
              ),
            ),
            const SizedBox(height: 14),
            StaggeredText(
              animation: _entrance,
              start: 0.12,
              child: DopHeaderWidget(
                title:
                    '${l10n.onboardingRewardTitleFirst}\n'
                    '*${l10n.onboardingRewardTitleAccent}*',
              ),
            ),
            const SizedBox(height: 16),
            StaggeredText(
              animation: _entrance,
              start: 0.24,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: DopText.body(
                  _done
                      ? l10n.onboardingRewardReadyBody
                      : l10n.onboardingRewardBody,
                  key: ValueKey(_done),
                  color: colors.inkSoft,
                ),
              ),
            ),
            const SizedBox(height: 32),
            StaggeredText(
              animation: _entrance,
              start: 0.36,
              child: Center(
                child: DopConfetti(
                  key: const ValueKey('reward-rub-confetti'),
                  controller: _confettiController,
                  size: 280,
                  // Hug the 122-tall pad instead of a 280 square, so the burst
                  // box doesn't pad the layout with dead vertical space.
                  height: 140,
                  child: Semantics(
                    label: l10n.onboardingRewardSemantic,
                    button: true,
                    enabled: !_done,
                    child: GestureDetector(
                      key: const ValueKey('reward-rub-pad'),
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: (_) => _onPanEnd(),
                      onPanCancel: _onPanEnd,
                      child: Transform.translate(
                        offset: Offset(shake, 0),
                        child: SizedBox(
                          width: 280,
                          height: 122,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              _padSize = constraints.biggest;
                              return CustomPaint(
                                painter: _RewardHeatPainter(
                                  heat: _heat / _ignite,
                                  done: _done,
                                  dabs: List.of(_dabs),
                                  sparks: List.of(_sparks),
                                  colors: colors,
                                  label: l10n.onboardingRewardPadLabel,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: DopText.label(
                  _hintText(l10n),
                  key: ValueKey(_hint),
                  color:
                      _hint == _RewardHint.slow || _hint == _RewardHint.stopped
                      ? colors.accent
                      : colors.inkFaint,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void _noopRewardStepCallback() {}

class _RewardHeatPainter extends CustomPainter {
  _RewardHeatPainter({
    required this.heat,
    required this.done,
    required this.dabs,
    required this.sparks,
    required this.colors,
    required this.label,
  });

  final double heat;
  final bool done;
  final List<_HeatDab> dabs;
  final List<_HeatSpark> sparks;
  final DopColors colors;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final clip = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.save();
    canvas.clipRRect(clip);

    final base = Paint()
      ..shader = RadialGradient(
        colors: done
            ? [colors.paper, colors.wall]
            : [colors.ink.withValues(alpha: 0.92), colors.voidBlack],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    if (!done) {
      final stripe = Paint()
        ..color = colors.wall.withValues(alpha: 0.06 + 0.05 * heat)
        ..strokeWidth = 1;
      final jitter = heat * 3.2;
      for (var x = 6.0; x < size.width; x += 9) {
        final offset = math.sin(x * 0.4 + heat * 6) * jitter;
        canvas.drawLine(
          Offset(x + offset, 4),
          Offset(x + offset, size.height - 4),
          stripe,
        );
      }
    }

    if (!done && heat > 0) {
      final wash = Paint()
        ..blendMode = BlendMode.plus
        ..shader =
            RadialGradient(
              colors: [_warmColor(0.50 * heat), _warmColor(0)],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width / 2, size.height * 0.55),
                radius: size.width * 0.62,
              ),
            );
      canvas.drawRect(rect, wash);
    }

    final glow = Paint()..blendMode = BlendMode.plus;
    for (final dab in dabs) {
      glow.shader =
          RadialGradient(
            colors: [_warmColor(dab.alpha), _warmColor(0)],
          ).createShader(
            Rect.fromCircle(center: Offset(dab.x, dab.y), radius: dab.radius),
          );
      canvas.drawCircle(Offset(dab.x, dab.y), dab.radius, glow);
    }

    for (final spark in sparks) {
      canvas.drawCircle(
        Offset(spark.x, spark.y),
        spark.size * spark.life,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = _warmColor(spark.life * 0.85),
      );
    }

    if (!done && heat > 0.12) {
      final wave = Paint()
        ..blendMode = BlendMode.plus
        ..color = _warmColor(0.10 * heat)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke;
      final path = Path();
      final amp = 4 + 10 * heat;
      for (var x = 0.0; x <= size.width; x += 6) {
        final y = 10 + math.sin(x * 0.05 + heat * 8) * amp;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wave);
    }

    canvas.restore();

    if (!done) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label.toUpperCase(),
          style: TextStyle(
            color: colors.wall.withValues(
              alpha: (0.5 - 0.5 * heat).clamp(0, 1),
            ),
            fontSize: 11,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  Color _warmColor(double alpha) {
    final p = heat.clamp(0, 1);
    final green = (185 - 65 * p).round();
    final blue = (85 + 120 * p).round();
    return Color.fromRGBO(255, green, blue, alpha.clamp(0, 1).toDouble());
  }

  @override
  bool shouldRepaint(covariant _RewardHeatPainter oldDelegate) {
    return heat != oldDelegate.heat ||
        done != oldDelegate.done ||
        dabs != oldDelegate.dabs ||
        sparks != oldDelegate.sparks ||
        label != oldDelegate.label ||
        colors != oldDelegate.colors;
  }
}

enum _RewardHint { idle, active, slow, stopped, ready }

class _HeatDab {
  _HeatDab({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
  });

  final double x;
  final double y;
  final double radius;
  double alpha;
}

class _HeatSpark {
  _HeatSpark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
  });

  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  double life = 1;
}
