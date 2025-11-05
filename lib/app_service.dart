import 'dart:convert';
import 'dart:io';

import 'package:to_dolist/repositories/json_repository.dart';

import './services/task_service.dart';
import './models/task.dart';
import './repositories/i_repository.dart';
import './repositories/json_repository.dart';


class AppService {

  static AppService? _onlyOneObj;

  final TaskService taskService;

  AppService._internal({required this.taskService});

  static Future<AppService> getTheObj() async{
    if (_onlyOneObj != null) {
      return _onlyOneObj!;
    }

    print("Starting app initialization...");
    final fileName = Platform.environment["TODO_DB_FILE"] ?? "data.json";

    final factories = <String, JsonFactory>{
      "Task" : (json) => Task.fromJson(json)
      };

    final typeOfStorage = Platform.environment["TODO_DB_STORAGE"] ?? "JSON";
    final IRepository? repository;

    if (typeOfStorage == "JSON") {
      repository = JsonRepository(_filename: fileName, _typeRegistry: factories);
    }
    
    print("loading data...");
    try{
      await repository.reload();
    } catch(e, s){
      print("!! CRITICAL: Failed to load storage. $e");
      print(s);
      throw Exception("Failed to initialize app: $e");
    }

    final TaskService taskService = TaskService(_repository: repository);

    _onlyOneObj = AppService._internal(taskService: taskService);

    print("App is ready.");
    return _onlyOneObj;
  }
}
