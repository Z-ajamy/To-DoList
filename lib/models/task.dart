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
  }) : super.internal(id: id, createdAt: createdAt);

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
  Map<String, dynamic> toMap() {
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
  String getKey(){
    return "Task.$id";
  }

  Task copyWith({
      String? title,
      String? content,
      DateTime? dueDate,
      bool? isDone,
    }) {
      return Task._internal(
        id: this.id,
        createdAt: this.createdAt,
        title: title ?? this.title,
        content: content ?? this.content,
        dueDate: dueDate ?? this.dueDate,
        isDone: isDone ?? this.isDone,
      );
    }
}
