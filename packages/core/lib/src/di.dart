import 'package:flutter/widgets.dart';

/// Minimal service locator: lazy singletons and factories, keyed by type.
class Injector {
  final Map<Type, Object Function(Injector)> _factories = {};
  final Map<Type, Object Function(Injector)> _singletonFactories = {};
  final Map<Type, Object> _singletons = {};

  /// Registers [create] to build a single [T], cached on first [get].
  void registerLazySingleton<T extends Object>(T Function(Injector) create) {
    _singletonFactories[T] = create;
  }

  /// Registers [create] to build a fresh [T] on every [get].
  void registerFactory<T extends Object>(T Function(Injector) create) {
    _factories[T] = create;
  }

  /// Resolves [T] or throws [StateError] when nothing is registered.
  T get<T extends Object>() {
    final cached = _singletons[T];
    if (cached != null) return cached as T;

    final singletonFactory = _singletonFactories[T];
    if (singletonFactory != null) {
      final instance = singletonFactory(this) as T;
      _singletons[T] = instance;
      return instance;
    }

    final factory = _factories[T];
    if (factory != null) return factory(this) as T;

    throw StateError('Injector: no registration for $T');
  }
}

/// Exposes an [Injector] to the widget tree.
class DependencyScope extends InheritedWidget {
  const DependencyScope({
    super.key,
    required this.injector,
    required super.child,
  });

  /// The container available to descendants.
  final Injector injector;

  /// The nearest [Injector] above [context]. Reads without subscribing, so
  /// it is safe in `initState`; the injector is expected to live for the
  /// whole app.
  static Injector of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DependencyScope>();
    assert(scope != null, 'DependencyScope: no scope found above this context');
    return scope!.injector;
  }

  @override
  bool updateShouldNotify(DependencyScope oldWidget) =>
      injector != oldWidget.injector;
}

/// `context.get<T>()` sugar over [DependencyScope.of].
extension DiX on BuildContext {
  /// Resolves [T] from the nearest [DependencyScope].
  T get<T extends Object>() => DependencyScope.of(this).get<T>();
}
