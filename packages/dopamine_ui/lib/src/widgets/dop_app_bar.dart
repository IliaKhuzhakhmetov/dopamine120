import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import 'dop_back_button.dart';
import 'dop_text.dart';

/// Top bar for DOPAMINE120 screens: an optional back button on the left and an
/// eyebrow [title] with an optional [trailing] control (e.g. a mute toggle) on
/// the right.
class DopAppBar extends StatelessWidget {
  const DopAppBar({
    super.key,
    this.onBack,
    this.backSemanticLabel,
    this.title,
    this.trailing,
  });

  /// Back-button tap handler; when null the back button is hidden.
  final VoidCallback? onBack;

  /// Accessibility label for the back button, e.g. a localized "back".
  final String? backSemanticLabel;

  /// Eyebrow-styled label shown on the right.
  final String? title;

  /// Control shown to the right of [title], e.g. a mute toggle.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return SizedBox(
      // Matches the back button so the bar keeps a stable height without one.
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onBack != null)
            DopBackButton(onPressed: onBack, semanticLabel: backSemanticLabel)
          else
            const SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) DopText.label(title!, color: colors.inkFaint),
              if (title != null && trailing != null)
                SizedBox(width: spacing.md),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}
