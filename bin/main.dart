import 'dart:io';
import 'dart:convert';
import '../lib/app_service.dart';
import '../lib/logging/i_logger.dart';
import '../lib/services/task_service.dart';

Future<void> main(List<String> args) async {
  final AppService appService;
  try {
    appService = await AppService.getTheObj(args);
  } catch (e) {
    print("ERROR WHITH INIT $e");
    return;
  }

  final ILogger logger = appService.logger;
  final TaskService taskService = appService.taskService;
  
  logger.log("--- Session Started ---");
  print("--- (To-DoList CLI) ---");

  while (true) {
    stdout.write("> ");
    final input = stdin.readLineSync();
    if (input == null || input.isEmpty) continue;

    logger.log("User command: $input");

    try {
      final parts = input.split(' ');
      final command = parts[0].toLowerCase();
      String objName, key;
      
      final jsonPrettyPrinter = JsonEncoder.withIndent('  ');

      switch (command) {
        case 'create':
          if (parts.length < 2) throw Exception("Usage: create <Type> <args>=...");
          objName = parts[1].toLowerCase();

          if (objName == 'task') {
            final title = _parseArgument(parts, 'title=');
            final task = await taskService.createNewTask(title: title);
            print("Task created successfully: ${task.getKey()}");
          } else if (objName == 'user') {
            print("User creation coming soon.");
          } else {
            print("Unknown type: $objName");
          }
          break;

        case 'all':
          if (parts.length < 2) {
            logger.log("Command: all-json");
            final allData = await taskService.getAllData();
            final jsonMap = allData.map((key, value) => MapEntry(key, value.toMap()));
            print(jsonPrettyPrinter.convert(jsonMap));
            break;
          }
          
          objName = parts[1].toLowerCase();
          if (objName == 'task') {
            final tasks = await taskService.getAllTasks();
            print("--- All Tasks (Sorted) ---");
            if (tasks.isEmpty) print("(No tasks)");
            tasks.forEach((task) {
              final status = task.isDone ? '[X]' : '[ ]';
              print("$status ${task.getKey()}: ${task.title}");
            });
          } else if (objName == 'user') {
            print("User 'all' coming soon.");
          } else {
            print("Unknown type: $objName");
          }
          break;
        
        case 'getinfo':
          if (parts.length < 2) throw Exception("Usage: getinfo <Key>");
          key = parts[1];
          final entity = await taskService.getDataByKey(key);
          print(jsonPrettyPrinter.convert(entity.toMap()));
          break;

        case 'change':
          if (parts.length < 2) throw Exception("Usage: change <Key>");
          key = parts[1];
          if (key.startsWith("Task.")) {
            await taskService.changeTaskStatus(key: key);
            print("Task status updated in memory.");
          } else {
            print("This command only works for Tasks.");
          }
          break;

        case 'delete':
          if (parts.length < 2) throw Exception("Usage: delete <Key>");
          key = parts[1];
          await taskService.deleteTask(key);
          print("Task deleted from memory.");
          break;

        case 'commit':
          await taskService.commitChanges();
          print("All changes saved to file.");
          break;

        case 'exit':
          await taskService.commitChanges();
          print("Changes saved. Goodbye!");
          await logger.dispose();
          return;

        case 'help':
          print("  create <type> title=<title> (e.g., create task title=My_Task)");
          print("  all <type> (e.g., all task)");
          print("  all (NEW: Dumps all data as JSON)");
          print("  getinfo <key> (NEW: Dumps one object as JSON)");
          print("  change <key> (e.g., change Task.123)");
          print("  delete <key> (e.g., delete Task.123)");
          print("  commit");
          print("  exit");
          break;

        default:
          print("Unknown command: $command.");
      }
    } catch (e, s) {
      logger.error("Command failed: $input", e, s);
      print("!! Error: $e");
    }
  }
}

String _parseArgument(List<String> parts, String prefix) {
  final arg = parts.firstWhere(
    (part) => part.startsWith(prefix),
    orElse: () => '',
  );

  if (arg.isEmpty) {
    throw Exception("Argument '$prefix' is missing.");
  }
  return arg.substring(prefix.length).replaceAll('_', ' ');
}
