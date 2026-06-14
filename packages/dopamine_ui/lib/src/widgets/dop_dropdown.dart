import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/context_ext.dart';
import '../theme/dop_spacing.dart';
import '../theme/dop_stroke.dart';
import 'dop_text.dart';

/// Direction used by [DopDropdown] when opening its option panel.
enum DopDropdownMenuDirection {
  /// Opens the panel above the control.
  up,

  /// Opens the panel below the control.
  down,
}

/// A selectable value shown by [DopDropdown].
class DopDropdownOption<T> {
  const DopDropdownOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  /// Value emitted through [DopDropdown.onChanged].
  final T value;

  /// Primary option text.
  final String label;

  /// Secondary option text, shown below [label].
  final String? subtitle;

  /// Disabled options render dimmed and do not emit changes.
  final bool enabled;
}

/// Hard-edged DOPAMINE120 dropdown with a mono label and an inverted selection.
class DopDropdown<T> extends StatefulWidget {
  const DopDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.menuDirection = DopDropdownMenuDirection.up,
    this.menuGap = 12,
    this.menuMaxHeight,
    this.semanticLabel,
  }) : assert(menuGap >= 0);

  /// Label rendered on the left side of the control.
  final String label;

  /// Currently selected value.
  final T value;

  /// Values available in the option panel.
  final List<DopDropdownOption<T>> options;

  /// Emits a newly selected value. Null disables the dropdown.
  final ValueChanged<T>? onChanged;

  /// Where to place the option panel relative to the control.
  final DopDropdownMenuDirection menuDirection;

  /// Space between the control and the option panel.
  final double menuGap;

  /// Optional maximum height for the option panel.
  final double? menuMaxHeight;

  /// Accessibility label for the control.
  final String? semanticLabel;

  @override
  State<DopDropdown<T>> createState() => _DopDropdownState<T>();
}

class _DopDropdownState<T> extends State<DopDropdown<T>> {
  final _link = LayerLink();
  final _controlKey = GlobalKey();
  OverlayEntry? _entry;
  Size _controlSize = Size.zero;
  double? _availableMenuHeight;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;
  bool get _open => _entry != null;

  DopDropdownOption<T> get _selectedOption {
    for (final option in widget.options) {
      if (option.value == widget.value) return option;
    }
    return widget.options.first;
  }

  @override
  void didUpdateWidget(covariant DopDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && _open) _close();
    _entry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.options.isNotEmpty,
      'DopDropdown requires at least one option.',
    );
    final colors = context.colors;
    final selected = _selectedOption;

    return CompositedTransformTarget(
      link: _link,
      child: Semantics(
        button: true,
        enabled: _enabled,
        label: widget.semanticLabel ?? widget.label,
        value: selected.label,
        onTap: _enabled ? _toggle : null,
        child: GestureDetector(
          key: _controlKey,
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _toggle : null,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 80),
            opacity: !_enabled
                ? 0.45
                : _pressed
                ? 0.72
                : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DopSpacing.lg,
                vertical: DopSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.paper,
                border: Border.fromBorderSide(
                  DopStroke.outlineSide(colors.ink),
                ),
              ),
              child: Row(
                children: [
                  DopText.label(widget.label),
                  const SizedBox(width: DopSpacing.md),
                  Expanded(
                    child: Text(
                      selected.label,
                      style: context.typo.control,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: DopSpacing.sm),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    child: Text(
                      '▾',
                      style: context.typo.controlSecondary.copyWith(
                        color: colors.inkFaint,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggle() {
    if (!_enabled) return;
    _open ? _close() : _openMenu();
  }

  void _openMenu() {
    final box = _controlKey.currentContext?.findRenderObject() as RenderBox?;
    _controlSize = box?.size ?? Size.zero;
    final top = box?.localToGlobal(Offset.zero).dy ?? 0;
    final bottom = top + _controlSize.height;
    final screenHeight = MediaQuery.sizeOf(context).height;
    _availableMenuHeight = widget.menuDirection == DopDropdownMenuDirection.up
        ? top - widget.menuGap
        : screenHeight - bottom - widget.menuGap;

    _entry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final opensUp = widget.menuDirection == DopDropdownMenuDirection.up;
    final targetAnchor = opensUp ? Alignment.topLeft : Alignment.bottomLeft;
    final followerAnchor = opensUp ? Alignment.bottomLeft : Alignment.topLeft;
    final offset = Offset(0, opensUp ? -widget.menuGap : widget.menuGap);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: targetAnchor,
          followerAnchor: followerAnchor,
          offset: offset,
          child: Material(
            color: Colors.transparent,
            child: _DopDropdownMenu<T>(
              width: _controlSize.width,
              maxHeight: _effectiveMenuMaxHeight(),
              value: widget.value,
              options: widget.options,
              onSelected: _select,
            ),
          ),
        ),
      ],
    );
  }

  double? _effectiveMenuMaxHeight() {
    final available = _availableMenuHeight;
    final requested = widget.menuMaxHeight;
    if (available == null || available <= 0) return requested;
    if (requested == null) return available;
    return requested.clamp(0, available).toDouble();
  }

  void _select(DopDropdownOption<T> option) {
    if (!option.enabled) return;
    HapticFeedback.selectionClick();
    _close();
    if (option.value != widget.value) widget.onChanged?.call(option.value);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }
}

class _DopDropdownMenu<T> extends StatelessWidget {
  const _DopDropdownMenu({
    required this.width,
    required this.maxHeight,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final double width;
  final double? maxHeight;
  final T value;
  final List<DopDropdownOption<T>> options;
  final ValueChanged<DopDropdownOption<T>> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < options.length; i++)
          _DopDropdownOptionRow<T>(
            option: options[i],
            selected: options[i].value == value,
            divider: i != options.length - 1,
            onSelected: onSelected,
          ),
      ],
    );

    return Container(
      width: width,
      constraints: maxHeight == null
          ? null
          : BoxConstraints(maxHeight: maxHeight!),
      decoration: BoxDecoration(
        color: colors.paper,
        border: Border.fromBorderSide(DopStroke.outlineSide(colors.ink)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 26,
            offset: Offset(0, -8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: maxHeight == null
          ? rows
          : SingleChildScrollView(padding: EdgeInsets.zero, child: rows),
    );
  }
}

class _DopDropdownOptionRow<T> extends StatelessWidget {
  const _DopDropdownOptionRow({
    required this.option,
    required this.selected,
    required this.divider,
    required this.onSelected,
  });

  final DopDropdownOption<T> option;
  final bool selected;
  final bool divider;
  final ValueChanged<DopDropdownOption<T>> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.onVoid : colors.ink;
    final secondary = selected ? colors.onVoidSoft : colors.inkFaint;
    final enabledOpacity = option.enabled ? 1.0 : 0.42;

    return Semantics(
      button: true,
      selected: selected,
      enabled: option.enabled,
      label: option.subtitle == null
          ? option.label
          : '${option.label}, ${option.subtitle}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: option.enabled ? () => onSelected(option) : null,
        child: Opacity(
          opacity: enabledOpacity,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: DopSpacing.lg,
              vertical: DopSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected ? colors.ink : colors.paper,
              border: divider
                  ? Border(bottom: DopStroke.hairlineSide(colors.line))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: context.typo.control.copyWith(color: foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (option.subtitle != null) ...[
                  const SizedBox(height: DopSpacing.xxs),
                  Text(
                    option.subtitle!,
                    style: context.typo.controlSecondary.copyWith(
                      color: secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
