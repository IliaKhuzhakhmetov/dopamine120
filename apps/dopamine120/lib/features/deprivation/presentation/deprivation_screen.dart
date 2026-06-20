import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../core/theme/domain/entities/app_theme.dart';
import '../../../core/theme/presentation/theme_provider.dart';
import '../../application/presentation/router/app_router.dart';
import '../domain/entities/deprivation_mask.dart';
import '../domain/usecases/set_deprivation_mask_volume.dart';
import '../domain/usecases/start_deprivation_mask.dart';
import '../domain/usecases/stop_deprivation_mask.dart';
import 'controller/deprivation_controller.dart';

@RoutePage()
class DeprivationScreen extends StatefulWidget {
  const DeprivationScreen({super.key});

  @override
  State<DeprivationScreen> createState() => _DeprivationScreenState();
}

class _DeprivationScreenState extends State<DeprivationScreen> {
  late final DeprivationController _controller;

  @override
  void initState() {
    super.initState();
    final injector = DependencyScope.of(context);
    _controller = DeprivationController(
      startMask: injector.get<StartDeprivationMask>(),
      setMaskVolume: injector.get<SetDeprivationMaskVolume>(),
      stopMask: injector.get<StopDeprivationMask>(),
      onCompleted: () {
        if (mounted) context.router.replace(FocusRoute());
      },
    );

    // set deprivation theme on init to avoid flash of default theme on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.themeController.setTheme(AppTheme.deprivation);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DopTheme.fromSpec(DopThemes.deprivation),
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final l10n = context.l10n;

          return Scaffold(
            backgroundColor: colors.wall,
            body: SafeArea(
              child: DopResponsivePane(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DopAppBar(
                              onBack: () => context.router.pop(),
                              title: l10n.deprivationEyebrow,
                            ),
                            const SizedBox(height: 20),
                            DopText.header(l10n.deprivationTitle),
                            const SizedBox(height: 12),
                            DopText.body(
                              l10n.deprivationBody,
                              color: colors.inkSoft,
                            ),
                            const SizedBox(height: 40),
                            Text(
                              _controller.remainingLabel,
                              style: context.typo.giant.copyWith(
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 36),
                            SizedBox(
                              height: 48,
                              child: Row(
                                spacing: context.spacing.lg,
                                children: [
                                  Expanded(
                                    child: DopDropdown<Duration>(
                                      label: l10n.deprivationDurationLabel,
                                      value: _controller.duration,
                                      options: [
                                        for (final duration
                                            in DeprivationController
                                                .durationOptions)
                                          DopDropdownOption(
                                            value: duration,
                                            label: _durationLabel(
                                              l10n,
                                              duration,
                                            ),
                                          ),
                                      ],
                                      onChanged: _controller.setDuration,
                                    ),
                                  ),
                                  Expanded(
                                    child: DopDropdown<DeprivationMask>(
                                      label: l10n.deprivationMaskLabel,
                                      value: _controller.mask,
                                      menuDirection:
                                          DopDropdownMenuDirection.down,
                                      options: [
                                        for (final mask
                                            in DeprivationMask.values)
                                          DopDropdownOption(
                                            value: mask,
                                            label: _maskLabel(l10n, mask),
                                          ),
                                      ],
                                      onChanged: _controller.setMask,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            DopSlider(
                              value: _controller.maskVolume,
                              min: DeprivationController.minMaskVolumeDb,
                              max: DeprivationController.maxMaskVolumeDb,
                              step: 1,
                              label: l10n.deprivationVolumeLabel,
                              minLabel: _dbLabel(
                                DeprivationController.minMaskVolumeDb,
                              ),
                              maxLabel: _dbLabel(
                                DeprivationController.maxMaskVolumeDb,
                              ),
                              semanticLabel: l10n.deprivationVolumeLabel,
                              valueFormatter: _dbLabel,
                              leadingIcon: Icon(context.icons.muted),
                              trailingIcon: Icon(context.icons.unmuted),
                              onChanged: _controller.setMaskVolume,
                            ),
                            const SizedBox(height: 28),
                            _Controls(controller: _controller),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final DeprivationController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        if (!controller.isStarted)
          DopButton.outline(
            label: l10n.deprivationStart,
            onPressed: controller.start,
          )
        else if (controller.isPaused)
          DopButton.outline(
            label: l10n.deprivationResume,
            onPressed: controller.resume,
          )
        else
          DopButton.outline(
            label: l10n.deprivationPause,
            onPressed: controller.pause,
          ),
        const SizedBox(height: 12),
        DopButton.link(
          label: l10n.deprivationEnd,
          onPressed: controller.isCompleted ? null : controller.end,
        ),
      ],
    );
  }
}

String _durationLabel(AppLocalizations l10n, Duration duration) {
  return switch (duration.inMinutes) {
    15 => l10n.deprivationDuration15,
    30 => l10n.deprivationDuration30,
    45 => l10n.deprivationDuration45,
    _ => '${duration.inMinutes} min',
  };
}

String _maskLabel(AppLocalizations l10n, DeprivationMask mask) {
  return switch (mask) {
    DeprivationMask.silence => l10n.deprivationMaskSilence,
    DeprivationMask.pink => l10n.deprivationMaskPink,
    DeprivationMask.brown => l10n.deprivationMaskBrown,
    DeprivationMask.rain => l10n.deprivationMaskRain,
  };
}

String _dbLabel(double value) => '${value.round()} dB';
