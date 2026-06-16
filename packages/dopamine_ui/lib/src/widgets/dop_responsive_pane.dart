import 'package:flutter/material.dart';

/// Centres and width-constrains a mobile-first screen body so it reads well on
/// desktop and tablet widths instead of stretching edge to edge.
///
/// Wrap the immediate child of a screen's `SafeArea` with it. The pane fills the
/// available height (so full-height [Column]s with [Spacer]s and scroll views
/// keep working) while capping the content at [maxWidth] and centring it
/// horizontally. On narrow phones the constraint is a no-op.
class DopResponsivePane extends StatelessWidget {
  /// Wraps [child] in a centred, width-capped pane.
  const DopResponsivePane({
    super.key,
    required this.child,
    this.maxWidth = kDopContentMaxWidth,
  });

  /// The largest a phone-style screen body grows to on desktop, in logical
  /// pixels. Matches a comfortable single-column reading width.
  static const double kDopContentMaxWidth = 520;

  /// The screen body to centre and constrain.
  final Widget child;

  /// The maximum width [child] is allowed to occupy.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
