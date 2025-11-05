// lib/services/task_service.dart
import '../repositories/i_repository.dart';
import '../models/base.dart';
import '../models/task.dart';
import '../logging/i_logger.dart';

class TaskService {
  final IRepository _repository;
  final ILogger _logger;

  TaskService({required IRepository repository, required ILogger logger})
      : _repository = repository,
        _logger = logger;

  Future<void> loadStorage() async {
    _logger.log("Service: Requesting storage reload.");
    await _repository.reload();
  }

  Future<void> commitChanges() async {
    _logger.log("Service: Requesting storage commit.");
    await _repository.commit();
  }

  Future<Task> createNewTask(
      {required String title, String? content, DateTime? dueDate}) async {
    _logger.log("Service: createNewTask invoked for '$title'");
    if (title.isEmpty) {
      _logger.error("Service: Task creation failed: Title was empty.");
      throw Exception("Title is required!");
    }

    final newTask = Task(title: title, content: content, dueDate: dueDate);
    await _repository.save(newTask);
    _logger.log("Service: Task ${newTask.getKey()} saved to cache.");
    return newTask;
  }

  Future<List<Task>> getAllTasks() async {
    _logger.log("Service: getAllTasks invoked.");
    final tasksMap = await _repository.getAllOfType<Task>();
    final tasksList = tasksMap.values.toList();

    tasksList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _logger.log("Service: Returning ${tasksList.length} tasks, sorted.");

    return tasksList;
  }

  Future<Task> updateTask(
      {required String key,
      String? title,
      String? content,
      DateTime? dueDate,
      bool? isDone}) async {
    _logger.log("Service: updateTask invoked for $key.");
    final oldTask = await _repository.get(key);
    if (oldTask == null || oldTask is! Task) {
      _logger.error("Service: Update failed. Task $key Not Exists");
      throw Exception("Task Not Exists");
    }
    Task newTask = oldTask.copyWith(
        title: title, content: content, isDone: isDone, dueDate: dueDate);
    await _repository.save(newTask);
    _logger.log("Service: Task $key updated in cache.");
    return newTask;
  }

  Future<Task> changeTaskStatus({required String key}) async {
    _logger.log("Service: changeTaskStatus invoked for $key.");
    final oldTask = await _repository.get(key);
    if (oldTask == null || oldTask is! Task) {
      _logger.error("Service: Change status failed. Task $key Not Exists");
      throw Exception("Task Not Exists");
    }
    Task newTask = oldTask.copyWith(isDone: !oldTask.isDone);
    await _repository.save(newTask);
    _logger.log("Service: Task $key status changed in cache.");
    return newTask;
  }

  Future<void> deleteTask(String key) async {
    _logger.log("Service: deleteTask invoked for $key.");
    final task = await _repository.get(key);
    if (task != null) {
      await _repository.delete(task);
      _logger.log("Service: Task $key deleted from cache.");
    } else {
      _logger.error("Service: Delete failed. Task $key Not Exists");
      throw Exception("Task Not Exists");
    }
  }

  Future<Map<String, Base>> getAllData() async {
    _logger.log("Service: getAllData invoked.");
    return await _repository.all();
  }

  Future<Base> getDataByKey(String key) async {
    _logger.log("Service: getDataByKey invoked for $key.");
    final entity = await _repository.get(key);
    if (entity == null) {
      _logger.error("Service: Get info failed. Key $key Not Exists");
      throw Exception("Key Not Exists");
    }
    return entity;
  }
}
