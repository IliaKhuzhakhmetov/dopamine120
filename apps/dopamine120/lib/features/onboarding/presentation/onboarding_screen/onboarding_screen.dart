import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine120/features/application/presentation/router/app_router.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../domain/entities/onboarding_result.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/get_health_access_status.dart';
import '../../domain/usecases/request_health_access.dart';
import '../../domain/usecases/request_setup_access.dart';
import '../../domain/usecases/save_action_readiness.dart';
import '../controller/onboarding_controller.dart';
import 'steps/attention_step.dart';
import 'steps/intro_step.dart';
import 'steps/reward_step.dart';
import 'widgets/onboarding_page.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinished});

  /// Overrides the default finish navigation (replacing the stack with
  /// home); the router guard and tests use it.
  final ValueChanged<OnboardingResult>? onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 3;

  late final OnboardingController _controller;
  late final PageController _pageController;
  int _page = 0;
  bool _attentionGathered = false;
  bool _rewardReady = false;

  @override
  void initState() {
    super.initState();
    final injector = DependencyScope.of(context);

    _controller = OnboardingController(
      saveActionReadiness: injector.get<SaveActionReadiness>(),
      getHealthAccessStatus: injector.get<GetHealthAccessStatus>(),
      requestHealthAccess: injector.get<RequestHealthAccess>(),
      requestSetupAccess: injector.get<RequestSetupAccess>(),
      completeOnboarding: injector.get<CompleteOnboarding>(),
    );
    _controller.init();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showPage(int page) {
    setState(() => _page = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    final result = await _controller.finish();
    if (!mounted) return;
    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished(result);
    } else {
      context.router.replaceAll([const HomeRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final page = _page;

            return DopResponsivePane(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        AnimatedOpacity(
                          opacity: page > 0 ? 1 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: IgnorePointer(
                            ignoring: page == 0,
                            child: DopBackButton(
                              semanticLabel: context.l10n.backLabel,
                              onPressed: _controller.loading
                                  ? null
                                  : () => _showPage(page - 1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: DopStepIndicator(
                            count: _pageCount,
                            index: page,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (value) {
                        if (_page != value) setState(() => _page = value);
                      },
                      // Swiping would fight the attention field gesture, so pages
                      // advance only through the buttons.
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const OnboardingPage(child: IntroStep()),
                        OnboardingPage(
                          child: AttentionStep(
                            active: page == 1,
                            onGathered: () {
                              if (_attentionGathered) return;
                              setState(() => _attentionGathered = true);
                            },
                          ),
                        ),
                        OnboardingPage(
                          child: RewardStep(
                            active: page == 2,
                            onRewardReady: () {
                              if (_rewardReady) return;
                              setState(() => _rewardReady = true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: _footer(context.l10n, page),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Pinned action bar under the pages; keyed so the switcher cross-fades it
  /// between steps.
  Widget _footer(AppLocalizations l10n, int page) {
    final loading = _controller.loading;
    return switch (page) {
      0 => Column(
        key: const ValueKey(0),
        children: [
          DopButton.primary(
            label: l10n.nextLabel,
            onPressed: () => _showPage(1),
          ),
          const SizedBox(height: 12),
          DopButton.link(label: l10n.skipLabel, onPressed: _finish),
        ],
      ),
      1 => Column(
        key: const ValueKey(1),
        children: [
          DopButton.primary(
            label: l10n.continueLabel,
            onPressed: _attentionGathered ? () => _showPage(2) : null,
          ),
          const SizedBox(height: 12),
          DopButton.link(label: l10n.skipLabel, onPressed: _finish),
        ],
      ),
      _ => Column(
        key: const ValueKey(2),
        children: [
          DopButton.primary(
            label: l10n.beginLabel,
            onPressed: loading || !_rewardReady ? null : _finish,
          ),
          const SizedBox(height: 12),
          DopButton.link(
            label: l10n.skipLabel,
            onPressed: loading ? null : _finish,
          ),
        ],
      ),
    };
  }
}
