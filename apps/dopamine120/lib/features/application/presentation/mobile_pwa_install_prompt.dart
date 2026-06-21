import 'dart:async';

import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../domain/usecases/is_mobile_pwa_install_prompt_dismissed.dart';
import '../domain/usecases/mark_mobile_pwa_install_prompt_dismissed.dart';

enum MobilePwaInstallPlatform { ios, android }

MobilePwaInstallPlatform? mobilePwaInstallPlatform({
  required bool isWeb,
  required TargetPlatform platform,
}) {
  if (!isWeb) return null;
  return switch (platform) {
    TargetPlatform.iOS => MobilePwaInstallPlatform.ios,
    TargetPlatform.android => MobilePwaInstallPlatform.android,
    _ => null,
  };
}

class MobilePwaInstallPrompt extends StatefulWidget {
  const MobilePwaInstallPrompt({
    super.key,
    required this.child,
    this.isWeb = kIsWeb,
    this.platform,
  });

  final Widget child;
  final bool isWeb;
  final TargetPlatform? platform;

  @override
  State<MobilePwaInstallPrompt> createState() => _MobilePwaInstallPromptState();
}

class _MobilePwaInstallPromptState extends State<MobilePwaInstallPrompt> {
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    unawaited(_showIfNeeded());
  }

  Future<void> _showIfNeeded() async {
    final platform = mobilePwaInstallPlatform(
      isWeb: widget.isWeb,
      platform: widget.platform ?? defaultTargetPlatform,
    );
    if (platform == null) return;

    final isDismissed = await context
        .get<IsMobilePwaInstallPromptDismissed>()
        .call(const NoParams());
    if (!mounted || isDismissed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = context.l10n;
      showDopSnackBar(
        context: context,
        title: l10n.mobilePwaInstallTitle,
        message: switch (platform) {
          MobilePwaInstallPlatform.ios => l10n.mobilePwaInstallIosBody,
          MobilePwaInstallPlatform.android => l10n.mobilePwaInstallAndroidBody,
        },
        actionLabel: l10n.mobilePwaInstallAction,
        onAction: () {
          unawaited(
            context.get<MarkMobilePwaInstallPromptDismissed>().call(
              const NoParams(),
            ),
          );
        },
        leading: const Icon(Icons.add_to_home_screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
