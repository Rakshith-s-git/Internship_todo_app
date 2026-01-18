import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all todos for a user
  Stream<List<Todo>> getTodos(String userId) {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Todo.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Add new todo
  Future<String?> addTodo({
    required String userId,
    required String title,
    required String description,
    DateTime? dueDate,
    String priority = 'medium', // ⭐ NEW
  }) async {
    try {
      if (title.trim().isEmpty) {
        return 'Title cannot be empty';
      }

      await _firestore.collection('todos').add({
        'userId': userId,
        'title': title.trim(),
        'description': description.trim(),
        'isCompleted': false,
        'createdAt': DateTime.now(),
        'dueDate': dueDate,
        'priority': priority, // ⭐ NEW
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Update todo
  Future<String?> updateTodo({
    required String todoId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority, // ⭐ NEW
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (title != null && title.isNotEmpty) {
        updates['title'] = title.trim();
      }
      if (description != null) {
        updates['description'] = description.trim();
      }
      if (isCompleted != null) {
        updates['isCompleted'] = isCompleted;
      }
      if (dueDate != null) {
        updates['dueDate'] = dueDate;
      }
      if (priority != null) {
        updates['priority'] = priority; // ⭐ NEW
      }

      if (updates.isEmpty) {
        return 'No updates provided';
      }

      await _firestore.collection('todos').doc(todoId).update(updates);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Delete todo
  Future<String?> deleteTodo(String todoId) async {
    try {
      await _firestore.collection('todos').doc(todoId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Toggle todo completion status
  Future<String?> toggleTodoStatus(String todoId, bool currentStatus) async {
    try {
      await _firestore.collection('todos').doc(todoId).update({
        'isCompleted': !currentStatus,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
