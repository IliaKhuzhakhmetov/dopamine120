import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/onboarding_result.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/get_health_access_status.dart';
import '../../domain/usecases/request_health_access.dart';
import '../../domain/usecases/request_setup_access.dart';
import '../../domain/usecases/save_action_readiness.dart';
import '../controller/onboarding_controller.dart';
import 'steps/access_step.dart';
import 'steps/intro_step.dart';
import 'steps/readiness_step.dart';
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
  final PageController _pageController = PageController();
  int _page = 0;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showPage(int page) {
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      AnimatedOpacity(
                        opacity: _page > 0 ? 1 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: IgnorePointer(
                          ignoring: _page == 0,
                          child: DopBackButton(
                            semanticLabel: context.l10n.backLabel,
                            onPressed: _controller.loading
                                ? null
                                : () => _showPage(_page - 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DopStepIndicator(
                          count: _pageCount,
                          index: _page,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    // Swiping would fight the readiness scale's horizontal
                    // drag, so pages advance only through the buttons.
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _page = page),
                    children: [
                      const OnboardingPage(child: IntroStep()),
                      OnboardingPage(
                        child: ReadinessStep(controller: _controller),
                      ),
                      OnboardingPage(
                        child: AccessStep(controller: _controller),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: _footer(context.l10n),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Pinned action bar under the pages; keyed so the switcher cross-fades it
  /// between steps.
  Widget _footer(AppLocalizations l10n) {
    final loading = _controller.loading;
    return switch (_page) {
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
            onPressed: () => _showPage(2),
          ),
          const SizedBox(height: 12),
          DopButton.link(label: l10n.skipLabel, onPressed: _finish),
        ],
      ),
      _ => Column(
        key: const ValueKey(2),
        children: [
          DopButton.primary(
            label: l10n.finishLabel,
            onPressed: loading ? null : _finish,
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
