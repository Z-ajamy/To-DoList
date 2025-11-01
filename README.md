# 📝 Dart CLI Task Manager

A clean, well-architected command-line task manager built with pure Dart, demonstrating professional software design principles and separation of concerns.

## 🎯 Project Philosophy

While this application provides practical task management functionality, its **primary purpose is educational**: to showcase how to build maintainable, scalable software using clean architecture principles. Every design decision prioritizes flexibility, testability, and future extensibility.

## ✨ Current Features (Phase 1)

- ✅ **Add Tasks**: Create new tasks directly from the command line
- 📋 **View Tasks**: Display all saved tasks in an organized format
- 💾 **Persistent Storage**: Tasks are automatically saved to `tasks.json` and survive program restarts
- 🔄 **Switchable Architecture**: Storage implementation can be swapped (JSON → Database) without touching business logic

## 🏗️ Architecture Overview

This project implements **Clean Architecture** principles with a focus on:

### 1. **Separation of Concerns**
- **Model Layer** (`task.dart`): Pure data representation
- **Repository Layer** (`task_repository.dart`): Abstract contracts
- **Implementation Layer** (`json_storage.dart`): Concrete storage logic
- **Presentation Layer** (`main.dart`): User interface and application entry point

### 2. **Dependency Inversion**
The application depends on abstractions, not concrete implementations:
```dart
// ❌ Bad: Direct dependency on implementation
final storage = JsonTaskRepository();

// ✅ Good: Dependency on abstraction
final ITaskRepository storage = JsonTaskRepository();
```

### 3. **Repository Pattern**
The `ITaskRepository` interface defines a contract that any storage mechanism must fulfill:
- `getAllTasks()`: Retrieve all tasks
- `addTask(Task task)`: Save a new task
- Future methods: `updateTask()`, `deleteTask()`, etc.

## 🛠️ Technical Stack

### Language & Runtime
- **Dart SDK**: Pure Dart implementation (no Flutter dependencies)

### Core Libraries
| Library | Purpose |
|---------|---------|
| `dart:io` | Command-line I/O and file operations |
| `dart:convert` | JSON serialization/deserialization |
| `dart:async` | Asynchronous programming (Future, async/await) |

### Design Patterns
- **Repository Pattern**: Data access abstraction
- **Dependency Injection**: Loose coupling between components
- **Factory Pattern**: Object creation in model classes (`fromJson`)

## 📁 Project Structure

```
task_manager/
├── bin/
│   └── main.dart                 # Entry point & CLI interface
├── lib/
│   ├── task.dart                 # Task model (data structure)
│   ├── task_repository.dart      # Repository contract (interface)
│   └── json_storage.dart         # JSON implementation
└── tasks.json                    # Persistent storage file
```

### File Responsibilities

#### `bin/main.dart` (Presentation Layer)
- Handles user input/output
- Manages application flow
- Injects dependencies
- No direct knowledge of storage mechanism

#### `lib/task.dart` (Domain Layer)
- Defines the `Task` data model
- Contains serialization logic (`toJson`, `fromJson`)
- Pure business object with no external dependencies

#### `lib/task_repository.dart` (Abstraction Layer)
- Declares the `ITaskRepository` abstract class
- Defines the contract for all storage implementations
- Ensures consistency across different storage mechanisms

#### `lib/json_storage.dart` (Data Layer)
- Implements `ITaskRepository` using JSON files
- Handles file I/O operations asynchronously
- Manages error handling for file operations

#### `tasks.json` (Storage)
- Physical storage file created automatically
- Stores tasks in JSON array format
- Human-readable for debugging

## 🚀 Getting Started

### Prerequisites
- Dart SDK 2.19 or higher

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd task_manager

# Run the application
dart run bin/main.dart
```

### Basic Usage
```bash
# Add a task
> 1
Enter task description: Complete project documentation
✅ Task added successfully!

# View all tasks
> 2
📋 Your Tasks:
1. Complete project documentation

# Exit
> 3
```

## 🔮 Future Roadmap

The current architecture is designed to scale effortlessly. Here are planned enhancements:

### Phase 2: Alternative Storage
```dart
// SQLite implementation
class SqliteTaskRepository implements ITaskRepository {
  @override
  Future<List<Task>> getAllTasks() async {
    // Query from SQLite database
  }
}
```

### Phase 3: Cloud Integration
```dart
// Firebase implementation
class FirebaseTaskRepository implements ITaskRepository {
  @override
  Future<List<Task>> getAllTasks() async {
    // Fetch from Firestore
  }
}
```

### Phase 4: Cross-Platform UI
- **Flutter Mobile App**: Reuse the same repository layer
- **Web Interface**: Build a responsive web UI
- **Desktop Application**: Create native desktop experience

### Phase 5: Backend API
- Build a REST API using Dart (`shelf`/`conduit`)
- Serve multiple clients (web, mobile, desktop)
- Add authentication and multi-user support

## 🧪 Why This Architecture Matters

### Testability
```dart
// Mock repository for testing
class MockTaskRepository implements ITaskRepository {
  final List<Task> _tasks = [];
  
  @override
  Future<List<Task>> getAllTasks() async => _tasks;
}
```


### Maintainability
- Each component has a single responsibility
- Changes in one layer don't affect others
- New features can be added without breaking existing code

## 📚 Learning Outcomes

By studying this project, you'll understand:

1. **Clean Architecture Principles**: How to structure applications for long-term maintainability
2. **SOLID Principles**: Practical implementation of OOP best practices
3. **Async Programming**: Proper use of Future, async, and await in Dart
4. **Design Patterns**: Repository, Dependency Injection, and Factory patterns
5. **File I/O**: Safe and efficient file operations in Dart

## 🤝 Contributing

This is an educational project. Contributions that enhance the architectural clarity or add well-documented features are welcome!

## 👨‍💻 Author

Z-ajamy

---

**Note**: This project prioritizes code quality and architecture over feature completeness. It's designed to be a learning resource and a foundation for larger applications.
