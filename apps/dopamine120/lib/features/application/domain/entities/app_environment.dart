enum AppFlavor { dev, prod }

enum AppPersistence { inMemory, sharedPreferences }

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.persistence,
    required this.title,
  });

  static const dartDefineName = 'APP_ENV';

  static final current = fromName(
    const String.fromEnvironment(dartDefineName, defaultValue: 'prod'),
  );

  static const dev = AppEnvironment(
    flavor: AppFlavor.dev,
    persistence: AppPersistence.inMemory,
    title: 'DOPAMINE120 Dev',
  );

  static const prod = AppEnvironment(
    flavor: AppFlavor.prod,
    persistence: AppPersistence.sharedPreferences,
    title: 'DOPAMINE120',
  );

  final AppFlavor flavor;
  final AppPersistence persistence;
  final String title;

  static AppEnvironment fromName(String name) {
    return switch (name.trim().toLowerCase()) {
      'dev' || 'development' => dev,
      'prod' || 'production' => prod,
      _ => prod,
    };
  }

  bool get usesSharedPreferences =>
      persistence == AppPersistence.sharedPreferences;
}
