/// App-supported visual themes.
enum AppTheme {
  light('light'),
  dark('dark');

  const AppTheme(this.storageValue);

  final String storageValue;

  static AppTheme fromStorageValue(String? value) {
    return switch (value) {
      'dark' => AppTheme.dark,
      _ => AppTheme.light,
    };
  }
}
