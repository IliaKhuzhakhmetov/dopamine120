import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/domain/entities/app_theme.dart';
import '../../../core/theme/presentation/theme_provider.dart';
import '../../../l10n/l10n.dart';
import '../../application/presentation/router/app_router.dart';
import '../../platform/domain/usecases/get_app_info.dart';
import '../../platform/presentation/controller/app_version_controller.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppVersionController _versionController;

  @override
  void initState() {
    super.initState();
    _versionController = AppVersionController(
      DependencyScope.of(context).get<GetAppInfo>(),
    );
    _versionController.load();
  }

  @override
  void dispose() {
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: DopResponsivePane(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                DopText.label('DOPAMINE120', color: colors.accent),
                const SizedBox(height: 16),
                DopText.header(l10n.homeTitle),
                const SizedBox(height: 16),
                DopText.body(l10n.homeBody, color: colors.inkSoft),
                const SizedBox(height: 32),
                DopButton.primary(
                  label: l10n.homeOpenFocus,
                  onPressed: () => context.router.push(FocusRoute()),
                ),
                const SizedBox(height: 12),
                DopButton.outline(
                  label: l10n.homeOpenDeprivation,
                  onPressed: () =>
                      context.router.push(const DeprivationRoute()),
                ),
                const SizedBox(height: 12),
                DopButton.outline(
                  label: l10n.homeOpenImagination,
                  onPressed: () =>
                      context.router.push(const ImaginationRoute()),
                ),
                const SizedBox(height: 24),
                DopDropdown<AppTheme>(
                  label: l10n.homeThemeLabel,
                  value: context.appTheme,
                  onChanged: context.themeController.setTheme,
                  options: [
                    for (final theme in AppTheme.values)
                      DopDropdownOption(
                        value: theme,
                        label: DopThemes.byId(theme.storageValue).label,
                        subtitle: DopThemes.byId(
                          theme.storageValue,
                        ).description,
                      ),
                  ],
                ),
                const Spacer(flex: 2),
                ValueListenableBuilder<String?>(
                  valueListenable: _versionController,
                  builder: (context, version, _) {
                    if (version == null) return const SizedBox.shrink();
                    return DopText.label(
                      l10n.homeVersion(version),
                      color: colors.inkSoft,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
