import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopDialog].
WidgetbookComponent get dopDialogBook => WidgetbookComponent(
  name: 'DopDialog',
  useCases: [
    WidgetbookUseCase(
      name: 'Focus support',
      builder: (_) => Center(
        child: DopDialog(
          eyebrow: 'focus block',
          title: 'Open Instagram with intention?',
          message:
              'This app is on your support list for the next 18 minutes. You can pause and return to the task, or open it as a deliberate choice.',
          actions: [
            DopDialogAction.outline(label: 'open anyway', onPressed: () {}),
            DopDialogAction.primary(label: 'return to task', onPressed: () {}),
          ],
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Completed rep',
      builder: (_) => Center(
        child: DopDialog(
          eyebrow: 'session',
          title: 'Interrupted focus still counts',
          leading: const Icon(Icons.repeat),
          message:
              'The repetition completed because the impulse became visible.',
          actions: [
            DopDialogAction.outline(label: 'review', onPressed: () {}),
            DopDialogAction.primary(label: 'log rep', onPressed: () {}),
          ],
          child: const _DialogMetricStrip(),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Permission optional',
      builder: (_) => Center(
        child: DopDialog(
          eyebrow: 'permission',
          title: 'Blocking is optional support',
          message:
              'The trainer can work without system permissions. Enable them only if it helps.',
          actions: [
            DopDialogAction.outline(label: 'not now', onPressed: () {}),
            DopDialogAction.primary(label: 'enable', onPressed: () {}),
          ],
          child: const _PermissionChecklist(),
        ),
      ),
    ),
  ],
);

class _PermissionChecklist extends StatelessWidget {
  const _PermissionChecklist();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChecklistRow(text: 'You can still run focus sessions.'),
        SizedBox(height: spacing.xs),
        _ChecklistRow(text: 'Allowed apps stay available.'),
        SizedBox(height: spacing.xs),
        _ChecklistRow(text: 'You can change this later.'),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('-', style: context.typo.bodyBold.copyWith(color: colors.ink)),
        SizedBox(width: spacing.xs),
        Expanded(child: DopText.body(text)),
      ],
    );
  }
}

class _DialogMetricStrip extends StatelessWidget {
  const _DialogMetricStrip();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final stroke = context.stroke;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(stroke.hairlineSide(colors.line)),
        borderRadius: context.radius.controlGeometry,
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          children: [
            Expanded(
              child: _Metric(label: 'rep', value: '1'),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: _Metric(label: 'minutes', value: '06'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DopText.label(label),
        SizedBox(height: context.spacing.xxs),
        Text(value, style: context.typo.control),
      ],
    );
  }
}
