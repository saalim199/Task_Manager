class Task {
  String? id;
  String? taskText;
  bool isDone;

  Task({
    required this.id,
    required this.taskText,
    this.isDone = false,
  });

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        id: json['id'],
        taskText: json['taskText'],
        isDone: json['isDone'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'taskText': taskText,
        'isDone': isDone ? 1 : 0,
      };
}
