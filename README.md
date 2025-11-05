# Dart Full-Stack Core: Task Manager (CLI)

![Language](https://img.shields.io/badge/Language-Dart-0175C2.svg)
![Architecture](https://img.shields.io/badge/Architecture-3--Tier_Clean-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A robust, scalable, and testable application core for a Task Management system, written entirely in pure Dart. This project serves as the foundational "backend" and "business logic" layer, starting with a Command-Line Interface (CLI).

This project is built from the ground up to be **extensible** and **platform-agnostic**. The architecture is designed to support future expansion into a full-stack application (Flutter Frontend, Dart/Firebase Backend) by strictly adhering to SOLID principles, especially Dependency Injection and Interface Segregation.

---

## 🏛️ Core Architectural Design

This project is not a simple script; it is a 3-Tier Layered Application. This separation of concerns is the project's main feature, allowing for independent development and testing of each layer.



1.  **UI / Presentation Layer (`bin/main.dart`)**
    * **Responsibility:** Only "showing" information and "capturing" user input.
    * It is "dumb" and holds no business logic.
    * It only communicates with the `Service` layer.
    * *This layer is designed to be completely replaceable with a Flutter UI or a REST API.*

2.  **Service Layer (`lib/services/task_service.dart`)**
    * **Responsibility:** The "Brain" of the application.
    * It contains all **Business Logic** (e.g., validation, sorting, state changes).
    * It knows nothing about the UI or how data is stored.
    * It communicates only with the `Repository` interface (`IRepository`).

3.  **Data Layer (`lib/repositories/`)**
    * **Responsibility:** The "Hands" of the application.
    * Handles the "how" and "where" of data persistence (I/O).
    * This layer is split into an **Abstraction** (`IRepository`) and an **Implementation** (`JsonRepository`).

---

### 🔑 Key Design Patterns Used

* **Repository Pattern:** `IRepository` acts as an abstract contract. The Service layer depends on this abstraction, not on the concrete `JsonRepository`. This allows us to swap `JsonRepository` with `FirebaseRepository` or `SqlRepository` in the future without changing a single line in the Service layer.
* **Unit of Work (UoW):** The `IRepository` interface is built around a UoW pattern. Changes (`save`, `delete`) are made to an in-memory cache (`_data`) and are only persisted when `commit()` is called. This is highly efficient for batch operations.
* **Dependency Injection (DI) & Composition Root:** We avoid "hard-coding" dependencies. The `AppService` class acts as our **Composition Root**. It reads environment variables, initializes the correct `Repository`, and "injects" it into the `TaskService`, which is then provided to the UI.
* **Factory Pattern:** The `JsonRepository` is decoupled from concrete models (like `Task`) by requiring a `Map<String, JsonFactory>`. This makes the repository extensible to new models (`User`, `Note`) without modifying its source code (Open/Closed Principle).
* **Professional Logging:** A dedicated `ILogger` interface is injected into all services and repositories, allowing us to toggle logging from a central location (`AppService`) or swap file logging for cloud logging.

---

## 📁 File Structure

```
.
├── bin/
│   └── main.dart           # (Layer 1: UI + Composition Root)
├── lib/
│   ├── app_service.dart      # (The App "Container")
│   ├── logging/
│   │   ├── file_logger.dart  # (Implementation)
│   │   ├── i_logger.dart     # (Abstraction)
│   │   └── null_logger.dart  # (Implementation)
│   ├── models/
│   │   ├── base.dart         # (Abstract Model with id, createdAt)
│   │   └── task.dart         # (Concrete Model)
│   ├── repositories/
│   │   ├── i_repository.dart     # (Abstraction - The "Contract")
│   │   └── json_repository.dart  # (Implementation - JSON Storage)
│   └── services/
│       └── task_service.dart   # (Layer 2: Business Logic)
├── logs/
│   └── (Session logs are generated here...)
├── data.json                   # (Default database file)
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

* [Dart SDK](https://dart.dev/get-dart) (v3.0 or later)
* (Recommended) An IDE like Visual Studio Code

### Installation & Running

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd To-DoList
    ```

2.  **Install dependencies:**
    (This will fetch `uuid`, `intl`, and `path` from `pubspec.yaml`)
    ```bash
    dart pub get
    ```

3.  **Run the application:**
    ```bash
    dart run bin/main.dart
    ```

4.  **Run with Logging Enabled:**
    The application will create a new log file in the `logs/` directory for your session.
    ```bash
    dart run bin/main.dart -logs
    ```

5.  **Run with Custom Settings (Environment Variables):**
    You can specify a different database file or storage type (once implemented) using environment variables.

    ```bash
    # (Linux/macOS)
    export TODO_DB_FILE=prod_data.json
    dart run bin/main.dart

    # (Windows - PowerShell)
    $env:TODO_DB_FILE = "prod_data.json"
    dart run bin/main.dart
    ```

---

## 💻 Available Commands

The CLI operates like a classic console (e.g., `hbnb`).

| Command | Arguments | Description |
| :--- | :--- | :--- |
| `create` | `task title=<Your_Title>` | Creates a new task in memory. |
| `all` | `task` | Lists all tasks from memory, sorted by newest. |
| `all` | (no arguments) | Dumps the *entire* raw JSON cache from memory. |
| `getinfo` | `<key>` (e.g., `Task.123...`) | Dumps the raw JSON for a single object. |
| `change` | `<key>` (e.g., `Task.123...`) | Toggles the `isDone` status of a task. |
| `delete` | `<key>` (e.g., `Task.123...`) | Deletes a task from memory. |
| `commit` | (no arguments) | Saves all in-memory changes to the `data.json` file. |
| `exit` | (no arguments) | Automatically calls `commit` and exits the program. |
| `help` | (no arguments) | Displays this help message. |

---

## 🛠️ Architectural Trade-offs (Pros & Cons)

This architecture was chosen to prioritize **Testability** and **Abstraction** over raw performance for this specific use case (local JSON file).

### ✅ Advantages

* **Testable:** All classes are "POJOs" (Plain Old Dart Objects). `JsonRepository` and `TaskService` can be instantiated in a test file with mock dependencies (e.g., a `test.json` file or a "mock" repository).
* **Extensible (Open/Closed):** The `JsonFactory` registry in `JsonRepository` allows new models (`User`, `Note`) to be added without *ever* modifying `JsonRepository`'s code.
* **Decoupled (Decoupled):** The UI (`main.dart`) is completely unaware of *how* data is stored (JSON, Firebase, etc.). The Service Layer (`TaskService`) is also unaware. This is a robust separation of concerns.

### ⚠️ Disadvantages (The "Architectural Warning")

As noted in the code, the `JsonRepository` implementation is **not for production use** at scale.
* **1. Memory Bottleneck:** `reload()` loads the *entire* database file into memory. This will crash the app if `data.json` becomes too large.
* **2. I/O Bottleneck:** `commit()` *rewrites the entire* file for every commit. This is highly inefficient.
* **3. Data Loss Risk:** The "Unit of Work" pattern means all changes (`save`, `delete`) are in-memory only. If the app crashes before `commit`, all data from that session is lost.
* **4. Abstraction Mismatch (ISP Violation):** The `IRepository` contract (with `commit`/`reload`) is "opinionated" for this local workflow. A real-time backend like Firebase *does not* have `commit` or `reload` methods. A future `FirebaseRepository` would need to implement these methods as empty stubs or throw errors, which is not ideal.

---

## 🛣️ Future Roadmap

This project is the **Core** for a full-stack application. The architecture is ready for the following expansions:

### 1. Backend Expansion
* [ ] **Add New Models:** Create `User` and `Note` classes inheriting from `Base`.
* [ ] **Add New Services:** Create `UserService` and `NoteService` (following Microservice principles) and add them to `AppService`.
* [ ] **Swap Data Layer (Firebase):**
    * Create `FirebaseRepository implements IRepository`.
    * `save()` -> `firestore.collection.doc.set()`
    * `delete()` -> `firestore.collection.doc.delete()`
    * `all()` -> `firestore.collection.get()`
    * `commit()` / `reload()` will be empty (Firebase is real-time).
    * Change **one line** in `app_service.dart` to inject `FirebaseRepository` instead of `JsonRepository`.
* [ ] **Build a REST API (Dart Backend):**
    * Create a new `bin/api_server.dart`.
    * Use a Dart server package (like `shelf` or `conduit`).
    * The API endpoints (e.g., `POST /task`) will call the *exact same* `appService.taskService.createNewTask(...)` that the CLI uses.

### 2. Frontend Expansion (Flutter)
* [ ] **Create a new Flutter project.**
* [ ] **Import this project's `lib/` folder** directly.
* [ ] The Flutter `main.dart` will become the new "Composition Root," initializing `AppService` just as the CLI does.
* [ ] All Flutter Widgets (UI) will get their data by calling `appService.taskService`, ensuring the *exact same* business logic is shared between the CLI and the Flutter app.
