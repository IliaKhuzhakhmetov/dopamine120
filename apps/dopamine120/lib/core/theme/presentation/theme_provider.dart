import 'package:flutter/widgets.dart';

import '../domain/entities/app_theme.dart';
import 'theme_controller.dart';

class ThemeProvider extends InheritedNotifier<ThemeController> {
  const ThemeProvider({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'ThemeProvider: no provider found above context');
    return provider!.notifier!;
  }
}

extension ThemeProviderContext on BuildContext {
  ThemeController get themeController => ThemeProvider.of(this);

  AppTheme get appTheme => themeController.theme;
}
