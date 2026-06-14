import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopBackButton].
WidgetbookComponent get dopBackButtonBook => WidgetbookComponent(
  name: 'DopBackButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Enabled',
      builder: (_) => Center(
        child: DopBackButton(semanticLabel: 'back', onPressed: () {}),
      ),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (_) => const Center(
        child: DopBackButton(semanticLabel: 'back', onPressed: null),
      ),
    ),
  ],
);
