import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../domain/entities/focus_dimension.dart';
import '../domain/entities/sound_layer.dart';
import '../domain/usecases/select_dimension.dart';
import '../domain/usecases/set_layer_level.dart';
import '../domain/usecases/set_temporal_distortion.dart';
import '../domain/usecases/start_ambience.dart';
import '../domain/usecases/stop_ambience.dart';
import 'controller/focus_controller.dart';

/// Focus mode: a reactive orb, five ambient-sound knobs, an acoustic dimension
/// selector, a task line and a session timer. Recreated from the HTML reference.
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
      startAmbience: injector.get<StartAmbience>(),
      setLayerLevel: injector.get<SetLayerLevel>(),
      setTemporalDistortion: injector.get<SetTemporalDistortion>(),
      selectDimension: injector.get<SelectDimension>(),
      stopAmbience: injector.get<StopAmbience>(),
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
                    Row(
                      children: [
                        DopText.label('DOPAMINE'),
                        DopText.label('120', color: colors.accent),
                      ],
                    ),
                    DopText.label(l10n.focusEyebrow, color: colors.inkFaint),
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
                            dimension: _controller.dimension.orbDimension,
                            onDistortionChanged:
                                _controller.setTemporalDistortion,
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
                        const SizedBox(height: 16),
                        DopText.caption(
                          l10n.focusKnobHint,
                          align: TextAlign.center,
                          color: colors.inkFaint,
                        ),
                        const SizedBox(height: 24),
                        DopDropdown<FocusDimension>(
                          label: l10n.focusDimensionLabel,
                          value: _controller.dimension,
                          onChanged: _controller.selectDimension,
                          options: [
                            for (final dimension in FocusDimension.values)
                              DopDropdownOption(
                                value: dimension,
                                label: dimension.label,
                                subtitle: dimension.description,
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

/// The five ambient knobs in the reference order.
class _KnobRow extends StatelessWidget {
  const _KnobRow({required this.controller});

  final FocusController controller;

  static const Map<SoundLayer, IconData> _icons = {
    SoundLayer.drone: Icons.graphic_eq,
    SoundLayer.rain: Icons.grain,
    SoundLayer.pulse: Icons.show_chart,
    SoundLayer.bell: Icons.notifications_none,
    SoundLayer.cicada: Icons.blur_on,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final layer in SoundLayer.values)
          DopKnob(
            value: controller.levelOf(layer),
            icon: Icon(_icons[layer]),
            label: layer.name,
            onChange: (value) => controller.setLayer(layer, value),
          ),
      ],
    );
  }
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
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            border: Border.fromBorderSide(DopStroke.hairlineSide(colors.line)),
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
