import 'package:flutter/material.dart';

import '../theme/context_ext.dart';

/// Controlled DOPAMINE120 checkbox control.
class DopCheckbox extends StatefulWidget {
  const DopCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled,
    this.semanticLabel,
  });

  /// Whether the checkbox is selected.
  final bool value;

  /// Called with the next value when this checkbox is tapped.
  final ValueChanged<bool>? onChanged;

  /// Whether the checkbox should render enabled.
  ///
  /// When null, follows Material's convention: a checkbox without [onChanged]
  /// renders disabled.
  final bool? enabled;

  /// Accessible label for standalone checkbox usage.
  final String? semanticLabel;

  @override
  State<DopCheckbox> createState() => _DopCheckboxState();
}

class _DopCheckboxState extends State<DopCheckbox> {
  bool _pressed = false;

  bool get _enabled => widget.enabled ?? widget.onChanged != null;

  bool get _interactive => _enabled && widget.onChanged != null;

  void _toggle() {
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = _enabled;
    final borderColor = enabled ? colors.inkSoft : colors.inkFaint;

    final mark = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: widget.value ? colors.ink : Colors.transparent,
        border: Border.all(
          color: widget.value ? colors.ink : borderColor,
          width: 1.5,
        ),
      ),
      child: widget.value
          ? Icon(Icons.check, color: colors.wall, size: 16)
          : null,
    );

    return Semantics(
      button: _interactive,
      checked: widget.value,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _interactive ? _toggle : null,
        onTapDown: _interactive ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _interactive ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _interactive
            ? () => setState(() => _pressed = false)
            : null,
        child: AnimatedOpacity(
          opacity: !enabled
              ? 0.45
              : _pressed
              ? 0.6
              : 1,
          duration: const Duration(milliseconds: 80),
          child: mark,
        ),
      ),
    );
  }
}
