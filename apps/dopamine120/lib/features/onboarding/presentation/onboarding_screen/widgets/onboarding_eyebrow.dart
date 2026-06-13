import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

/// Small section label + step counter sitting above each onboarding title,
/// e.g. `THE LOOP            01 / 03`.
class OnboardingEyebrow extends StatelessWidget {
  const OnboardingEyebrow({
    super.key,
    required this.label,
    required this.step,
    this.total = 3,
  });

  /// Section name shown on the left.
  final String label;

  /// 1-based index of the current step.
  final int step;

  /// Total number of steps shown on the right.
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final counter =
        '${step.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DopText.label(label, color: colors.inkFaint),
        DopText.label(counter, color: colors.inkFaint),
      ],
    );
  }
}
