import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// `context.l10n` sugar over [AppLocalizations.of].
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
