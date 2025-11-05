import 'i_logger.dart';

class NullLogger implements ILogger {
  const NullLogger();
  
  @override
  void log(String message) {}

  @override
  void error(String message, [Object? e, StackTrace? s]) {}

  @override
  Future<void> dispose() async {}
}
