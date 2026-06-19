import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for icon tokens.
WidgetbookComponent get iconsBook => WidgetbookComponent(
  name: 'Icons',
  useCases: [
    WidgetbookUseCase(
      name: 'Active theme',
      builder: (_) => const _ActiveIconMatrix(),
    ),
    WidgetbookUseCase(name: 'All themes', builder: (_) => const _ThemeMatrix()),
  ],
);

/// Icon matrix for the currently selected Widgetbook theme.
class _ActiveIconMatrix extends StatelessWidget {
  const _ActiveIconMatrix();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = context.icons.entries;
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final token in tokens)
            Container(
              width: 112,
              height: 104,
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(
                    color: colors.line,
                    width: context.stroke.hairline,
                  ),
                ),
                borderRadius: context.radius.controlGeometry,
                color: colors.paper,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(token.icon, size: 28, color: colors.ink),
                  const SizedBox(height: 12),
                  DopText.caption(token.name, color: colors.inkSoft),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Cross-theme matrix showing how each token changes with [DopThemeSpec].
class _ThemeMatrix extends StatelessWidget {
  const _ThemeMatrix();

  @override
  Widget build(BuildContext context) {
    final activeColors = context.colors;
    final tokenNames = context.icons.entries
        .map((token) => token.name)
        .toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(96),
          border: TableBorder.all(
            color: activeColors.line,
            width: context.stroke.hairline,
          ),
          children: [
            TableRow(
              children: [
                const _HeaderCell('token'),
                for (final spec in DopThemes.all) _HeaderCell(spec.label),
              ],
            ),
            for (final name in tokenNames)
              TableRow(
                children: [
                  _HeaderCell(name),
                  for (final spec in DopThemes.all)
                    _ThemeIconCell(spec: spec, name: name),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      color: context.colors.paper,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DopText.caption(
        label,
        color: context.colors.inkSoft,
        align: TextAlign.center,
      ),
    );
  }
}

class _ThemeIconCell extends StatelessWidget {
  const _ThemeIconCell({required this.spec, required this.name});

  final DopThemeSpec spec;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = DopTheme.fromSpec(spec);
    final icons = spec.icons;
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          return Container(
            height: 64,
            alignment: Alignment.center,
            color: context.colors.wall,
            child: Icon(
              icons.byName(name),
              size: 24,
              color: context.colors.ink,
            ),
          );
        },
      ),
    );
  }
}
