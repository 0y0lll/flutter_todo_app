import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Todo {
  String title;
  String content;
  String date;
  String updateDate;
  bool isPlanned;
  bool isDoing;
  bool isDone;

  Todo({
    required this.title,
    required this.content,
    required this.date,
    required this.updateDate,
    required this.isPlanned,
    required this.isDoing,
    required this.isDone,
  });

  factory Todo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    return Todo(
        title: data?['title'],
        content: data?['content'],
        date:
            DateFormat.yMMMMd('ko_KR').add_jm().format(data?['date'].toDate()),
        updateDate: DateFormat.yMMMMd('ko_KR')
            .add_jm()
            .format(data?['updateDate'].toDate()),
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
