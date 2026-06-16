import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import 'dop_button.dart';
import 'dop_text.dart';

/// Visual treatment for a [DopDialogAction].
enum DopDialogActionVariant {
  /// Ink-filled action.
  primary,

  /// Transparent outlined action.
  outline,

  /// Text-only action.
  link,
}

/// An action rendered in the footer of a [DopDialog].
class DopDialogAction {
  const DopDialogAction._({
    required this.label,
    required this.onPressed,
    required this.variant,
    required this.arrow,
  });

  /// Ink-filled action.
  const DopDialogAction.primary({
    required String label,
    required VoidCallback? onPressed,
    bool arrow = false,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: DopDialogActionVariant.primary,
         arrow: arrow,
       );

  /// Transparent outlined action.
  const DopDialogAction.outline({
    required String label,
    required VoidCallback? onPressed,
    bool arrow = false,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: DopDialogActionVariant.outline,
         arrow: arrow,
       );

  /// Text-only action.
  const DopDialogAction.link({
    required String label,
    required VoidCallback? onPressed,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: DopDialogActionVariant.link,
         arrow: false,
       );

  /// Button label.
  final String label;

  /// Tap handler. Null disables the action.
  final VoidCallback? onPressed;

  /// Visual button treatment.
  final DopDialogActionVariant variant;

  /// Shows the DOPAMINE120 arrow on boxed actions.
  final bool arrow;
}

/// Shows a token-driven [DopDialog] with a DOPAMINE120 barrier color.
Future<T?> showDopDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
}) {
  final colors = context.colors;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? colors.voidBlack.withValues(alpha: 0.58),
    barrierLabel: barrierLabel,
    builder: builder,
  );
}

/// Token-driven dialog surface for confirmations, choices, and compact custom content.
class DopDialog extends StatelessWidget {
  /// Creates a DOPAMINE120 dialog.
  const DopDialog({
    super.key,
    this.eyebrow,
    required this.title,
    this.message,
    this.child,
    this.actions = const [],
    this.leading,
    this.maxWidth = defaultMaxWidth,
    this.scrollable = false,
    this.semanticLabel,
  });

  /// Default desktop/tablet width cap.
  static const double defaultMaxWidth = 520;

  /// Optional label rendered above the title.
  final String? eyebrow;

  /// Primary title.
  final String title;

  /// Optional body copy.
  final String? message;

  /// Optional custom content rendered below [message].
  final Widget? child;

  /// Footer actions. Rendered in a row when space allows and wrapped otherwise.
  final List<DopDialogAction> actions;

  /// Optional leading visual slot next to the title.
  final Widget? leading;

  /// Width cap for the dialog surface.
  final double maxWidth;

  /// Wraps message/custom content in a scroll view.
  final bool scrollable;

  /// Accessibility label for the dialog route.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final stroke = context.stroke;

    return Dialog(
      insetPadding: EdgeInsets.all(spacing.screen),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: Semantics(
        namesRoute: true,
        scopesRoute: true,
        explicitChildNodes: true,
        label: semanticLabel ?? title,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.paper,
              borderRadius: radius.cardGeometry,
              border: Border.fromBorderSide(stroke.outlineSide(colors.ink)),
            ),
            child: Padding(
              padding: EdgeInsets.all(spacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DopDialogHeader(
                    eyebrow: eyebrow,
                    title: title,
                    leading: leading,
                  ),
                  if (message != null || child != null) ...[
                    SizedBox(height: spacing.lg),
                    _DopDialogContent(
                      message: message,
                      scrollable: scrollable,
                      child: child,
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: spacing.xl),
                    _DopDialogActions(actions: actions),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DopDialogHeader extends StatelessWidget {
  const _DopDialogHeader({
    required this.eyebrow,
    required this.title,
    required this.leading,
  });

  final String? eyebrow;
  final String title;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          DopText.label(eyebrow!, color: colors.inkFaint),
          SizedBox(height: spacing.xs),
        ],
        Text(title, style: context.typo.title),
      ],
    );

    if (leading == null) return header;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTheme.merge(
          data: IconThemeData(color: colors.ink, size: spacing.xl),
          child: leading!,
        ),
        SizedBox(width: spacing.md),
        Expanded(child: header),
      ],
    );
  }
}

class _DopDialogContent extends StatelessWidget {
  const _DopDialogContent({
    required this.message,
    required this.scrollable,
    required this.child,
  });

  final String? message;
  final bool scrollable;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null) DopText.body(message!),
        if (message != null && child != null) SizedBox(height: spacing.md),
        ?child,
      ],
    );

    if (!scrollable) return content;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: spacing.xxl * 8),
      child: SingleChildScrollView(child: content),
    );
  }
}

class _DopDialogActions extends StatelessWidget {
  const _DopDialogActions({required this.actions});

  final List<DopDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final actionWidth = _actionWidth(
          maxWidth: constraints.maxWidth,
          actionCount: actions.length,
          gap: spacing.sm,
        );

        return Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          alignment: WrapAlignment.end,
          children: [
            for (final action in actions)
              SizedBox(
                width: actionWidth,
                child: _DopDialogActionButton(action: action),
              ),
          ],
        );
      },
    );
  }

  double _actionWidth({
    required double maxWidth,
    required int actionCount,
    required double gap,
  }) {
    if (actionCount <= 1 || maxWidth < 320) return maxWidth;
    final visibleColumns = actionCount > 2 ? 2 : actionCount;
    return (maxWidth - gap * (visibleColumns - 1)) / visibleColumns;
  }
}

class _DopDialogActionButton extends StatelessWidget {
  const _DopDialogActionButton({required this.action});

  final DopDialogAction action;

  @override
  Widget build(BuildContext context) {
    return switch (action.variant) {
      DopDialogActionVariant.primary => DopButton.primary(
        label: action.label,
        onPressed: action.onPressed,
        arrow: action.arrow,
      ),
      DopDialogActionVariant.outline => DopButton.outline(
        label: action.label,
        onPressed: action.onPressed,
        arrow: action.arrow,
      ),
      DopDialogActionVariant.link => DopButton.link(
        label: action.label,
        onPressed: action.onPressed,
      ),
    };
  }
}
