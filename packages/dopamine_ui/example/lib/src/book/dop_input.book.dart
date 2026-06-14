import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopInput].
WidgetbookComponent get dopInputBook => WidgetbookComponent(
  name: 'DopInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Empty',
      builder: (_) => const Center(
        child: DopInput(label: 'daily limit', hint: '120'),
      ),
    ),
    WidgetbookUseCase(
      name: 'Error',
      builder: (_) => const Center(
        child: DopInput(
          label: 'daily limit',
          hint: '120',
          errorText: 'numbers only',
        ),
      ),
    ),
  ],
);
