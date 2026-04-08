import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

class TodoFirestoreDataSource {
  TodoFirestoreDataSource._();
  static final instance = TodoFirestoreDataSource._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _todosRef(String uid) =>
      _db.collection('users').doc(uid).collection('todos');


  Future<List<TodoModel>> fetchTodos(String uid) async {
    try {
      final snapshot = await _todosRef(uid).get();
      return snapshot.docs
          .map((doc) => _fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return []; // return empty on network error — Hive is source of truth
    }
  }


  Future<void> saveTodo(String uid, TodoModel todo) async {
    try {
      await _todosRef(uid).doc(todo.id).set(_toMap(todo));
    } catch (_) {}
  }


  Future<void> saveAllTodos(String uid, List<TodoModel> todos) async {
    try {
      final batch = _db.batch();
      for (final todo in todos) {
        batch.set(_todosRef(uid).doc(todo.id), _toMap(todo));
      }
      await batch.commit();
    } catch (_) {}
  }


  Future<void> deleteTodo(String uid, String todoId) async {
    try {
      await _todosRef(uid).doc(todoId).delete();
    } catch (_) {}
  }


  Stream<List<TodoModel>> watchTodos(String uid) {
    return _todosRef(uid).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList());
  }


  Map<String, dynamic> _toMap(TodoModel todo) {
    return {
      'id': todo.id,
      'description': todo.description,
      'isComplete': todo.isComplete,
      'addedDate': todo.addedDate.toIso8601String(),
      'dueDate': todo.dueDate?.toIso8601String(),
      'reminderTime': todo.reminderTime?.toIso8601String(),
      'startReminder': todo.startReminder?.toIso8601String(),
      'status': todo.status.index,
      'category': todo.category.index,
      'priority': todo.priority,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TodoModel _fromMap(String id, Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String? ?? id,
      description: map['description'] as String? ?? '',
      isComplete: map['isComplete'] as bool? ?? false,
      addedDate: DateTime.parse(map['addedDate'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'] as String)
          : null,
      startReminder: map['startReminder'] != null
          ? DateTime.parse(map['startReminder'] as String)
          : null,
      status: TodoStatus.values[map['status'] as int? ?? 0],
      category: TodoCategory.values[map['category'] as int? ?? 1],
      priority: map['priority'] as int? ?? 2,
    );
  }
}