/// A single business action: call with [P], get a [Future] of [R].
abstract class UseCase<R, P> {
  /// Executes the action.
  Future<R> call(P params);
}

/// Argument for use cases that take no input.
class NoParams {
  const NoParams();
}
