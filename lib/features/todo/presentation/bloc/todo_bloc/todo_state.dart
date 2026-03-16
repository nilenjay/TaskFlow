import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todo/data/models/todo_filter.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc/todo_event.dart';

abstract class TodoState extends Equatable {
  const TodoState();
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  final TodoFilter filter;
  final String searchQuery;
  final TodoSortOrder sortOrder;

  const TodoLoaded({
    required this.todos,
    this.filter = TodoFilter.all,
    this.searchQuery = '',
    this.sortOrder = TodoSortOrder.dateAdded,
  });

  @override
  List<Object?> get props => [todos, filter, searchQuery, sortOrder];
}

class TodoDeleted extends TodoState {
  final TodoModel deletedTodo;
  final List<TodoModel> todos;
  final String searchQuery;
  final TodoFilter filter;
  final TodoSortOrder sortOrder;

  const TodoDeleted({
    required this.deletedTodo,
    required this.todos,
    this.filter = TodoFilter.all,
    this.searchQuery = '',
    this.sortOrder = TodoSortOrder.dateAdded,
  });

  @override
  List<Object?> get props =>
      [deletedTodo, todos, filter, searchQuery, sortOrder];
}