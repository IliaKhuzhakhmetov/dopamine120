import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/context_ext.dart';
import '../theme/dop_spacing.dart';

enum _DopButtonVariant { primary, outline, link }

/// Flat full-width DOPAMINE120 button with zero corner radius.
class DopButton extends StatefulWidget {
  const DopButton._(
    this._variant, {
    super.key,
    required this.label,
    required this.onPressed,
    this.arrow = false,
  });

  /// Ink background, wall text, optional trailing arrow.
  const DopButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool arrow = true,
  }) : this._(
         _DopButtonVariant.primary,
         key: key,
         label: label,
         onPressed: onPressed,
         arrow: arrow,
       );

  /// Transparent with a 1px ink border, optional trailing arrow.
  const DopButton.outline({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool arrow = true,
  }) : this._(
         _DopButtonVariant.outline,
         key: key,
         label: label,
         onPressed: onPressed,
         arrow: arrow,
       );

  /// Underlined centered text, no box.
  const DopButton.link({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
  }) : this._(
         _DopButtonVariant.link,
         key: key,
         label: label,
         onPressed: onPressed,
       );

  /// The button label.
  final String label;

  /// Tap handler; null disables the button.
  final VoidCallback? onPressed;

  /// Shows a `→` on the right (primary/outline only).
  final bool arrow;

  final _DopButtonVariant _variant;

  @override
  State<DopButton> createState() => _DopButtonState();
}

class _DopButtonState extends State<DopButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLink = widget._variant == _DopButtonVariant.link;
    final foreground = switch (widget._variant) {
      _DopButtonVariant.primary => colors.wall,
      _DopButtonVariant.outline || _DopButtonVariant.link => colors.ink,
    };
    final labelStyle = GoogleFonts.dmMono(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: foreground,
      decoration: isLink ? TextDecoration.underline : null,
    );

    final row = Row(
      mainAxisAlignment: isLink
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label, style: labelStyle),
        if (!isLink && widget.arrow) Text('→', style: labelStyle),
      ],
    );

    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DopSpacing.control),
      decoration: BoxDecoration(
        color: widget._variant == _DopButtonVariant.primary ? colors.ink : null,
        border: widget._variant == _DopButtonVariant.outline
            ? Border.all(color: colors.ink)
            : null,
      ),
      child: row,
    );

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 80),
        child: AnimatedOpacity(
          opacity: !_enabled
              ? 0.4
              : _pressed
              ? 0.9
              : 1,
          duration: const Duration(milliseconds: 80),
          child: box,
        ),
      ),
    );
  }
}
