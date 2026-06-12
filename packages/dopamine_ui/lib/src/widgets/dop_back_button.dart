import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/context_ext.dart';

/// Square bordered DOPAMINE120 back button with a `←` glyph.
class DopBackButton extends StatefulWidget {
  const DopBackButton({super.key, required this.onPressed, this.semanticLabel});

  /// Tap handler; null disables the button.
  final VoidCallback? onPressed;

  /// Accessibility label, e.g. a localized "back".
  final String? semanticLabel;

  @override
  State<DopBackButton> createState() => _DopBackButtonState();
}

class _DopBackButtonState extends State<DopBackButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 80),
          child: AnimatedOpacity(
            opacity: !_enabled
                ? 0.4
                : _pressed
                ? 0.9
                : 1,
            duration: const Duration(milliseconds: 80),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: colors.ink)),
              child: Text(
                '←',
                style: GoogleFonts.dmMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
