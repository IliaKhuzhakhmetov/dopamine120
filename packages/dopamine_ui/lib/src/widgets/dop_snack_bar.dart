import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import 'dop_button.dart';
import 'dop_text.dart';

/// Token-driven snackbar content for short, dismissible app guidance.
class DopSnackBar extends StatelessWidget {
  const DopSnackBar({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismissed,
    this.leading,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismissed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final stroke = context.stroke;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.paper,
        borderRadius: radius.cardGeometry,
        border: Border.fromBorderSide(stroke.outlineSide(colors.ink)),
        boxShadow: [
          BoxShadow(
            color: colors.voidBlack.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: colors.ink, size: spacing.xl),
                child: leading!,
              ),
              SizedBox(width: spacing.sm),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DopText.label(title, color: colors.inkFaint),
                  SizedBox(height: spacing.xs),
                  DopText.body(message),
                  if (actionLabel != null) ...[
                    SizedBox(height: spacing.sm),
                    DopButton.primary(
                      label: actionLabel!,
                      onPressed: onAction,
                      arrow: false,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            _DismissButton(onPressed: onDismissed),
          ],
        ),
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showDopSnackBar({
  required BuildContext context,
  required String title,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Widget? leading,
  Duration duration = const Duration(seconds: 8),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  controller;
  controller = messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(
        left: context.spacing.md,
        right: context.spacing.md,
        bottom: context.spacing.md,
      ),
      duration: duration,
      content: DopSnackBar(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: actionLabel == null
            ? null
            : () {
                controller.close();
                onAction?.call();
              },
        onDismissed: () {
          controller.close();
        },
        leading: leading,
      ),
    ),
  );

  return controller;
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Dismiss',
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xxs),
          child: Icon(Icons.close, color: colors.ink, size: 18),
        ),
      ),
    );
  }
}
