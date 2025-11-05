import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'i_repository.dart';
import '../models/base.dart';

typedef JsonFactory = Base Function(Map<String, dynamic> json);

class JsonRepository implements IRepository {
  final Map<String, Base> _data = {};
  final String _filename;
  final Map<String, JsonFactory> _typeRegistry;

  Future<void> _ioQueue = Future.value();

  JsonRepository({
    required this._filename,
    required this._typeRegistry,
  });

  @override
  Future<void> commit() {
    final dataSnapshot = Map<String, dynamic>.unmodifiable(
        _data.map((key, value) => MapEntry(key, value.toMap())));

    _ioQueue = _ioQueue.then((_) async {
      final jsonString = jsonEncode(dataSnapshot);
      await File(_filename).writeAsString(jsonString);
    }).catchError((e, s) {
      print("CRITICAL REPOSITORY COMMIT FAILED: $e");
      print(s);
      throw e;
    });

    return _ioQueue;
  }

  @override
  Future<void> reload() {
    _ioQueue = _ioQueue.then((_) async {
      final f = File(_filename);

      if (!await f.exists()) {
        await f.create(recursive: true);
        _data.clear();
        return;
      }

      final jsonString = await f.readAsString();
      if (jsonString.isEmpty) {
        _data.clear();
        return;
      }

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _data.clear();

      jsonMap.forEach((key, val) {
        final typeName = key.split('.').first;
        final factory = _typeRegistry[typeName];

        if (factory != null) {
          _data[key] = factory(val as Map<String, dynamic>);
        }
      });
    }).catchError((e, s) {
      print("CRITICAL REPOSITORY RELOAD FAILED: $e");
      print(s);
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
    _data[key] = obj;
  }

  @override
  Future<void> delete(Base obj) async {
    final key = obj.getKey();
    _data.remove(key);
  }
}


/*
 * =============================================================================
 * !!! ARCHITECTURAL WARNING - NOT FOR PRODUCTION USE !!!
 * =============================================================================
 *
 * This JsonRepository implementation uses an in-memory "Unit of Work" pattern.
 * It was designed for simplicity and to practice abstraction, but it has
 * critical performance and scalability drawbacks:
 *
 * 1. MEMORY BOTTLENECK:
 * The `reload()` method loads the *entire* database file into the `_data`
 * cache. This is not scalable and will cause an OutOfMemory crash
 * if the `tasks.json` file grows too large.
 *
 * 2. I/O BOTTLENECK:
 * The `_commit()` method *rewrites the entire* JSON file every time it's
 * called, even for a single object change. This is extremely inefficient
 * for frequent `save` or `delete` operations.
 *
 * 3. DATA LOSS RISK:
 * All changes (`save`, `delete`) only modify the in-memory `_data` cache.
 * If the application crashes or is terminated before `commit()` is
 * explicitly called, *all data from that session will be lost*.
 *
 * 4. POOR ABSTRACTION (ISP VIOLATION):
 * The `IRepository` contract (with `commit`/`reload`) is heavily
 * "opinionated" and assumes this specific in-memory/batch-save
 * workflow. This makes the interface incompatible with real-time or
 * transactional backends (like Firebase or a direct MySQL/API)
 * which handle persistence differently (e.g., per-operation, not per-session).
 */
