import 'package:flutter/material.dart';

import '../feedback/dop_haptic_feedback.dart';
import '../theme/context_ext.dart';

/// A selectable value shown by [DopSegmentedControl].
class DopSegmentedOption<T> {
  const DopSegmentedOption({required this.value, required this.label});

  /// Value emitted through [DopSegmentedControl.onChanged].
  final T value;

  /// Segment text.
  final String label;
}

/// Hard-edged single-select segmented control for compact mode switching.
class DopSegmentedControl<T> extends StatelessWidget {
  const DopSegmentedControl({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.semanticLabel,
  }) : assert(options.length > 0);

  /// Currently selected value.
  final T value;

  /// Values available in the control.
  final List<DopSegmentedOption<T>> options;

  /// Emits a newly selected value. Null disables the control.
  final ValueChanged<T>? onChanged;

  /// Accessibility label for the whole control.
  final String? semanticLabel;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final stroke = context.stroke;
    final selectedLabel = options
        .firstWhere(
          (option) => option.value == value,
          orElse: () => options.first,
        )
        .label;

    return Semantics(
      container: true,
      enabled: _enabled,
      label: semanticLabel,
      value: selectedLabel,
      child: Opacity(
        opacity: _enabled ? 1 : 0.45,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.paper,
            borderRadius: context.radius.controlGeometry,
            border: Border.fromBorderSide(stroke.outlineSide(colors.ink)),
          ),
          child: ClipRRect(
            borderRadius: context.radius.controlGeometry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      width: stroke.hairline,
                      height: 32,
                      child: ColoredBox(color: colors.ink),
                    ),
                  _DopSegment<T>(
                    option: options[i],
                    selected: options[i].value == value,
                    enabled: _enabled,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    onSelected: _select,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(DopSegmentedOption<T> option) {
    if (!_enabled || option.value == value) return;
    DopHapticFeedback.selection();
    onChanged!(option.value);
  }
}

class _DopSegment<T> extends StatelessWidget {
  const _DopSegment({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.padding,
    required this.onSelected,
  });

  final DopSegmentedOption<T> option;
  final bool selected;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final ValueChanged<DopSegmentedOption<T>> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.paper : colors.ink;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: option.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onSelected(option) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          color: selected ? colors.ink : colors.paper,
          padding: padding,
          child: Text(
            option.label,
            style: context.typo.control.copyWith(color: foreground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
