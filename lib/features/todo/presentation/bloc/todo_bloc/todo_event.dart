import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import '../../data/models/todo_filter.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

class AddTodo extends TodoEvent {
  final String description;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final DateTime? startReminder;
  final int priority;
  final TodoCategory category;

  const AddTodo({
    required this.description,
    this.dueDate,
    this.reminderTime,
    this.startReminder,
    this.priority = 2,
    this.category = TodoCategory.personal,
  });

  @override
  List<Object?> get props =>
      [description, dueDate, reminderTime, startReminder, priority, category];
}

class DeleteTodo extends TodoEvent {
  final String id;
  const DeleteTodo({required this.id});
  @override
  List<Object?> get props => [id];
}

class ToggleTodoStatus extends TodoEvent {
  final String id;
  const ToggleTodoStatus({required this.id});
  @override
  List<Object?> get props => [id];
}

class RestoreTodo extends TodoEvent {
  final TodoModel todo;
  const RestoreTodo({required this.todo});
  @override
  List<Object?> get props => [todo];
}

class ChangeFilter extends TodoEvent {
  final TodoFilter filter;
  const ChangeFilter({required this.filter});
  @override
  List<Object?> get props => [filter];
}

class SearchTodos extends TodoEvent {
  final String query;
  const SearchTodos({required this.query});
  @override
  List<Object?> get props => [query];
}

class EditTodo extends TodoEvent {
  final TodoModel updatedTodo;
  const EditTodo({required this.updatedTodo});
  @override
  List<Object?> get props => [updatedTodo];
}

class LoadTodos extends TodoEvent {
  const LoadTodos();
  @override
  List<Object?> get props => [];
}

class ChangeSortOrder extends TodoEvent {
  final TodoSortOrder sortOrder;
  const ChangeSortOrder({required this.sortOrder});
  @override
  List<Object?> get props => [sortOrder];
}

enum TodoSortOrder { dateAdded, dueDate, priority, category }