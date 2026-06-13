import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/l10n.dart';
import '../../../domain/entities/permission_status.dart';
import '../../controller/onboarding_controller.dart';
import '../widgets/onboarding_motion.dart';
import '../widgets/permission_section.dart';

class AccessStep extends StatefulWidget {
  const AccessStep({super.key, required this.controller});

  final OnboardingController controller;

  @override
  State<AccessStep> createState() => _AccessStepState();
}

class _AccessStepState extends State<AccessStep>
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
        StaggeredText(
          animation: _entrance,
          start: 0,
          child: DopText.header(l10n.onboardingSetupTitle),
        ),
        const SizedBox(height: 12),
        StaggeredText(
          animation: _entrance,
          start: 0.18,
          child: DopText.body(l10n.onboardingSetupBody, color: colors.inkSoft),
        ),
        const SizedBox(height: 28),
        StaggeredText(
          animation: _entrance,
          start: 0.36,
          child: PermissionSection(
            label: l10n.healthAccessLabel,
            status: controller.healthAccessStatus,
            statusText: _healthStatusText(l10n, controller.healthAccessStatus),
            grantLabel: l10n.healthAccessGrant,
            onGrant: loading ? null : controller.requestHealthAccess,
          ),
        ),
        const SizedBox(height: 16),
        StaggeredText(
          animation: _entrance,
          start: 0.5,
          child: PermissionSection(
            label: l10n.setupAccessLabel,
            status: controller.setupAccessStatus,
            statusText: _setupStatusText(l10n, controller.setupAccessStatus),
            grantLabel: l10n.setupAccessGrant,
            onGrant: loading ? null : controller.requestSetupAccess,
          ),
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
