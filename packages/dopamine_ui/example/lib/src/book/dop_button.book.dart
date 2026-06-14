import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopButton].
WidgetbookComponent get dopButtonBook => WidgetbookComponent(
  name: 'DopButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Primary',
      builder: (_) => Center(
        child: DopButton.primary(label: 'go quiet', onPressed: () {}),
      ),
    ),
    WidgetbookUseCase(
      name: 'Outline',
      builder: (_) => Center(
        child: DopButton.outline(label: 'see the math', onPressed: () {}),
      ),
    ),
    WidgetbookUseCase(
      name: 'Link',
      builder: (_) => Center(
        child: DopButton.link(label: 'not today', onPressed: () {}),
      ),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DopButton.primary(label: 'go quiet', onPressed: null),
            SizedBox(height: 16),
            DopButton.outline(label: 'see the math', onPressed: null),
            SizedBox(height: 16),
            DopButton.link(label: 'not today', onPressed: null),
          ],
        ),
      ),
    ),
  ],
);
