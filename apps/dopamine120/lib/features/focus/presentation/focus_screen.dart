import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../../core/theme/domain/entities/app_theme.dart';
import '../../../core/theme/presentation/theme_provider.dart';
import '../../../l10n/l10n.dart';
import '../domain/usecases/set_scene_dimension.dart';
import '../domain/usecases/set_scene_knob.dart';
import '../domain/usecases/set_temporal_distortion.dart';
import '../domain/usecases/start_ambience.dart';
import '../domain/usecases/stop_ambience.dart';
import '../domain/usecases/watch_scene_sound_events.dart';
import 'controller/focus_controller.dart';

/// Focus mode: a reactive orb, configured focus-scene knobs, an acoustic
/// dimension selector, a task line and a session timer.
@RoutePage()
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  late final FocusController _controller;
  late final TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    final injector = DependencyScope.of(context);
    _controller = FocusController(
      scene: injector.get<SceneConfig>(),
      startAmbience: injector.get<StartAmbience>(),
      setSceneKnob: injector.get<SetSceneKnob>(),
      setSceneDimension: injector.get<SetSceneDimension>(),
      setTemporalDistortion: injector.get<SetTemporalDistortion>(),
      stopAmbience: injector.get<StopAmbience>(),
      watchSceneSoundEvents: injector.get<WatchSceneSoundEvents>(),
    );
    _taskController = TextEditingController();
    _controller.startTimer();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Switches the configured focus-scene dimension and dresses the app theme
  /// with the same id (`room`, `cathedral`, ...).
  void _selectDimension(String dimensionId) {
    _controller.selectDimension(dimensionId);
    context.themeController.setTheme(AppTheme.fromStorageValue(dimensionId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _controller.primeAudio(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DopBackButton(
                      onPressed: () {
                        context.router.pop();
                      },
                    ),
                    Row(
                      children: [
                        DopText.label(
                          l10n.focusEyebrow,
                          color: colors.inkFaint,
                        ),
                        const SizedBox(width: 16),
                        _MuteButton(controller: _controller),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Orb, knobs and the dimension selector share the controller's
                // structural state; the per-second timer is intentionally left
                // out so it can repaint on its own (see the chip below).
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: DopFocusOrb(
                            knobs: _controller.knobs,
                            controller: _controller.orbController,
                            dimension: _controller.orbDimension,
                            onDistortionChanged: _controller.setOrbDistortion,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DopText.header(
                          l10n.focusTitle,
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        DopInput(
                          label: l10n.focusTaskLabel,
                          hint: l10n.focusTaskHint,
                          controller: _taskController,
                          onChanged: _controller.setTask,
                        ),
                        const SizedBox(height: 28),
                        _KnobRow(controller: _controller),
                        SizedBox(height: context.spacing.lg),
                        DopDropdown<String>(
                          label: l10n.focusDimensionLabel,
                          value: _controller.dimensionId,
                          onChanged: _selectDimension,
                          options: [
                            for (final filter in _controller.scene.filters)
                              DopDropdownOption(
                                value: filter.id,
                                label: _orbDimensionFor(filter.id).label,
                                subtitle: _orbDimensionFor(
                                  filter.id,
                                ).description,
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: _controller.remaining,
                    builder: (context, remaining, _) {
                      return _TimerChip(
                        label: FocusController.formatDuration(remaining),
                        semanticLabel: l10n.focusTimerReset,
                        onTap: _controller.startTimer,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggles the ambient mix between silent and audible, reflecting the
/// controller's mute state with its icon.
class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.controller});

  final FocusController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final muted = controller.isMuted;
        return Semantics(
          button: true,
          label: muted ? l10n.focusUnmute : l10n.focusMute,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.toggleMute,
            child: Icon(
              muted ? Icons.volume_off : Icons.volume_up,
              size: 20,
              color: muted ? colors.inkFaint : colors.ink,
            ),
          ),
        );
      },
    );
  }
}

/// The configured focus-scene knobs.
class _KnobRow extends StatelessWidget {
  const _KnobRow({required this.controller});

  final FocusController controller;

  static const Map<String, IconData> _icons = {
    'drone': Icons.graphic_eq,
    'rain': Icons.grain,
    'pulse': Icons.show_chart,
    'bell': Icons.notifications_none,
    'cicada': Icons.blur_on,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final knob in controller.scene.knobs)
          DopKnob(
            value: controller.knobValue(knob.id),
            icon: Icon(_icons[knob.id] ?? Icons.tune),
            label: knob.id,
            onChange: (value) => controller.setKnob(knob.id, value),
          ),
      ],
    );
  }
}

DopFocusOrbDimension _orbDimensionFor(String dimensionId) {
  return DopFocusOrbDimension.values.firstWhere(
    (dimension) => dimension.name == dimensionId,
    orElse: () => DopFocusOrbDimension.room,
  );
}

/// Rounded, tappable countdown chip that resets the session on tap.
class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stroke = context.stroke;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            border: Border.fromBorderSide(stroke.hairlineSide(colors.line)),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: context.typo.control.copyWith(letterSpacing: 3),
          ),
        ),
      ),
    );
  }
}
