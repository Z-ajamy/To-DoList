import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

abstract class Base {
    final String id;
    final DateTime createdAt;

  Base(): id = uuid.v4(),
          createdAt = DateTime.now()  {
  }

  Base.internal({required String id, required DateTime createdAt})
    : id = id,
      createdAt = createdAt{
      }

  Map<String, dynamic> toMap();
  String getKey();
}
