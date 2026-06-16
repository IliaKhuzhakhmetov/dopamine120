import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopResponsivePane].
WidgetbookComponent get dopResponsivePaneBook => WidgetbookComponent(
  name: 'DopResponsivePane',
  useCases: [
    WidgetbookUseCase(
      name: 'Constrained body',
      builder: (context) => DopResponsivePane(
        child: Container(
          color: context.colors.paper,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DopText.header('Centred on desktop'),
              const SizedBox(height: 16),
              DopText.body(
                'On wide windows this body stops growing at '
                '${DopResponsivePane.kDopContentMaxWidth.toInt()}px and '
                'centres; on phones the cap is a no-op. Resize the preview '
                'to see it react.',
                color: context.colors.inkSoft,
              ),
              const SizedBox(height: 24),
              DopButton.primary(label: 'Action', onPressed: () {}),
            ],
          ),
        ),
      ),
    ),
  ],
);
