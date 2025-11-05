import '../repositories/i_repository.dart';
import '../models/base.dart';
import '../models/task.dart';

class TaskService{
  final IRepository _repository;
  
  TaskService({required this._repository});

  Future<void> loadStorage() async{
    await _repository.reload();
  }

  Future<void> commitChanges() async{
    await _repository.commit();
  }

  Future<Task> createNewTask({required String title, String? content, DateTime? dueDate}) async{
    final newTask = Task(title: title, content: content, dueDate: dueDate);
    await _repository.save(newTask);
    return newTask;
  }

  Future<List<Task>> getAllTasks() async {
    final tasksMap = await _repository.getAllOfType<Task>();
    final tasksList = tasksMap.values.toList();
    
    tasksList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return tasksList;
  }

  Future<Task> updateTask({required String key ,String? title,String? content,DateTime? dueDate,bool? isDone}) async{
    final oldTask = await _repository.get(key);
    if (oldTask == null || oldTask is! Task) {
    throw Exception("Task Not Exists");
  }
    Task newTask = oldTask.copyWith(title: title,content: content, isDone: isDone, dueDate: dueDate);
    await _repository.save(newTask);
    return newTask;
  }

  Future<Task> changeTaskStatus({required String key}) async{
    final oldTask = await _repository.get(key);
    if (oldTask == null || oldTask is! Task){
      throw Exception("Task Not Exists");
    }
    Task newTask = oldTask.copyWith(isDone: !oldTask.isDone);
    await _repository.save(newTask);
    return newTask;
  }


  Future<void> deleteTask(String key) async {
    final task = await _repository.get(key);
    if (task != null) {
      await _repository.delete(task);
    } else {
      throw Exception("Task Not Exists");
    }
  }
}

