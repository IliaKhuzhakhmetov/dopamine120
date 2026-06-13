import 'package:flutter/material.dart';

/// Shared scroll + padding wrapper for one onboarding page.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
