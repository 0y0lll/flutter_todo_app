import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String? id;
  String title;
  String content;
  String date;
  String updateDate;
  bool isPlanned;
  bool isDoing;
  bool isDone;

  Todo({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.updateDate,
    required this.isPlanned,
    required this.isDoing,
    required this.isDone,
  });

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, content: $content, date: $date, updateDate: $updateDate, isPlanned: $isPlanned, isDoing: $isDoing, isDone: $isDone}';
  }

  factory Todo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    return Todo(
        id: data?['id'],
        title: data?['title'],
        content: data?['content'],
        date: data != null ? data['date'].toString() : '',
        updateDate: data != null ? data['updateDate'].toString() : '',
        isPlanned: data?['isPlanned'],
        isDoing: data?['isDoing'],
        isDone: data?['isDone']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'date': date,
      'updateDate': updateDate,
      'isPlanned': isPlanned,
      'isDoing': isDoing,
      'isDone': isDone,
    };
  }
}

class TodoStatus {
  bool isPlanned = true;
  bool isDoing = false;
  bool isDone = false;

  TodoStatus();
}
