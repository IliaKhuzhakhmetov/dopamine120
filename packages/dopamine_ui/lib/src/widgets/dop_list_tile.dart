import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import 'dop_text.dart';

/// Ledger-style DOPAMINE120 row: index on the left, uppercase title with an
/// optional subtitle in the middle, status text on the right, hairline below.
class DopListTile extends StatefulWidget {
  const DopListTile({
    super.key,
    this.index,
    required this.title,
    this.subtitle,
    this.trailing,
    this.dimmed = false,
    this.divider = true,
    this.onTap,
  });

  /// Ordinal shown left of the title, e.g. `001`.
  final String? index;

  /// Row title, auto-uppercased.
  final String title;

  /// Mono line under the title.
  final String? subtitle;

  /// Status text on the right, auto-uppercased, e.g. `claimed` or `78 / 100`.
  final String? trailing;

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

    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: widget.divider
            ? Border(bottom: BorderSide(color: colors.line))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.index != null) ...[
            // Top padding optically centers the small mono label against the
            // first line of the 21px title.
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: DopText.label(widget.index!),
            ),
            const SizedBox(width: 20),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DopText.title(widget.title, color: ink),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  DopText.body(widget.subtitle!, color: soft),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 20),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: DopText.label(widget.trailing!, color: soft),
            ),
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
}
