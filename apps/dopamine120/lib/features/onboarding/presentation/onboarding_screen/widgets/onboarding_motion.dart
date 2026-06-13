import 'package:flutter/material.dart';

/// Scales its child in with an overshoot along the entrance stagger;
/// [spin] adds a small settling rotation.
class PopIn extends StatelessWidget {
  const PopIn({
    super.key,
    required this.animation,
    required this.start,
    this.spin = false,
    required this.child,
  });

  final Animation<double> animation;
  final double start;
  final bool spin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        start,
        (start + 0.45).clamp(0.0, 1.0),
        curve: Curves.easeOutBack,
      ),
    );

    Widget result = ScaleTransition(scale: curved, child: child);
    if (spin) {
      result = RotationTransition(
        turns: Tween<double>(begin: -0.12, end: 0).animate(curved),
        child: result,
      );
    }
    return result;
  }
}

class StaggeredText extends StatelessWidget {
  const StaggeredText({
    super.key,
    required this.animation,
    required this.start,
    required this.child,
  });

  final Animation<double> animation;
  final double start;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
