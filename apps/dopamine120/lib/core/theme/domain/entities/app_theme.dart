/// App-supported visual themes.
///
/// [storageValue] matches the corresponding `DopThemeSpec.id` in the UI kit, so
/// the presentation layer resolves a theme with `DopThemes.byId(storageValue)`
/// without this domain entity depending on the UI kit. Adding a theme is one
/// entry here plus its spec in the kit.
enum AppTheme {
  light('light'),
  dark('dark'),
  room('room'),
  cathedral('cathedral'),
  underwater('underwater'),
  cosmos('cosmos'),
  jungle('jungle'),
  cave('cave');

  const AppTheme(this.storageValue);

  final String storageValue;

  static AppTheme fromStorageValue(String? value) {
    return AppTheme.values.firstWhere(
      (theme) => theme.storageValue == value,
      orElse: () => AppTheme.light,
    );
  }
}
