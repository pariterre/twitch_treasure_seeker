///
/// To specify a specific type of listener, you can instantiate this class
/// as such:
class GenericListener<T extends Function> {
  ///
  /// Start listening.
  void listen(T callback) => _listeners.add(callback);

  ///
  /// Stop listening.
  void cancel(T callback) => _listeners.remove(callback);

  ///
  /// Stop all listeners.
  void cancelAll() => _listeners.clear();

  ///
  /// Notify all listeners.
  void notifyListeners(void Function(T) callback) =>
      _listeners.forEach(callback);

  int get length => _listeners.length;

  ///
  /// List of active listeners to notify.
  final List<T> _listeners = [];
}
