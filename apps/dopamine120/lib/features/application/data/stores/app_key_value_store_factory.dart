import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/stores/app_preferences_allowlist.dart';
import '../../../../core/stores/shared_preferences_key_value_store.dart';
import '../../domain/entities/app_environment.dart';

class AppKeyValueStoreFactory {
  const AppKeyValueStoreFactory();

  Future<KeyValueStore> create(AppEnvironment environment) async {
    return switch (environment.persistence) {
      AppPersistence.inMemory => InMemoryKeyValueStore(),
      AppPersistence.sharedPreferences => SharedPreferencesKeyValueStore(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: AppPreferencesAllowlist.keys,
          ),
        ),
      ),
    };
  }
}
