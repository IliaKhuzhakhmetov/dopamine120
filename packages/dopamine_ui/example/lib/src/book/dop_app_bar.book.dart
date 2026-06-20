import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopAppBar].
WidgetbookComponent get dopAppBarBook => WidgetbookComponent(
  name: 'DopAppBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Back, title and trailing',
      builder: (context) => _Frame(
        child: DopAppBar(
          onBack: () {},
          backSemanticLabel: 'back',
          title: 'Focus',
          trailing: Icon(context.icons.unmuted, size: 20),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Back and title',
      builder: (_) => const _Frame(
        child: DopAppBar(title: 'Deprivation', onBack: _noop),
      ),
    ),
    WidgetbookUseCase(
      name: 'Title only',
      builder: (_) => const _Frame(child: DopAppBar(title: 'Focus')),
    ),
  ],
);

void _noop() {}

/// Aligns the bar to the top of a padded frame, the way a screen mounts it.
class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Align(alignment: Alignment.topCenter, child: child),
    );
  }
}
