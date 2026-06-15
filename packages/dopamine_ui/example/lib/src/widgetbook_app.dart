import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook shell for the dopamine_ui package.
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({required this.directories, super.key});

  final List<WidgetbookNode> directories;

  @override
  Widget build(BuildContext context) {
    // One Widgetbook theme per registry entry, so the toolbar "Theme" dropdown
    // lists every DOPAMINE120 theme and stays in sync with `DopThemes.all`:
    // adding a theme to the kit surfaces it here with no edit.
    final themes = [
      for (final spec in DopThemes.all)
        WidgetbookTheme(
          name: '${spec.label} · ${spec.description}',
          data: DopTheme.fromSpec(spec),
        ),
    ];

    return Widgetbook.material(
      addons: [
        ThemeAddon<ThemeData>(
          themes: themes,
          initialTheme: themes.first,
          // Paint the canvas with the selected theme and add breathing room.
          // The builder runs below `appBuilder`, so the whole canvas — not just
          // the use case — follows the chosen theme.
          themeBuilder: (context, theme, child) {
            return Theme(
              data: theme,
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor,
                child: DefaultTextStyle(
                  style: theme.textTheme.bodyMedium!,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ],
      directories: directories,
    );
  }
}
