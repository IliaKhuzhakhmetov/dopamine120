import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import '../theme/dop_spacing.dart';
import 'dop_text.dart';

/// Ledger-style DOPAMINE120 row with Material-like leading/trailing slots.
class DopListTile extends StatefulWidget {
  const DopListTile({
    super.key,
    this.leading,
    this.index,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingText,
    this.dimmed = false,
    this.divider = true,
    this.onTap,
  }) : assert(
         leading == null || index == null,
         'Use either leading or index, not both.',
       ),
       assert(
         trailing == null || trailingText == null,
         'Use either trailing or trailingText, not both.',
       );

  /// Custom widget shown before the title block.
  final Widget? leading;

  /// Ordinal shown left of the title, e.g. `001`.
  final String? index;

  /// Row title, auto-uppercased.
  final String title;

  /// Mono line under the title.
  final String? subtitle;

  /// Custom widget shown after the title block.
  final Widget? trailing;

  /// Status text on the right, auto-uppercased, e.g. `claimed` or `78 / 100`.
  final String? trailingText;

  /// Fades the whole row — for locked or not-yet-earned entries.
  final bool dimmed;

  /// Draws the hairline under the row.
  final bool divider;

  /// Tap handler; null makes the row static.
  final VoidCallback? onTap;

  @override
  State<DopListTile> createState() => _DopListTileState();
}

class _DopListTileState extends State<DopListTile> {
  bool _pressed = false;

  bool get _tappable => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ink = widget.dimmed ? colors.inkFaint : colors.ink;
    final soft = widget.dimmed ? colors.inkFaint : colors.inkSoft;
    final leading = _leading();
    final trailing = _trailing(soft);

    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: DopSpacing.xl),
      decoration: BoxDecoration(
        border: widget.divider
            ? Border(bottom: BorderSide(color: colors.line))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: DopSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DopText.title(widget.title, color: ink),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: DopSpacing.xxs),
                  DopText.body(widget.subtitle!, color: soft),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: DopSpacing.lg),
            trailing,
          ],
        ],
      ),
    );

    if (!_tappable) return row;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.6 : 1,
        duration: const Duration(milliseconds: 80),
        child: row,
      ),
    );
  }

  Widget? _leading() {
    if (widget.leading != null) {
      return Padding(
        padding: const EdgeInsets.only(top: DopSpacing.xxs),
        child: widget.leading!,
      );
    }

    if (widget.index == null) return null;

    // Top padding optically centers the small mono label against the first line
    // of the 21px title.
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: DopText.label(widget.index!),
    );
  }

  Widget? _trailing(Color color) {
    if (widget.trailing != null) {
      return Padding(
        padding: const EdgeInsets.only(top: DopSpacing.xxs),
        child: widget.trailing!,
      );
    }

    if (widget.trailingText == null) return null;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: DopText.label(widget.trailingText!, color: color),
    );
  }
}
