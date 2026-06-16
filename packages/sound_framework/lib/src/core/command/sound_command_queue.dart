/// Serializes async sound commands so UI gestures cannot race the backend.
class SoundCommandQueue {
  Future<void> _tail = Future<void>.value();

  /// Runs [command] after previously enqueued work completes.
  Future<T> enqueue<T>(Future<T> Function() command) {
    final result = _tail.then((_) => command());
    _tail = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }
}
