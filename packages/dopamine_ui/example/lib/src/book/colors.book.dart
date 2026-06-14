import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for the color tokens.
WidgetbookComponent get colorsBook => WidgetbookComponent(
  name: 'Colors',
  useCases: [
    WidgetbookUseCase(name: 'Palette', builder: (_) => const _Palette()),
  ],
);

/// Swatch + name + hex for every color token.
class _Palette extends StatelessWidget {
  const _Palette();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = <(String, Color)>[
      ('wall', colors.wall),
      ('paper', colors.paper),
      ('ink', colors.ink),
      ('inkSoft', colors.inkSoft),
      ('inkFaint', colors.inkFaint),
      ('line', colors.line),
      ('voidBlack', colors.voidBlack),
      ('onVoid', colors.onVoid),
      ('onVoidSoft', colors.onVoidSoft),
      ('accent', colors.accent),
    ];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (name, color) in tokens)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: colors.line),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DopText.bodyBold(name),
                  const Spacer(),
                  DopText.caption(_hex(color)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}
