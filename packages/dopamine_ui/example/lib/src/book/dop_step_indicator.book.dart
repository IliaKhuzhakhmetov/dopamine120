import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopStepIndicator].
WidgetbookComponent get dopStepIndicatorBook => WidgetbookComponent(
  name: 'DopStepIndicator',
  useCases: [
    WidgetbookUseCase(
      name: 'Steps',
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DopStepIndicator(count: 4, index: 0),
            SizedBox(height: 24),
            DopStepIndicator(count: 4, index: 1),
            SizedBox(height: 24),
            DopStepIndicator(count: 4, index: 2),
            SizedBox(height: 24),
            DopStepIndicator(count: 4, index: 3),
          ],
        ),
      ),
    ),
  ],
);
