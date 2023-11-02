class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  String time;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    required this.time,
  });

  ToDo copyWith({
    String? id,
    String? todoText,
    bool? isDone,
    String? time,
  }) {
    return ToDo(
      id: id ?? this.id,
      todoText: todoText ?? this.todoText,
      isDone: isDone ?? this.isDone,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
      'time': time,
    };
  }
}
