import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const WidgetbookApp());
}

/// Widgetbook catalog for the dopamine_ui package.
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Paints the use-case canvas with DopTheme; without it Widgetbook's own
      // (system-dark) workbench color shows through behind every use case.
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'DOPAMINE120', data: DopTheme.light()),
          ],
        ),
      ],
      appBuilder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DopTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(28),
            child: child,
          ),
        ),
      ),
      directories: [
        WidgetbookComponent(
          name: 'DopText',
          useCases: [
            WidgetbookUseCase(name: 'All styles', builder: (_) => const _TextGallery()),
          ],
        ),
        WidgetbookComponent(
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
        ),
        WidgetbookComponent(
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
        ),
        WidgetbookComponent(
          name: 'DopListTile',
          useCases: [
            WidgetbookUseCase(
              name: 'Milestones',
              builder: (_) => const _MilestoneList(),
            ),
            WidgetbookUseCase(
              name: 'Single',
              builder: (_) => Center(
                child: DopListTile(
                  index: '001',
                  title: 'first silence',
                  subtitle: '24 hours, no feeds',
                  trailing: 'claimed',
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'Colors',
          useCases: [
            WidgetbookUseCase(name: 'Palette', builder: (_) => const _Palette()),
          ],
        ),
      ],
    );
  }
}

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

/// The milestones ledger: claimed rows full ink, locked rows dimmed.
class _MilestoneList extends StatelessWidget {
  const _MilestoneList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DopListTile(
            index: '001',
            title: 'first silence',
            subtitle: '24 hours, no feeds',
            trailing: 'claimed',
            onTap: () {},
          ),
          DopListTile(
            index: '002',
            title: 'seven',
            subtitle: 'a clean week',
            trailing: 'claimed',
            onTap: () {},
          ),
          DopListTile(
            index: '003',
            title: 'under eighty',
            subtitle: 'load below 80',
            trailing: 'claimed',
            onTap: () {},
          ),
          DopListTile(
            index: '004',
            title: 'dawn patrol',
            subtitle: 'nothing before noon · 5 days',
            trailing: 'claimed',
            onTap: () {},
          ),
          const DopListTile(
            index: '005',
            title: 'off-grid weekend',
            subtitle: 'a whole weekend dark',
            trailing: '1 / 2',
            dimmed: true,
          ),
          const DopListTile(
            index: '006',
            title: 'century down',
            subtitle: 'average under 100 for a month',
            trailing: '78 / 100',
            dimmed: true,
            divider: false,
          ),
        ],
      ),
    );
  }
}

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
