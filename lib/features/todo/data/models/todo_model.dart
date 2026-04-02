import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

// ─── Category enum ────────────────────────────────────────────────────────────

@HiveType(typeId: 4)
enum TodoCategory {
  @HiveField(0) work,
  @HiveField(1) personal,
  @HiveField(2) professional,
  @HiveField(3) family,
  @HiveField(4) fitness,
  @HiveField(5) other,
}

// ─── Status enum ──────────────────────────────────────────────────────────────

@HiveType(typeId: 5)
enum TodoStatus {
  @HiveField(0) toDo,
  @HiveField(1) inProgress,
  @HiveField(2) inReview,
  @HiveField(3) done,
  @HiveField(4) blocked,
  @HiveField(5) onHold,
  @HiveField(6) rework,
}

// ─── TodoModel ────────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class TodoModel extends Equatable {
  static const _noValue = Object();

  @HiveField(0) final String id;
  @HiveField(1) final String description;
  @HiveField(2) final bool isComplete;
  @HiveField(3) final DateTime addedDate;
  @HiveField(4) final DateTime? dueDate;
  @HiveField(5) final DateTime? reminderTime;
  @HiveField(6) final DateTime? startReminder;
  @HiveField(7) final TodoStatus status;
  @HiveField(8) final TodoCategory category;
  @HiveField(9) final int priority;

  const TodoModel({
    required this.id,
    required this.description,
    this.isComplete = false,
    required this.addedDate,
    this.dueDate,
    this.reminderTime,
    this.startReminder,
    this.status = TodoStatus.toDo,
    this.category = TodoCategory.personal,
    this.priority = 2, // Default to medium
  });

  TodoModel copyWith({
    String? id,
    String? description,
    bool? isComplete,
    DateTime? addedDate,
    Object? dueDate = _noValue,
    Object? reminderTime = _noValue,
    Object? startReminder = _noValue,
    TodoStatus? status,
    TodoCategory? category,
    int? priority,
  }) {
    return TodoModel(
      id: id ?? this.id,
      description: description ?? this.description,
      isComplete: isComplete ?? this.isComplete,
      addedDate: addedDate ?? this.addedDate,
      dueDate: identical(dueDate, _noValue) ? this.dueDate : dueDate as DateTime?,
      reminderTime: identical(reminderTime, _noValue) ? this.reminderTime : reminderTime as DateTime?,
      startReminder: identical(startReminder, _noValue) ? this.startReminder : startReminder as DateTime?,
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  /// Map status → isComplete for toggle logic
  bool get isStatusComplete => status == TodoStatus.done;

  @override
  List<Object?> get props => [
    id, description, isComplete, addedDate,
    dueDate, reminderTime, startReminder, status, category, priority,
  ];
}
