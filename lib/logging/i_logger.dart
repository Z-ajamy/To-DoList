abstract class ILogger {
  void log(String message);
  void error(String message, [Object? e, StackTrace? s]);
  Future<void> dispose();
}
