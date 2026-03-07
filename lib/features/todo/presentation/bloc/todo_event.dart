import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

import '../../data/models/todo_filter.dart';

abstract class TodoEvent extends Equatable{
  const TodoEvent();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AddTodo extends TodoEvent{
  final String description;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final DateTime? startReminder;
  final int priority;
  const AddTodo({
    required this.description,
    this.dueDate,
    this.reminderTime,
    this.startReminder,
    this.priority=2,
});
  @override
  // TODO: implement props
  List<Object?> get props => [description,dueDate,reminderTime,startReminder,priority];
}

class DeleteTodo extends TodoEvent{
  final String id;
  const DeleteTodo({
    required this.id,
});
  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class ToggleTodoStatus extends TodoEvent{
  final String id;
  const ToggleTodoStatus({
    required this.id,
});
  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class RestoreTodo extends TodoEvent{
  final TodoModel todo;

  const RestoreTodo({required this.todo});
  @override
  // TODO: implement props
  List<Object?> get props => [todo];
}

class ChangeFilter extends TodoEvent {
  final TodoFilter filter;

  const ChangeFilter({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class SearchTodos extends TodoEvent{
  final String query;
  const SearchTodos({
    required this.query,
});
  @override
  // TODO: implement props
  List<Object?> get props => [query];
}

class EditTodo extends TodoEvent {
  final TodoModel updatedTodo;
  const EditTodo({
    required this.updatedTodo
});
  @override
  // TODO: implement props
  List<Object?> get props => [updatedTodo];
}

class LoadTodos extends TodoEvent {
  const LoadTodos();

  @override
  List<Object?> get props => [];
}