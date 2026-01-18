class Todo {
  final String id;
  final String userId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String priority; // ⭐ NEW

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = 'medium', // ⭐ DEFAULT
  });

  // Convert Todo to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'priority': priority, // ⭐ NEW
    };
  }

  // Create Todo from Firestore data
  factory Todo.fromMap(Map<String, dynamic> map, String docId) {
    return Todo(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as dynamic).toDate()
          : null,
      priority: map['priority'] ?? 'medium', // ⭐ SAFE DEFAULT
    );
  }

  // Create a copy of Todo with updated fields
  Todo copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    String? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}
