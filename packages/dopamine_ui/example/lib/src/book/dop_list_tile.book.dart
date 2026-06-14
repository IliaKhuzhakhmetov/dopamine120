import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopListTile].
WidgetbookComponent get dopListTileBook => WidgetbookComponent(
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
);

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
