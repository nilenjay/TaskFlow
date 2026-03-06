import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)

class TodoModel extends Equatable{
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
  final DateTime ? dueDate;

  @HiveField(5)
  final DateTime? reminderTime;

  @HiveField(6)
  final DateTime? startReminder;

  const TodoModel({
    required this.id,
    required this.description,
    this.isComplete=false,
    required this.addedDate,
    this.dueDate,
    this.reminderTime,
    this.startReminder
});

  TodoModel copyWith({
    String? id,
    String? description,
    bool? isComplete,
    DateTime? addedDate,
    Object? dueDate = _noValue,
    Object? reminderTime = _noValue,
  }) {
    return TodoModel(
      id: id ?? this.id,
      description: description ?? this.description,
      isComplete: isComplete ?? this.isComplete,
      addedDate: addedDate ?? this.addedDate,
      dueDate: identical(dueDate, _noValue,)
          ? this.dueDate
          : dueDate as DateTime?,
      reminderTime: identical(reminderTime, _noValue)
          ? this.reminderTime
          : reminderTime as DateTime?,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id,addedDate,isComplete,description,dueDate,reminderTime];
}