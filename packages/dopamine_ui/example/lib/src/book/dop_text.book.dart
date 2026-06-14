import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopText].
WidgetbookComponent get dopTextBook => WidgetbookComponent(
  name: 'DopText',
  useCases: [
    WidgetbookUseCase(
      name: 'All styles',
      builder: (_) => const _TextGallery(),
    ),
  ],
);

/// Every DopText variant with its token name alongside.
class _TextGallery extends StatelessWidget {
  const _TextGallery();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DopText.label('giant'),
          DopText.giant('120'),
          SizedBox(height: 28),
          DopText.label('header'),
          DopText.header('This is you.'),
          SizedBox(height: 28),
          DopText.label('title'),
          DopText.title('the lock'),
          SizedBox(height: 28),
          DopText.label('body'),
          DopText.body('Lower is better.'),
          SizedBox(height: 28),
          DopText.label('bodyBold'),
          DopText.bodyBold('120 of 120.'),
          SizedBox(height: 28),
          DopText.label('caption'),
          DopText.caption('not a brain scan'),
          SizedBox(height: 28),
          DopText.label('label'),
          DopText.label('current load'),
        ],
      ),
    );
  }
}
