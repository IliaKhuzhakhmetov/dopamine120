import 'package:core/core.dart';
import 'package:dopamine120/features/application/application.dart';
import 'package:dopamine120/features/application/presentation/mobile_pwa_install_prompt.dart';
import 'package:dopamine120/l10n/l10n.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects only mobile web platforms', () {
    expect(
      mobilePwaInstallPlatform(isWeb: true, platform: TargetPlatform.iOS),
      MobilePwaInstallPlatform.ios,
    );
    expect(
      mobilePwaInstallPlatform(isWeb: true, platform: TargetPlatform.android),
      MobilePwaInstallPlatform.android,
    );
    expect(
      mobilePwaInstallPlatform(isWeb: true, platform: TargetPlatform.macOS),
      isNull,
    );
    expect(
      mobilePwaInstallPlatform(isWeb: false, platform: TargetPlatform.iOS),
      isNull,
    );
  });

  testWidgets('does not show again after got it', (tester) async {
    final store = InMemoryKeyValueStore();

    await tester.pumpWidget(_Host(store: store));
    await tester.pump();
    await tester.pump();

    expect(find.byType(DopSnackBar), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DopButton, 'got it'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_Host(store: store));
    await tester.pump();
    await tester.pump();

    expect(find.byType(DopSnackBar), findsNothing);
  });
}

class _Host extends StatelessWidget {
  const _Host({required this.store});

  final KeyValueStore store;

  @override
  Widget build(BuildContext context) {
    return DependencyScope(
      injector: createAppInjector(keyValueStore: store),
      child: MaterialApp(
        theme: DopTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: MobilePwaInstallPrompt(
            isWeb: true,
            platform: TargetPlatform.iOS,
            child: Text('home'),
          ),
        ),
      ),
    );
  }
}
