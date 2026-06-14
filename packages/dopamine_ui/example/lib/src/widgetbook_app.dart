import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook shell for the dopamine_ui package.
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({required this.directories, super.key});

  final List<WidgetbookNode> directories;

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
      directories: directories,
    );
  }
}
