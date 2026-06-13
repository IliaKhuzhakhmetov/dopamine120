import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import '../theme/dop_spacing.dart';
import 'dop_text.dart';

/// Ledger-style DOPAMINE120 row with Material-like leading/trailing slots.
class DopListTile extends StatefulWidget {
  const DopListTile({
    super.key,
    this.leading,
    this.index,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingText,
    this.dimmed = false,
    this.divider = true,
    this.verticalPadding = DopSpacing.xl,
    this.animateTitleOnTap = false,
    this.animateLeadingOnTap = false,
    this.onTap,
  }) : assert(
         leading == null || index == null,
         'Use either leading or index, not both.',
       ),
       assert(
         trailing == null || trailingText == null,
         'Use either trailing or trailingText, not both.',
       );

  /// Custom widget shown before the title block.
  final Widget? leading;

  /// Ordinal shown left of the title, e.g. `001`.
  final String? index;

  /// Row title, auto-uppercased.
  final String title;

  /// Mono line under the title.
  final String? subtitle;

  /// Custom widget shown after the title block.
  final Widget? trailing;

  /// Status text on the right, auto-uppercased, e.g. `claimed` or `78 / 100`.
  final String? trailingText;

  /// Fades the whole row — for locked or not-yet-earned entries.
  final bool dimmed;

  /// Draws the hairline under the row.
  final bool divider;

  /// Vertical row inset. Defaults to the roomy ledger rhythm; compact surfaces
  /// can opt into a tighter value without changing all list tiles.
  final double verticalPadding;

  /// Pulses the title when a tappable row is activated.
  final bool animateTitleOnTap;

  /// Gives the leading slot a subtle motion when a tappable row is activated.
  final bool animateLeadingOnTap;

  /// Tap handler; null makes the row static.
  final VoidCallback? onTap;

  @override
  State<DopListTile> createState() => _DopListTileState();
}

class _DopListTileState extends State<DopListTile>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _tapPulseController;
  late final Animation<double> _titleScale;
  late final Animation<double> _titleLift;
  late final Animation<double> _titleAccent;
  late final Animation<double> _leadingScale;
  late final Animation<double> _leadingLift;
  late final Animation<double> _leadingTurns;

  bool get _tappable => widget.onTap != null;

  @override
  void initState() {
    super.initState();
    _tapPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    final pulse = CurvedAnimation(
      parent: _tapPulseController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
    _titleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.035), weight: 38),
      TweenSequenceItem(tween: Tween(begin: 1.035, end: 1), weight: 62),
    ]).animate(pulse);
    _titleLift = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -3), weight: 38),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 62),
    ]).animate(pulse);
    _titleAccent = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 32),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 68),
    ]).animate(pulse);
    _leadingScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.09), weight: 34),
      TweenSequenceItem(tween: Tween(begin: 1.09, end: 1), weight: 66),
    ]).animate(pulse);
    _leadingLift = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -2), weight: 34),
      TweenSequenceItem(tween: Tween(begin: -2, end: 0), weight: 66),
    ]).animate(pulse);
    _leadingTurns = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.012), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.012, end: 0.005), weight: 28),
      TweenSequenceItem(tween: Tween(begin: 0.005, end: 0), weight: 42),
    ]).animate(pulse);
  }

  @override
  void dispose() {
    _tapPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ink = widget.dimmed ? colors.inkFaint : colors.ink;
    final soft = widget.dimmed ? colors.inkFaint : colors.inkSoft;
    final leading = _leading();
    final trailing = _trailing(soft);

    final row = Container(
      padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
      decoration: BoxDecoration(
        border: widget.divider
            ? Border(bottom: BorderSide(color: colors.line))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: DopSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitlePulse(
                  animation: _tapPulseController,
                  scale: _titleScale,
                  lift: _titleLift,
                  accent: _titleAccent,
                  title: widget.title,
                  color: ink,
                  accentColor: colors.accent,
                  enabled: widget.animateTitleOnTap && _tappable,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: DopSpacing.xxs),
                  DopText.body(widget.subtitle!, color: soft),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: DopSpacing.lg),
            trailing,
          ],
        ],
      ),
    );

    if (!_tappable) return row;

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.6 : 1,
        duration: const Duration(milliseconds: 80),
        child: row,
      ),
    );
  }

  void _handleTap() {
    if (widget.animateTitleOnTap || widget.animateLeadingOnTap) {
      _tapPulseController.forward(from: 0);
    }
    widget.onTap?.call();
  }

  Widget? _leading() {
    if (widget.leading != null) {
      return Padding(
        padding: const EdgeInsets.only(top: DopSpacing.xxs),
        child: _LeadingPulse(
          animation: _tapPulseController,
          scale: _leadingScale,
          lift: _leadingLift,
          turns: _leadingTurns,
          enabled: widget.animateLeadingOnTap && _tappable,
          child: widget.leading!,
        ),
      );
    }

    if (widget.index == null) return null;

    // Top padding optically centers the small mono label against the first line
    // of the 21px title.
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: DopText.label(widget.index!),
    );
  }

  Widget? _trailing(Color color) {
    if (widget.trailing != null) {
      return Padding(
        padding: const EdgeInsets.only(top: DopSpacing.xxs),
        child: widget.trailing!,
      );
    }

    if (widget.trailingText == null) return null;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: DopText.label(widget.trailingText!, color: color),
    );
  }
}

class _LeadingPulse extends StatelessWidget {
  const _LeadingPulse({
    required this.animation,
    required this.scale,
    required this.lift,
    required this.turns,
    required this.enabled,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> scale;
  final Animation<double> lift;
  final Animation<double> turns;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, lift.value),
          child: Transform.rotate(
            angle: turns.value * 6.283185307179586,
            child: Transform.scale(scale: scale.value, child: child),
          ),
        );
      },
    );
  }
}

class _TitlePulse extends StatelessWidget {
  const _TitlePulse({
    required this.animation,
    required this.scale,
    required this.lift,
    required this.accent,
    required this.title,
    required this.color,
    required this.accentColor,
    required this.enabled,
  });

  final Animation<double> animation;
  final Animation<double> scale;
  final Animation<double> lift;
  final Animation<double> accent;
  final String title;
  final Color color;
  final Color accentColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return DopText.title(title, color: color);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final titleColor = Color.lerp(color, accentColor, accent.value)!;
        return Transform.translate(
          offset: Offset(0, lift.value),
          child: Transform.scale(
            scale: scale.value,
            alignment: Alignment.centerLeft,
            child: DopText.title(title, color: titleColor),
          ),
        );
      },
    );
  }
}
