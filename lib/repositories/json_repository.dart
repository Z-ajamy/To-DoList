import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'i_repository.dart';
import '../models/base.dart';
import '../logging/i_logger.dart';

typedef JsonFactory = Base Function(Map<String, dynamic> json);

class JsonRepository implements IRepository {
  final Map<String, Base> _data = {};
  final String _filename;
  final Map<String, JsonFactory> _typeRegistry;
  final ILogger _logger;

  Future<void> _ioQueue = Future.value();

  JsonRepository({
    required String filename,
    required final Map<String, JsonFactory> typeRegistry,
    required ILogger logger,
  })  : _filename = filename,
        _typeRegistry = typeRegistry,
        _logger = logger;

  @override
  Future<void> commit() {
    _logger.log("Commit: Taking data snapshot.");
    final dataSnapshot = Map<String, dynamic>.unmodifiable(
        _data.map((key, value) => MapEntry(key, value.toMap())));

    _ioQueue = _ioQueue.then((_) async {
      _logger.log("Commit: Writing ${_data.length} items to $_filename...");
      final jsonString = jsonEncode(dataSnapshot);
      await File(_filename).writeAsString(jsonString);
      _logger.log("Commit: Write successful.");
    }).catchError((e, s) {
      _logger.error("CRITICAL REPOSITORY COMMIT FAILED", e, s);
      throw e;
    });

    return _ioQueue;
  }

  @override
  Future<void> reload() {
    _ioQueue = _ioQueue.then((_) async {
      _logger.log("Reload: Reading from $_filename...");
      final f = File(_filename);

      if (!await f.exists()) {
        await f.create(recursive: true);
        _data.clear();
        _logger.log("Reload: File not found, created empty file.");
        return;
      }

      final jsonString = await f.readAsString();
      if (jsonString.isEmpty) {
        _data.clear();
        _logger.log("Reload: File is empty, starting fresh.");
        return;
      }

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _data.clear();

      jsonMap.forEach((key, val) {
        final typeName = key.split('.').first;
        final factory = _typeRegistry[typeName];

        if (factory != null) {
          _data[key] = factory(val as Map<String, dynamic>);
        } else {
          _logger.log("Reload: Warning! No factory found for type '$typeName'.");
        }
      });
      _logger.log("Reload: Done. Loaded ${_data.length} items.");
    }).catchError((e, s) {
      _logger.error("CRITICAL REPOSITORY RELOAD FAILED", e, s);
      _data.clear();
      throw e;
    });

    return _ioQueue;
  }

  @override
  Future<Map<String, Base>> all() async {
    return Map.unmodifiable(_data);
  }

  @override
  Future<Base?> get(String key) async {
    return _data[key];
  }

  @override
  Future<Map<String, T>> getAllOfType<T extends Base>() async {
    final Map<String, T> filteredMap = {};
    _data.forEach((key, value) {
      if (value is T) {
        filteredMap[key] = value;
      }
    });
    return Map.unmodifiable(filteredMap);
  }

  @override
  Future<void> save(Base obj) async {
    final key = obj.getKey();
    _logger.log("Cache: Saving entity $key to memory.");
    _data[key] = obj;
  }

  @override
  Future<void> delete(Base obj) async {
    final key = obj.getKey();
    _logger.log("Cache: Deleting entity $key from memory.");
    _data.remove(key);
  }
}
