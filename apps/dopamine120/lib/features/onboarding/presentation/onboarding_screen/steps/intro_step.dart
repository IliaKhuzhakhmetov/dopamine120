import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../core/theme/presentation/theme_provider.dart';
import '../../../domain/usecases/trigger_onboarding_sound.dart';
import '../widgets/creation_icon_animation.dart';
import '../widgets/imagination_icon_animation.dart';
import '../widgets/onboarding_eyebrow.dart';
import '../widgets/onboarding_motion.dart';

enum _IntroStepKind { deprivation, imagination, creation, reward }

typedef OnboardingStep = ({
  _IntroStepKind kind,
  SvgGenImage icon,
  String triggerId,
  String title,
  String body,
  bool flashTheme,
});

class IntroStep extends StatefulWidget {
  const IntroStep({super.key});

  @override
  State<IntroStep> createState() => _IntroStepState();
}

class _IntroStepState extends State<IntroStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final ImaginationIconAnimationController _imaginationIconController;
  late final CreationIconAnimationController _creationIconController;
  late final DopConfettiController _rewardConfettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _imaginationIconController = ImaginationIconAnimationController();
    _creationIconController = CreationIconAnimationController();
    _rewardConfettiController = DopConfettiController();
  }

  @override
  void dispose() {
    _rewardConfettiController.dispose();
    _creationIconController.dispose();
    _imaginationIconController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playSound(String triggerId) async {
    DopHapticFeedback.medium();

    try {
      await context.get<TriggerOnboardingSound>()(triggerId);
    } catch (e, s) {
      // The sound is decoration; a playback failure never blocks the UI.
      Log.e('Intro step sound failed', error: e, stackTrace: s);
    }
  }

  Future<void> _flashDeprivationTheme() async {
    final themeController = context.themeController;
    final token = ++_themeFlashToken;

    await themeController.useDark();
    await Future<void>.delayed(const Duration(milliseconds: 2000));

    if (!mounted || token != _themeFlashToken) return;
    await themeController.useLight();
  }

  var _themeFlashToken = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    final steps = <OnboardingStep>[
      (
        kind: _IntroStepKind.deprivation,
        icon: Assets.icons.deprivationOrb,
        triggerId: 'onboarding.deprivation',
        title: l10n.onboardingStepDeprivationTitle,
        body: l10n.onboardingStepDeprivationBody,
        flashTheme: true,
      ),
      (
        kind: _IntroStepKind.imagination,
        icon: Assets.icons.imaginationBlob,
        triggerId: 'onboarding.imagination',
        title: l10n.onboardingStepImaginationTitle,
        body: l10n.onboardingStepImaginationBody,
        flashTheme: false,
      ),
      (
        kind: _IntroStepKind.creation,
        icon: Assets.icons.creation,
        triggerId: 'onboarding.creation',
        title: l10n.onboardingStepCreationTitle,
        body: l10n.onboardingStepCreationBody,
        flashTheme: false,
      ),
      (
        kind: _IntroStepKind.reward,
        icon: Assets.icons.rewardWave,
        triggerId: 'onboarding.reward',
        title: l10n.onboardingStepRewardTitle,
        body: l10n.onboardingStepRewardBody,
        flashTheme: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredText(
          animation: _controller,
          start: 0,
          child: OnboardingEyebrow(label: l10n.onboardingIntroEyebrow, step: 1),
        ),
        SizedBox(height: spacing.md),
        StaggeredText(
          animation: _controller,
          start: 0.06,
          child: DopHeaderWidget(
            title: l10n.onboardingIntroTitle,
            subtitle: l10n.onboardingIntroSubtitle,
            trailing: PopIn(
              animation: _controller,
              start: 0.1,
              spin: true,
              child: _IntroIcon(Assets.icons.brains, size: 72),
            ),
          ),
        ),
        SizedBox(height: spacing.xl),
        for (final (index, step) in steps.indexed)
          StaggeredText(
            animation: _controller,
            start: 0.18 + index * 0.12,
            child: DopListTile(
              leading: PopIn(
                animation: _controller,
                start: 0.18 + index * 0.12,
                child: _buildLeading(step),
              ),
              title: step.title,
              subtitle: step.body,
              divider: index < steps.length - 1,
              verticalPadding: spacing.md,
              animateTitleOnTap: true,
              animateLeadingOnTap: true,
              onTap: () => _handleTileTap(step),
            ),
          ),
        SizedBox(height: spacing.xl),
      ],
    );
  }

  void _handleTileTap(OnboardingStep step) {
    if (step.flashTheme) {
      unawaited(_flashDeprivationTheme());
    }
    switch (step.kind) {
      case _IntroStepKind.imagination:
        _imaginationIconController.play();
      case _IntroStepKind.creation:
        _creationIconController.play();
      case _IntroStepKind.reward:
        _rewardConfettiController.play();
      case _IntroStepKind.deprivation:
    }
    unawaited(_playSound(step.triggerId));
  }

  Widget _buildLeading(OnboardingStep step) {
    return switch (step.kind) {
      _IntroStepKind.deprivation => _IntroIcon(step.icon),
      _IntroStepKind.imagination => ImaginationIconAnimation(
        controller: _imaginationIconController,
      ),
      _IntroStepKind.creation => CreationIconAnimation(
        controller: _creationIconController,
      ),
      _IntroStepKind.reward => SizedBox(
        width: 78,
        child: Align(
          alignment: Alignment.centerRight,
          child: DopConfetti(
            size: 62,
            key: const ValueKey('reward-confetti'),
            controller: _rewardConfettiController,
            child: _IntroIcon(step.icon),
          ),
        ),
      ),
    };
  }
}

/// Hand-drawn SVG icon tinted in ink.
class _IntroIcon extends StatelessWidget {
  const _IntroIcon(this.asset, {this.size = 62});

  final SvgGenImage asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return asset.svg(
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(context.colors.ink, BlendMode.srcIn),
    );
  }
}
