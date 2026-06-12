import 'package:flutter/material.dart';

import '../theme/context_ext.dart';

/// Row of thin segments marking progress through a flow: segments up to and
/// including [index] are filled with the accent, the rest stay on the line
/// color.
class DopStepIndicator extends StatelessWidget {
  const DopStepIndicator({super.key, required this.count, required this.index})
    : assert(count > 0),
      assert(index >= 0 && index < count);

  /// Total number of steps.
  final int count;

  /// Zero-based current step.
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 3,
              color: i <= index ? colors.accent : colors.line,
            ),
          ),
        ],
      ],
    );
  }
}
