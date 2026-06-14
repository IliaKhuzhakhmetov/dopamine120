import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopHeaderWidget].
WidgetbookComponent get dopHeaderWidgetBook => WidgetbookComponent(
  name: 'DopHeaderWidget',
  useCases: [
    WidgetbookUseCase(
      name: 'Title + subtitle',
      builder: (_) => const Center(
        child: DopHeaderWidget(
          title: 'How to train *your brain*',
          subtitle: 'to do a heavy job easily',
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'With trailing',
      builder: (_) => const Center(
        child: DopHeaderWidget(
          title: 'How to train *your brain*',
          subtitle: 'to do a heavy job easily',
          trailing: Icon(Icons.auto_awesome, size: 56),
        ),
      ),
    ),
  ],
);
