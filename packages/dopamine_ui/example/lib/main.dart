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
          body: Padding(padding: const EdgeInsets.all(28), child: child),
        ),
      ),
      directories: [
        WidgetbookComponent(
          name: 'DopText',
          useCases: [
            WidgetbookUseCase(
              name: 'All styles',
              builder: (_) => const _TextGallery(),
            ),
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
                child: DopButton.outline(
                  label: 'see the math',
                  onPressed: () {},
                ),
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
          name: 'DopCheckbox',
          useCases: [
            WidgetbookUseCase(
              name: 'States',
              builder: (_) => const Center(child: _CheckboxStates()),
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
                  trailingText: 'claimed',
                  onTap: () {},
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Checkbox rows',
              builder: (_) => const _CheckboxList(),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DopScaleSelector',
          useCases: [
            WidgetbookUseCase(
              name: 'Interactive',
              builder: (_) => const Center(child: _ScalePlayground()),
            ),
            WidgetbookUseCase(
              name: 'Disabled',
              builder: (_) => const Center(
                child: DopScaleSelector(
                  value: 5,
                  onChanged: null,
                  minLabel: 'scroll / autopilot',
                  maxLabel: 'study / useful action',
                  semanticLabel: 'Useful action readiness',
                ),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
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
        ),
        WidgetbookComponent(
          name: 'Colors',
          useCases: [
            WidgetbookUseCase(
              name: 'Palette',
              builder: (_) => const _Palette(),
            ),
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

/// Standalone checkbox controls.
class _CheckboxStates extends StatefulWidget {
  const _CheckboxStates();

  @override
  State<_CheckboxStates> createState() => _CheckboxStatesState();
}

class _CheckboxStatesState extends State<_CheckboxStates> {
  bool _checked = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DopCheckbox(
          value: _checked,
          semanticLabel: 'interactive checkbox',
          onChanged: (value) => setState(() => _checked = value),
        ),
        const SizedBox(width: 28),
        const DopCheckbox(
          value: false,
          enabled: true,
          semanticLabel: 'unchecked checkbox',
        ),
        const SizedBox(width: 28),
        const DopCheckbox(
          value: true,
          enabled: false,
          semanticLabel: 'disabled checkbox',
        ),
      ],
    );
  }
}

/// Controlled selection rows used by setup and settings flows.
class _CheckboxList extends StatefulWidget {
  const _CheckboxList();

  @override
  State<_CheckboxList> createState() => _CheckboxListState();
}

class _CheckboxListState extends State<_CheckboxList> {
  final Set<int> _selected = {0};

  @override
  Widget build(BuildContext context) {
    final items = [
      ('feeds', 'environment support during focus'),
      ('short video', 'fast dopamine source'),
      ('late-night loops', 'optional, never required'),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            DopListTile(
              index: '${i + 1}'.padLeft(3, '0'),
              title: items[i].$1,
              subtitle: items[i].$2,
              divider: i != items.length - 1,
              trailing: DopCheckbox(
                value: _selected.contains(i),
                enabled: true,
                semanticLabel: items[i].$1,
              ),
              onTap: () {
                setState(() {
                  if (_selected.contains(i)) {
                    _selected.remove(i);
                  } else {
                    _selected.add(i);
                  }
                });
              },
            ),
        ],
      ),
    );
  }
}

/// Interactive scale; each change fires the selection-click haptic on device.
class _ScalePlayground extends StatefulWidget {
  const _ScalePlayground();

  @override
  State<_ScalePlayground> createState() => _ScalePlaygroundState();
}

class _ScalePlaygroundState extends State<_ScalePlayground> {
  var _value = 5;

  @override
  Widget build(BuildContext context) {
    return DopScaleSelector(
      value: _value,
      minLabel: 'scroll / autopilot',
      maxLabel: 'study / useful action',
      semanticLabel: 'Useful action readiness',
      onChanged: (value) => setState(() => _value = value),
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
            trailingText: 'claimed',
            onTap: () {},
          ),
          DopListTile(
            index: '002',
            title: 'seven',
            subtitle: 'a clean week',
            trailingText: 'claimed',
            onTap: () {},
          ),
          DopListTile(
            index: '003',
            title: 'under eighty',
            subtitle: 'load below 80',
            trailingText: 'claimed',
            onTap: () {},
          ),
          DopListTile(
            index: '004',
            title: 'dawn patrol',
            subtitle: 'nothing before noon · 5 days',
            trailingText: 'claimed',
            onTap: () {},
          ),
          const DopListTile(
            index: '005',
            title: 'off-grid weekend',
            subtitle: 'a whole weekend dark',
            trailingText: '1 / 2',
            dimmed: true,
          ),
          const DopListTile(
            index: '006',
            title: 'century down',
            subtitle: 'average under 100 for a month',
            trailingText: '78 / 100',
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
