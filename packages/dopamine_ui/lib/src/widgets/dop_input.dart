import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import 'dop_text.dart';

/// Transparent DOPAMINE120 text field with a bottom hairline and a label above.
class DopInput extends StatelessWidget {
  /// Creates a text field; [errorText] renders below in caption style with a `!` prefix.
  const DopInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.obscure = false,
    this.errorText,
  });

  /// Label rendered above the field.
  final String label;

  /// Placeholder shown when empty.
  final String? hint;

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Called on every text change.
  final ValueChanged<String>? onChanged;

  /// Hides the input (passwords).
  final bool obscure;

  /// Error message shown below the field.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final spacing = context.spacing;
    final stroke = context.stroke;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DopText.label(label),
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscure,
          style: typo.bodyBold,
          cursorColor: colors.ink,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: typo.body.copyWith(color: colors.inkFaint),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: spacing.sm),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colors.line,
                width: stroke.hairline,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.ink, width: stroke.outline),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: spacing.xs),
          DopText.caption('! $errorText', color: colors.ink),
        ],
      ],
    );
  }
}
