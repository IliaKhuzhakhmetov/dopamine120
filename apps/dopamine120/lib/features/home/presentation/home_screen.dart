import 'package:auto_route/auto_route.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              DopText.label('DOPAMINE120', color: colors.accent),
              const SizedBox(height: 16),
              DopText.header(l10n.homeTitle),
              const SizedBox(height: 16),
              DopText.body(l10n.homeBody, color: colors.inkSoft),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
