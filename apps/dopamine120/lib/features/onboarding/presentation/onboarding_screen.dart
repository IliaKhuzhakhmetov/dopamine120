import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../l10n/l10n.dart';
import '../domain/entities/action_readiness.dart';
import '../domain/entities/onboarding_result.dart';
import '../domain/entities/permission_status.dart';
import '../domain/usecases/complete_onboarding.dart';
import '../domain/usecases/get_health_access_status.dart';
import '../domain/usecases/request_health_access.dart';
import '../domain/usecases/request_setup_access.dart';
import '../domain/usecases/save_action_readiness.dart';
import 'controller/onboarding_controller.dart';

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
                      _OnboardingPage(
                        child: _IntroStep(
                          onNext: () => _showPage(1),
                          onSkip: _finish,
                        ),
                      ),
                      _OnboardingPage(
                        child: _ReadinessStep(
                          controller: _controller,
                          onNext: () => _showPage(2),
                          onSkip: _finish,
                        ),
                      ),
                      _OnboardingPage(
                        child: _AccessStep(
                          controller: _controller,
                          onSkip: _finish,
                          onFinish: _finish,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Shared scroll + padding wrapper for one onboarding page.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _IntroStep extends StatefulWidget {
  const _IntroStep({required this.onNext, required this.onSkip});

  final VoidCallback onNext;
  final Future<void> Function() onSkip;

  @override
  State<_IntroStep> createState() => _IntroStepState();
}

class _IntroStepState extends State<_IntroStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _count;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    _count = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.62, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaggeredText(
          animation: _controller,
          start: 0,
          child: DopText.label(l10n.onboardingIntroSignal),
        ),
        const SizedBox(height: 26),
        _StaggeredText(
          animation: _controller,
          start: 0.06,
          child: AnimatedBuilder(
            animation: _count,
            builder: (context, _) {
              final value = 72 + (_count.value * 48).round();
              return DopText.giant('$value', color: colors.accent);
            },
          ),
        ),
        const SizedBox(height: 8),
        _StaggeredText(
          animation: _controller,
          start: 0.3,
          child: DopText.header(l10n.onboardingIntroTitle),
        ),
        const SizedBox(height: 14),
        _StaggeredText(
          animation: _controller,
          start: 0.46,
          child: DopText.body(l10n.onboardingIntroBody, color: colors.inkSoft),
        ),
        const SizedBox(height: 30),
        _StaggeredText(
          animation: _controller,
          start: 0.6,
          child: _SignalStrip(label: l10n.onboardingIntroChoice),
        ),
        const SizedBox(height: 52),
        DopButton.primary(label: l10n.continueLabel, onPressed: widget.onNext),
        const SizedBox(height: 12),
        DopButton.link(label: l10n.skipLabel, onPressed: widget.onSkip),
      ],
    );
  }
}

class _StaggeredText extends StatelessWidget {
  const _StaggeredText({
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

class _SignalStrip extends StatelessWidget {
  const _SignalStrip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.voidBlack,
        border: Border.all(color: colors.ink),
      ),
      child: DopText.label(label, color: colors.onVoid),
    );
  }
}

class _ReadinessStep extends StatefulWidget {
  const _ReadinessStep({
    required this.controller,
    required this.onNext,
    required this.onSkip,
  });

  final OnboardingController controller;
  final VoidCallback onNext;
  final Future<void> Function() onSkip;

  @override
  State<_ReadinessStep> createState() => _ReadinessStepState();
}

class _ReadinessStepState extends State<_ReadinessStep>
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
        _StaggeredText(
          animation: _entrance,
          start: 0,
          child: DopText.header(l10n.onboardingReadinessTitle),
        ),
        const SizedBox(height: 12),
        _StaggeredText(
          animation: _entrance,
          start: 0.18,
          child: DopText.body(
            l10n.onboardingReadinessBody,
            color: colors.inkSoft,
          ),
        ),
        const SizedBox(height: 44),
        _StaggeredText(
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
        const SizedBox(height: 42),
        DopButton.primary(label: l10n.continueLabel, onPressed: widget.onNext),
        const SizedBox(height: 12),
        DopButton.link(label: l10n.skipLabel, onPressed: widget.onSkip),
      ],
    );
  }
}

class _AccessStep extends StatefulWidget {
  const _AccessStep({
    required this.controller,
    required this.onSkip,
    required this.onFinish,
  });

  final OnboardingController controller;
  final Future<void> Function() onSkip;
  final Future<void> Function() onFinish;

  @override
  State<_AccessStep> createState() => _AccessStepState();
}

class _AccessStepState extends State<_AccessStep>
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
    final loading = controller.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaggeredText(
          animation: _entrance,
          start: 0,
          child: DopText.header(l10n.onboardingSetupTitle),
        ),
        const SizedBox(height: 12),
        _StaggeredText(
          animation: _entrance,
          start: 0.18,
          child: DopText.body(l10n.onboardingSetupBody, color: colors.inkSoft),
        ),
        const SizedBox(height: 28),
        _StaggeredText(
          animation: _entrance,
          start: 0.36,
          child: _PermissionSection(
            label: l10n.healthAccessLabel,
            status: controller.healthAccessStatus,
            statusText: _healthStatusText(l10n, controller.healthAccessStatus),
            grantLabel: l10n.healthAccessGrant,
            onGrant: loading ? null : controller.requestHealthAccess,
          ),
        ),
        const SizedBox(height: 16),
        _StaggeredText(
          animation: _entrance,
          start: 0.5,
          child: _PermissionSection(
            label: l10n.setupAccessLabel,
            status: controller.setupAccessStatus,
            statusText: _setupStatusText(l10n, controller.setupAccessStatus),
            grantLabel: l10n.setupAccessGrant,
            onGrant: loading ? null : controller.requestSetupAccess,
          ),
        ),
        const SizedBox(height: 30),
        DopButton.primary(
          label: l10n.finishLabel,
          onPressed: loading ? null : () => widget.onFinish(),
        ),
        const SizedBox(height: 12),
        DopButton.link(
          label: l10n.skipLabel,
          onPressed: loading ? null : widget.onSkip,
        ),
      ],
    );
  }

  String _healthStatusText(AppLocalizations l10n, PermissionStatus status) =>
      switch (status) {
        PermissionStatus.idle => l10n.healthAccessIdle,
        PermissionStatus.requesting => l10n.healthAccessRequesting,
        PermissionStatus.granted => l10n.healthAccessGranted,
        PermissionStatus.denied => l10n.healthAccessDenied,
        PermissionStatus.unsupported => l10n.healthAccessUnsupported,
      };

  String _setupStatusText(AppLocalizations l10n, PermissionStatus status) =>
      switch (status) {
        PermissionStatus.idle => l10n.setupAccessIdle,
        PermissionStatus.requesting => l10n.setupAccessRequesting,
        PermissionStatus.granted => l10n.setupAccessGranted,
        PermissionStatus.denied => l10n.setupAccessDenied,
        PermissionStatus.unsupported => l10n.setupAccessUnsupported,
      };
}

/// One permission: label, current status, and a grant action while idle.
class _PermissionSection extends StatelessWidget {
  const _PermissionSection({
    required this.label,
    required this.status,
    required this.statusText,
    required this.grantLabel,
    required this.onGrant,
  });

  final String label;
  final PermissionStatus status;
  final String statusText;
  final String grantLabel;
  final VoidCallback? onGrant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = switch (status) {
      PermissionStatus.idle => 'IDLE',
      PermissionStatus.requesting => '...',
      PermissionStatus.granted => 'ON',
      PermissionStatus.denied => 'OFF',
      PermissionStatus.unsupported => 'N/A',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: colors.line),
        color: colors.paper,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DopText.label(label)),
              DopText.bodyBold(
                value,
                color: status == PermissionStatus.granted
                    ? colors.accent
                    : colors.ink,
              ),
            ],
          ),
          const SizedBox(height: 10),
          DopText.body(statusText, color: colors.inkSoft),
          if (status == PermissionStatus.idle) ...[
            const SizedBox(height: 14),
            DopButton.outline(label: grantLabel, onPressed: onGrant),
          ],
        ],
      ),
    );
  }
}
