import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

// ─── Category enum ────────────────────────────────────────────────────────────

@HiveType(typeId: 4)
enum TodoCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  professional,
  @HiveField(3)
  family,
  @HiveField(4)
  fitness,
  @HiveField(5)
  other,
}

// ─── TodoModel ────────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class TodoModel extends Equatable {
  static const _noValue = Object();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final bool isComplete;

  @HiveField(3)
  final DateTime addedDate;

  @HiveField(4)
  final DateTime? dueDate;

  @HiveField(5)
  final DateTime? reminderTime;

  @HiveField(6)
  final DateTime? startReminder;

  @HiveField(7)
  final int priority;

  @HiveField(8)
  final TodoCategory category;

  const TodoModel({
    required this.id,
    required this.description,
    this.isComplete = false,
    required this.addedDate,
    this.dueDate,
    this.reminderTime,
    this.startReminder,
    this.priority = 2,
    this.category = TodoCategory.personal,
  });

  TodoModel copyWith({
    String? id,
    String? description,
    bool? isComplete,
    DateTime? addedDate,
    Object? dueDate = _noValue,
    Object? reminderTime = _noValue,
    Object? startReminder = _noValue,
    int? priority,
    TodoCategory? category,
  }) {
    return TodoModel(
      id: id ?? this.id,
      description: description ?? this.description,
      isComplete: isComplete ?? this.isComplete,
      addedDate: addedDate ?? this.addedDate,
      dueDate: identical(dueDate, _noValue) ? this.dueDate : dueDate as DateTime?,
      reminderTime: identical(reminderTime, _noValue) ? this.reminderTime : reminderTime as DateTime?,
      startReminder: identical(startReminder, _noValue) ? this.startReminder : startReminder as DateTime?,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
    id, addedDate, isComplete, description,
    dueDate, reminderTime, startReminder, priority, category,
  ];
}