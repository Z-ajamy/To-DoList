import 'base.dart';

class Task extends Base {
  final String title;
  final String? content;
  final DateTime? dueDate;
  final bool isDone;

  Task({
    required this.title,
    this.content,
    this.dueDate,
    this.isDone = false,
  }) : super();

  Task._internal({
    required String id, // To super
    required DateTime createdAt, // To super

    required this.title, // required

    this.content, // not required becouse ?
    this.dueDate, // not required becouse ?
    this.isDone = false, // not required becouse the init "this.isDone = false"
  }) : super._internal(id: id, createdAt: createdAt);

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task._internal(
      id: json["id"] as String,
      createdAt: DateTime.parse(json["createdAt"] as String),
      title: json["title"] as String,
      content: json["content"] as String?,
      dueDate: json["dueDate"] != null
          ? DateTime.parse(json["dueDate"] as String)
          : null,
      isDone: json["isDone"] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> _toMap() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "title": title,
      "content": content,
      "dueDate": dueDate?.toIso8601String(),
      "isDone": isDone,
    };
  }

  @override
  Map<String, Map<String, dynamic>> toDict() {
    String name_id = "Task.$id";
    return {name_id: _toMap()};
  }

  Task copyWith({
      String? title,
      DateTime? dueDate,
      bool? isDone,
    }) {
      return Task._internal(
        id: this.id,
        createdAt: this.createdAt,
        title: title ?? this.title,
        dueDate: dueDate ?? this.dueDate,
        isDone: isDone ?? this.isDone,
      );
    }
}
