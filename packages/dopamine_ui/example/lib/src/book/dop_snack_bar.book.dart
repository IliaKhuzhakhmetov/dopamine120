import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent get dopSnackBarBook => WidgetbookComponent(
  name: 'DopSnackBar',
  useCases: [
    WidgetbookUseCase(
      name: 'PWA install hint',
      builder: (_) => Center(
        child: DopSnackBar(
          title: 'install app',
          message: 'Share -> Add to Home Screen -> Add.',
          actionLabel: 'got it',
          onAction: () {},
          leading: const Icon(Icons.add_to_home_screen),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Passive note',
      builder: (_) => const Center(
        child: DopSnackBar(
          title: 'session saved',
          message: 'Interrupted focus still counts as a completed repetition.',
        ),
      ),
    ),
  ],
);
