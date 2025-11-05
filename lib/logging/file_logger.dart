import 'dart:io';
import 'i_logger.dart';
import 'package:path/path.dart' as path;

class FileLogger implements ILogger {
  final IOSink _sink;

  static IOSink _initSink(String filename){
    final dir = path.dirname(filename);
    Directory(dir).createSync(recursive: true);
    return File(filename).openWrite(mode: FileMode.append);
  }

  FileLogger(String filename)
      : _sink = _initSink(filename);

  @override
  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _sink.writeln("[$timestamp] [INFO] $message");
  }

  @override
  void error(String message, [Object? e, StackTrace? s]) {
    final timestamp = DateTime.now().toIso8601String();
    _sink.writeln("[$timestamp] [ERROR] $message");
    if (e != null) _sink.writeln(e.toString());
    if (s != null) _sink.writeln(s.toString());
  }

  @override
  Future<void> dispose() async {
    await _sink.flush();
    await _sink.close();
  }
}
