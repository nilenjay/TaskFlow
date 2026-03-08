import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todo/data/models/todo_filter.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

abstract class TodoState extends Equatable{
  const TodoState();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class TodoInitial extends TodoState{
  const TodoInitial();
}

class TodoLoaded extends TodoState{
  final List<TodoModel> todos;
  final TodoFilter filter;
  final String searchQuery;

  const TodoLoaded({
    required this.todos,
    this.filter=TodoFilter.all,
    this.searchQuery='',
});
  @override
  // TODO: implement props
  List<Object?> get props => [todos,filter,searchQuery];
}

class TodoDeleted extends TodoState{
  final TodoModel deletedTodo;
  final List<TodoModel> todos;
  final String searchQuery;
  final TodoFilter filter;

  const TodoDeleted({
    required this.deletedTodo,
    required this.todos,
    this.filter=TodoFilter.all,
    this.searchQuery='',
  });
  @override
  // TODO: implement props
  List<Object?> get props => [deletedTodo,todos,filter,searchQuery];
}