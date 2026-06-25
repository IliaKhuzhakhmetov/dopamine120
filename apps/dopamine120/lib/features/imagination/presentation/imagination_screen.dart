import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../../core/theme/domain/entities/app_theme.dart';
import '../../../core/theme/presentation/theme_provider.dart';
import '../../../l10n/l10n.dart';
import '../../application/presentation/router/app_router.dart';
import '../domain/usecases/play_imagination_cue.dart';
import '../domain/usecases/set_imagination_drone.dart';
import '../domain/usecases/set_imagination_theme.dart';
import '../domain/usecases/start_imagination_audio.dart';
import '../domain/usecases/stop_imagination_audio.dart';
import 'controller/imagination_controller.dart';

@RoutePage()
class ImaginationScreen extends StatefulWidget {
  const ImaginationScreen({super.key});

  @override
  State<ImaginationScreen> createState() => _ImaginationScreenState();
}

class _ImaginationScreenState extends State<ImaginationScreen> {
  late final ImaginationController _controller;

  @override
  void initState() {
    super.initState();
    final injector = DependencyScope.of(context);
    _controller = ImaginationController(
      startAudio: injector.get<StartImaginationAudio>(),
      setDrone: injector.get<SetImaginationDrone>(),
      setTheme: injector.get<SetImaginationTheme>(),
      playCue: injector.get<PlayImaginationCue>(),
      stopAudio: injector.get<StopImaginationAudio>(),
      backgroundAudioSession: injector.get<BackgroundAudioSession>(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.themeController.setTheme(AppTheme.room);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Theme(
          data: DopTheme.fromSpec(DopThemes.byId(_controller.selectedThemeId)),
          child: Builder(
            builder: (context) {
              final colors = context.colors;
              final l10n = context.l10n;

              return Scaffold(
                backgroundColor: colors.wall,
                body: SafeArea(
                  child: DopResponsivePane(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DopAppBar(
                            onBack: () => context.router.pop(),
                            title: l10n.imaginationEyebrow,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _TimerChip(
                                  label: _controller.remainingLabel,
                                  semanticLabel: l10n.imaginationTimerLabel,
                                ),
                                SizedBox(width: context.spacing.md),
                                _MuteButton(controller: _controller),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          DopText.header(l10n.imaginationTitle),
                          const SizedBox(height: 12),
                          DopText.body(
                            l10n.imaginationBody,
                            color: colors.inkSoft,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 340,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.line),
                              ),
                              child: BlockFieldWidget(
                                controller: _controller.blockController,
                                padding: const EdgeInsets.all(18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ControlsGrid(controller: _controller),
                          const SizedBox(height: 20),
                          DopDropdown<String>(
                            label: l10n.imaginationThemeLabel,
                            value: _controller.selectedThemeId,
                            menuDirection: DopDropdownMenuDirection.up,
                            options: [
                              for (final id in ImaginationController.themeIds)
                                DopDropdownOption(
                                  value: id,
                                  label: DopThemes.byId(id).label,
                                  subtitle: DopThemes.byId(id).description,
                                ),
                            ],
                            onChanged: _selectTheme,
                          ),
                          const SizedBox(height: 20),
                          DopSlider(
                            value: _controller.droneDb,
                            min: ImaginationController.minDroneDb,
                            max: ImaginationController.maxDroneDb,
                            step: 1,
                            label: l10n.imaginationDroneLabel,
                            minLabel: _dbLabel(
                              ImaginationController.minDroneDb,
                            ),
                            maxLabel: _dbLabel(
                              ImaginationController.maxDroneDb,
                            ),
                            semanticLabel: l10n.imaginationDroneLabel,
                            valueFormatter: _dbLabel,
                            leadingIcon: Icon(context.icons.muted),
                            trailingIcon: Icon(context.icons.unmuted),
                            onChanged: _controller.setDroneDb,
                          ),
                          const SizedBox(height: 24),
                          _ActionButtons(
                            controller: _controller,
                            onGoFocus: _goFocus,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _selectTheme(String themeId) {
    _controller.setTheme(themeId);
    context.themeController.setTheme(AppTheme.fromStorageValue(themeId));
  }

  void _goFocus() {
    context.router.replace(
      FocusRoute(
        initialTheme: AppTheme.fromStorageValue(_controller.selectedThemeId),
      ),
    );
  }
}

class _ControlsGrid extends StatelessWidget {
  const _ControlsGrid({required this.controller});

  final ImaginationController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: context.spacing.md,
      runSpacing: context.spacing.md,
      children: [
        _ControlGroup(
          label: l10n.imaginationModeLabel,
          child: DopSegmentedControl<BlockFieldMode>(
            value: controller.blockController.mode,
            semanticLabel: l10n.imaginationModeLabel,
            options: [
              DopSegmentedOption(
                value: BlockFieldMode.spawn,
                label: l10n.imaginationModeAdd,
              ),
              DopSegmentedOption(
                value: BlockFieldMode.delete,
                label: l10n.imaginationModeDelete,
              ),
            ],
            onChanged: controller.setMode,
          ),
        ),
        _ControlGroup(
          label: l10n.imaginationTypeLabel,
          child: DopSegmentedControl<BlockType>(
            value: controller.blockController.selectedType,
            semanticLabel: l10n.imaginationTypeLabel,
            options: [
              DopSegmentedOption(
                value: BlockType.core,
                label: l10n.imaginationTypeCore,
              ),
              DopSegmentedOption(
                value: BlockType.glass,
                label: l10n.imaginationTypeGlass,
              ),
              DopSegmentedOption(
                value: BlockType.goo,
                label: l10n.imaginationTypeGoo,
              ),
            ],
            onChanged: controller.setType,
          ),
        ),
      ],
    );
  }
}

class _ControlGroup extends StatelessWidget {
  const _ControlGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DopText.label(label, color: context.colors.inkFaint),
        SizedBox(height: context.spacing.xs),
        child,
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller, required this.onGoFocus});

  final ImaginationController controller;
  final VoidCallback onGoFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        DopButton.outline(
          label: l10n.imaginationStart,
          onPressed: controller.isStarted ? null : controller.start,
        ),
        const SizedBox(height: 12),
        if (controller.canGoNext)
          DopButton.primary(label: l10n.imaginationNext, onPressed: onGoFocus)
        else
          DopButton.link(label: l10n.imaginationSkip, onPressed: onGoFocus),
      ],
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.controller});

  final ImaginationController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final muted = controller.isMuted;
    return Semantics(
      button: true,
      label: muted ? l10n.imaginationUnmute : l10n.imaginationMute,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleMute,
        child: Icon(
          muted ? context.icons.muted : context.icons.unmuted,
          size: 20,
          color: muted ? colors.inkFaint : colors.ink,
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.label, required this.semanticLabel});

  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel,
      value: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colors.line),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: context.typo.control.copyWith(letterSpacing: 2),
        ),
      ),
    );
  }
}

String _dbLabel(double value) => '${value.round()} dB';
