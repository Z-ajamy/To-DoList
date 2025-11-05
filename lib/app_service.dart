import 'dart:io';
import 'package:intl/intl.dart';
import './services/task_service.dart';
import './models/task.dart';
import './repositories/i_repository.dart';
import './repositories/json_repository.dart';
import './logging/i_logger.dart';
import './logging/file_logger.dart';
import './logging/null_logger.dart';

class AppService {
  final TaskService taskService;
  final ILogger logger;

  static AppService? _onlyOneObj;

  AppService._internal({
    required this.taskService,
    required this.logger,
  });

  static Future<AppService> getTheObj(List<String> args) async {
    if (_onlyOneObj != null) {
      return _onlyOneObj!;
    }

    print("Starting app initialization...");

    final ILogger appLogger;
    if (args.contains('-logs')) {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final logFilename = 'logs/session_$timestamp.log';
      appLogger = FileLogger(logFilename);
      print("Logging enabled. Writing to $logFilename");
    } else {
      appLogger = const NullLogger();
    }

    appLogger.log("AppService starting...");
    appLogger.log("Reading environment variables...");

    final fileName = Platform.environment["TODO_DB_FILE"] ?? "data.json";
    final factories = <String, JsonFactory>{
      "Task": (json) => Task.fromJson(json),
    };

    final typeOfStorage = Platform.environment["TODO_DB_STORAGE"] ?? "JSON";
    final IRepository? repository;

    appLogger.log("Initializing repository (Type: $typeOfStorage, File: $fileName)");
    if (typeOfStorage == "JSON") {
      repository = JsonRepository(
        filename: fileName,
        typeRegistry: factories,
        logger: appLogger,
      );
    } else {
      final errorMsg = "Not valid TODO_DB_STORAGE value: $typeOfStorage";
      appLogger.error(errorMsg);
      throw Exception(errorMsg);
    }

    appLogger.log("Loading data from storage...");
    try {
      await repository.reload();
    } catch (e, s) {
      appLogger.error("CRITICAL: Failed to load storage.", e, s);
      throw Exception("Failed to initialize app: $e");
    }

    appLogger.log("Initializing services...");
    final taskService = TaskService(
      repository: repository,
      logger: appLogger,
    );

    _onlyOneObj = AppService._internal(
      taskService: taskService,
      logger: appLogger,
    );

    appLogger.log("App is ready.");
    return _onlyOneObj!;
  }
}
