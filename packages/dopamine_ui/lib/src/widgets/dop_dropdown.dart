import 'package:flutter/material.dart';

import '../feedback/dop_haptic_feedback.dart';
import '../theme/context_ext.dart';
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
    if (!_enabled && _open) {
      _entry?.remove();
      _entry = null;
      return;
    }
    if (_open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entry?.markNeedsBuild();
      });
    }
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
    final spacing = context.spacing;
    final stroke = context.stroke;
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
              padding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.paper,
                borderRadius: context.radius.controlGeometry,
                border: Border.fromBorderSide(stroke.outlineSide(colors.ink)),
              ),
              child: Row(
                children: [
                  DopText.label(widget.label),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      selected.label,
                      style: context.typo.control,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
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

    // The entry renders under the root Overlay, above the Theme that carries
    // the DOPAMINE120 token extensions. Re-apply the control's theme so the
    // menu keeps the active tokens (and `context.colors` never sees a null).
    final controlTheme = Theme.of(context);

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
          child: Theme(
            data: controlTheme,
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
    DopHapticFeedback.selection();
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
    final stroke = context.stroke;
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
        borderRadius: context.radius.cardGeometry,
        border: Border.fromBorderSide(stroke.outlineSide(colors.ink)),
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

class _DopDropdownOptionRow<T> extends StatefulWidget {
  const _DopDropdownOptionRow({
    super.key,
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
  State<_DopDropdownOptionRow<T>> createState() =>
      _DopDropdownOptionRowState<T>();
}

class _DopDropdownOptionRowState<T> extends State<_DopDropdownOptionRow<T>> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.option.enabled;

  void _activate() {
    if (_enabled) widget.onSelected(widget.option);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final stroke = context.stroke;
    final option = widget.option;
    final selected = widget.selected;
    final foreground = selected ? colors.onVoid : colors.ink;
    final secondary = selected ? colors.onVoidSoft : colors.inkFaint;

    // Pointer/keyboard feedback for desktop & web: hover and keyboard focus
    // both lift the row off the menu surface; a press darkens it further.
    final highlighted = _enabled && (_hovered || _focused);
    final Color background;
    if (selected) {
      background = colors.ink;
    } else if (_enabled && _pressed) {
      background = colors.line;
    } else if (highlighted) {
      background = colors.wall;
    } else {
      background = colors.paper;
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: _enabled,
      label: option.subtitle == null
          ? option.label
          : '${option.label}, ${option.subtitle}',
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _activate : null,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          child: Opacity(
            opacity: _enabled ? 1.0 : 0.42,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.sm,
              ),
              decoration: BoxDecoration(
                color: background,
                border: widget.divider
                    ? Border(bottom: stroke.hairlineSide(colors.line))
                    : null,
              ),
              // A keyboard focus ring sits above the fill without disturbing
              // the divider; mouse hover doesn't trigger it.
              foregroundDecoration: _focused
                  ? BoxDecoration(
                      border: Border.fromBorderSide(
                        stroke.outlineSide(
                          selected ? colors.onVoid : colors.ink,
                        ),
                      ),
                    )
                  : null,
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
                    SizedBox(height: spacing.xxs),
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
      ),
    );
  }
}
