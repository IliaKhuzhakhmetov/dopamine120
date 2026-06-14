import 'package:core/core.dart';

void registerStorageModule(
  Injector injector, {
  required KeyValueStore keyValueStore,
}) {
  injector.registerLazySingleton<KeyValueStore>((_) => keyValueStore);
}
