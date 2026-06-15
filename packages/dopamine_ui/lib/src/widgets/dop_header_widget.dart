import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import '../theme/dop_typography.dart';
import 'dop_text.dart';

/// Screen header block: a display title, a soft subtitle, and an optional
/// trailing slot (e.g. a decorative icon) aligned with the title's first line.
///
/// Asterisk-wrapped segments of [title] (`'train *your brain*'`) render in
/// the serif accent style for an editorial two-family look.
class DopHeaderWidget extends StatelessWidget {
  const DopHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  /// Header line in the display style; `*…*` marks accent segments.
  final String title;

  /// Soft line under the title.
  final String? subtitle;

  /// Widget shown to the right of the title.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: _titleSpans(context.typo))),
              if (subtitle != null) ...[
                DopText.body(subtitle!, color: colors.inkSoft),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: spacing.lg),
          // Top padding optically centers the slot against the 34px title line.
          Padding(
            padding: EdgeInsets.only(top: spacing.xxs),
            child: trailing!,
          ),
        ],
      ],
    );
  }

  /// Odd `*`-delimited segments get the serif accent style.
  List<TextSpan> _titleSpans(DopTypography typo) {
    final header = typo.header.copyWith(height: 0.92);
    final accent = typo.headerAccent.copyWith(height: 0.86);

    return [
      for (final (index, part) in title.split('*').indexed)
        if (part.isNotEmpty)
          TextSpan(text: part, style: index.isOdd ? accent : header),
    ];
  }
}
