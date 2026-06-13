import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/l10n.dart';
import '../../../domain/entities/action_readiness.dart';
import '../../controller/onboarding_controller.dart';
import '../widgets/onboarding_motion.dart';

class ReadinessStep extends StatefulWidget {
  const ReadinessStep({super.key, required this.controller});

  final OnboardingController controller;

  @override
  State<ReadinessStep> createState() => _ReadinessStepState();
}

class _ReadinessStepState extends State<ReadinessStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final controller = widget.controller;
    final score = controller.readiness?.score ?? ActionReadiness.neutralScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredText(
          animation: _entrance,
          start: 0,
          child: DopText.header(l10n.onboardingReadinessTitle),
        ),
        const SizedBox(height: 12),
        StaggeredText(
          animation: _entrance,
          start: 0.18,
          child: DopText.body(
            l10n.onboardingReadinessBody,
            color: colors.inkSoft,
          ),
        ),
        const SizedBox(height: 44),
        StaggeredText(
          animation: _entrance,
          start: 0.36,
          child: DopScaleSelector(
            value: score,
            min: ActionReadiness.minScore,
            max: ActionReadiness.maxScore,
            minLabel: l10n.onboardingReadinessMin,
            maxLabel: l10n.onboardingReadinessMax,
            semanticLabel: l10n.onboardingReadinessSemantic,
            onChanged: (value) {
              controller.chooseReadiness(ActionReadiness(value));
            },
          ),
        ),
      ],
    );
  }
}
