import 'dart:io';
import 'dart:convert';
import 'i_repository.dart';
import '../models/base.dart';

typedef JsonFactory = Base Function(Map<String, dynamic> json);


class JsonRepository implements IRepository {
  static JsonRepository? _instance;

  Map<String, JsonFactory>? _typeRegistry;

  final Map<String, Base> _data = {};
  final String _filename = "data.json";

  JsonRepository._internal(this._typeRegistry);

  static Future<JsonRepository> getInstance({Map<String, JsonFactory>? factories}) async{
    
    if(_instance != null){
      return _instance!;
    }

    if (factories == null || factories.isEmpty) {
      throw ArgumentError("Factories must be provided on first initialization.");
    }
    else{
      _instance = JsonRepository._internal(factories);
      await _instance!._reload();
      return _instance!;
    }
  }

  Future<void> _commit() async {
    final Map<String, Map<String, dynamic>> jsonMap = {};
    _data.forEach((key, value) {
      jsonMap[key] = value.toMap();
    });

    final jsonString = json.encode(jsonMap);

    var f = File(_filename);
    try {
      if (!await f.exists()) {
        await f.create(recursive: true);
      }
      await f.writeAsString(jsonString);
    } catch (e) {
      print("Error writing to File $e");
    }
  }

  Future<void> _reload() async {
    final f = File(_filename);

    if (!await f.exists()) {
      await f.create(recursive: true);
      print("File created, no data to load.");
      return;
    }

    try {
      String jsonString = await f.readAsString();
      if (jsonString.isEmpty) {
        print("File is empty, loading done.");
        _data.clear();
        return;
      }

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      _data.clear();
      jsonMap.forEach((key, val) {
        final typeName = key.split('.').first;
        final factory = _typeRegistry?[typeName];
        if (factory != null){
          _data[key] = factory(val as Map<String, dynamic>);
        } else {
          print("Warning: No factory found for type '$typeName'.");
        }
    });

      print("loading is done. Loaded ${_data.length} items.");
    } catch (e) {
      print("Error reading from File $e");
      _data.clear();
    }
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
    await _commit();
  }

  @override
  Future<void> delete(Base obj) async {
    final key = obj.getKey();
    _data.remove(key);
    await _commit();
  }
}
