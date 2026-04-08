import 'dart:async';
import 'package:todo_app/core/notifications/notification_service.dart';
import 'package:bloc/bloc.dart';
import 'package:todo_app/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:todo_app/features/todo/data/datasources/todo_firestore_datasource.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc/todo_event.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc/todo_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/todo_filter.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoLocalDataSource _localDataSource;

  TodoBloc(this._localDataSource) : super(const TodoInitial()) {
    on<LoadTodos>(_loadTodos);
    on<AddTodo>(_addTodo);
    on<DeleteTodo>(_deleteTodo);
    on<ToggleTodoStatus>(_toggleTodoStatus);
    on<RestoreTodo>(_restoreTodo);
    on<ChangeFilter>(_changeFilter);
    on<SearchTodos>(_searchTodos);
    on<EditTodo>(_editTodo);
    on<ChangeSortOrder>(_changeSortOrder);
    on<SyncFromFirestore>(_onSyncFromFirestore);

    add(const LoadTodos());
  }

  TodoSortOrder _currentSort = TodoSortOrder.dateAdded;

  Future<void> _addTodo(AddTodo event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    TodoFilter currentFilter = TodoFilter.all;
    String currentSearch = '';

    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
      currentFilter = (state as TodoLoaded).filter;
      currentSearch = (state as TodoLoaded).searchQuery;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
      currentFilter = (state as TodoDeleted).filter;
      currentSearch = (state as TodoDeleted).searchQuery;
    }

    final newTodo = TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: event.description,
      addedDate: DateTime.now(),
      isComplete: false,
      dueDate: event.dueDate,
      reminderTime: event.reminderTime,
      startReminder: event.startReminder,
      status: event.status,
      category: event.category,
      priority: event.priority,
    );

    final newTodos = [...oldTodos, newTodo];
    await _localDataSource.saveTodos(newTodos);
    await _scheduleReminder(newTodo);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await TodoFirestoreDataSource.instance.saveTodo(uid, newTodo);
    }

    emit(TodoLoaded(
      todos: newTodos,
      filter: currentFilter,
      searchQuery: currentSearch,
      sortOrder: _currentSort,
    ));
  }

  Future<void> _deleteTodo(
      DeleteTodo event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) oldTodos = (state as TodoDeleted).todos;

    final newTodos = oldTodos.where((todo) => todo.id != event.id).toList();

    await _localDataSource.saveTodos(newTodos);
    await NotificationService.instance.cancelNotification(event.id.hashCode);
    await NotificationService.instance
        .cancelNotification(("${event.id}_start").hashCode);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await TodoFirestoreDataSource.instance.deleteTodo(uid, event.id);
    }

    emit(TodoLoaded(
      todos: newTodos,
      sortOrder: _currentSort,
    ));
  }

  Future<void> _toggleTodoStatus(
      ToggleTodoStatus event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) oldTodos = (state as TodoDeleted).todos;

    final toggled = oldTodos.firstWhere((t) => t.id == event.id);
    final newIsComplete = !toggled.isComplete;
    final newStatus = newIsComplete ? TodoStatus.done : TodoStatus.toDo;

    final updatedTodo = toggled.copyWith(isComplete: newIsComplete, status: newStatus);

    final newTodos = oldTodos.map((todo) => todo.id == event.id
        ? updatedTodo
        : todo).toList();

    if (newIsComplete) {
      await NotificationService.instance.cancelNotification(event.id.hashCode);
      await NotificationService.instance
          .cancelNotification(("${event.id}_start").hashCode);
    } else {
      await _scheduleReminder(updatedTodo);
    }

    await _localDataSource.saveTodos(newTodos);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await TodoFirestoreDataSource.instance.saveTodo(uid, updatedTodo);
    }

    emit(TodoLoaded(todos: newTodos, sortOrder: _currentSort));
  }

  Future<void> _loadTodos(
      LoadTodos event, Emitter<TodoState> emit) async {
    final todos = await _localDataSource.loadTodos();
    emit(TodoLoaded(todos: todos, sortOrder: _currentSort));
  }

  Future<void> _restoreTodo(
      RestoreTodo event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) oldTodos = (state as TodoDeleted).todos;

    final newTodos = [...oldTodos, event.todo];
    await _localDataSource.saveTodos(newTodos);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await TodoFirestoreDataSource.instance.saveTodo(uid, event.todo);
    }

    emit(TodoLoaded(todos: newTodos, sortOrder: _currentSort));
  }

  Future<void> _changeFilter(
      ChangeFilter event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) oldTodos = (state as TodoDeleted).todos;

    emit(TodoLoaded(
      todos: oldTodos,
      filter: event.filter,
      sortOrder: _currentSort,
    ));
  }

  Future<void> _searchTodos(
      SearchTodos event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    TodoFilter currentFilter = TodoFilter.all;
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
      currentFilter = (state as TodoLoaded).filter;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
      currentFilter = (state as TodoDeleted).filter;
    }

    emit(TodoLoaded(
      todos: oldTodos,
      filter: currentFilter,
      searchQuery: event.query,
      sortOrder: _currentSort,
    ));
  }

  Future<void> _changeSortOrder(
      ChangeSortOrder event, Emitter<TodoState> emit) async {
    _currentSort = event.sortOrder;
    List<TodoModel> oldTodos = [];
    TodoFilter currentFilter = TodoFilter.all;
    String currentSearch = '';
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
      currentFilter = (state as TodoLoaded).filter;
      currentSearch = (state as TodoLoaded).searchQuery;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
      currentFilter = (state as TodoDeleted).filter;
      currentSearch = (state as TodoDeleted).searchQuery;
    }

    emit(TodoLoaded(
      todos: oldTodos,
      filter: currentFilter,
      searchQuery: currentSearch,
      sortOrder: _currentSort,
    ));
  }

  Future<void> _editTodo(
      EditTodo event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    TodoFilter currentFilter = TodoFilter.all;
    String currentSearch = '';

    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
      currentFilter = (state as TodoLoaded).filter;
      currentSearch = (state as TodoLoaded).searchQuery;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
      currentFilter = (state as TodoDeleted).filter;
      currentSearch = (state as TodoDeleted).searchQuery;
    }

    final oldTodo = oldTodos.firstWhere((t) => t.id == event.updatedTodo.id);
    await NotificationService.instance.cancelNotification(oldTodo.id.hashCode);
    await NotificationService.instance
        .cancelNotification(("${oldTodo.id}_start").hashCode);

    final newTodos = oldTodos.map((todo) {
      if (todo.id == event.updatedTodo.id) return event.updatedTodo;
      return todo;
    }).toList();

    if (!event.updatedTodo.isComplete) {
      await _scheduleReminder(event.updatedTodo);
    }

    await _localDataSource.saveTodos(newTodos);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await TodoFirestoreDataSource.instance.saveTodo(uid, event.updatedTodo);
    }

    emit(TodoLoaded(
      todos: newTodos,
      filter: currentFilter,
      searchQuery: currentSearch,
      sortOrder: _currentSort,
    ));
  }

  Future<void> _onSyncFromFirestore(
      SyncFromFirestore event, Emitter<TodoState> emit) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final remoteTodos = await TodoFirestoreDataSource.instance.fetchTodos(uid);
    if (remoteTodos.isNotEmpty) {
      await _localDataSource.saveTodos(remoteTodos);
      emit(TodoLoaded(
        todos: remoteTodos,
        sortOrder: _currentSort,
      ));
    }
  }

  Future<void> _scheduleReminder(TodoModel todo) async {
    if (todo.startReminder != null) {
      if (todo.startReminder!.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleNotification(
          id: ("${todo.id}_start").hashCode,
          title: "Start Task",
          body: "Start working on: ${todo.description}",
          scheduledTime: todo.startReminder!,
        );
      }
    } else if (todo.dueDate != null) {
      final startTime = _calculateSmartStartReminder(todo.dueDate);
      if (startTime != null && startTime.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleNotification(
          id: ("${todo.id}_start").hashCode,
          title: "Start Task",
          body: "Start working on: ${todo.description}",
          scheduledTime: startTime,
        );
      }
    }

    DateTime? scheduledTime;
    if (todo.reminderTime != null) {
      scheduledTime = todo.reminderTime;
    } else if (todo.dueDate != null) {
      final now = DateTime.now();
      final due = todo.dueDate!;
      final difference = due.difference(now).inDays;
      if (difference == 0) {
        scheduledTime = due.subtract(const Duration(minutes: 30));
      } else if (difference == 1) {
        scheduledTime = DateTime(now.year, now.month, now.day, 20, 0);
      } else if (difference > 1) {
        final reminderDay = due.subtract(const Duration(days: 1));
        scheduledTime = DateTime(
            reminderDay.year, reminderDay.month, reminderDay.day, 20, 0);
      }
    }

    if (scheduledTime == null) return;
    if (scheduledTime.isBefore(DateTime.now())) return;

    await NotificationService.instance.cancelNotification(todo.id.hashCode);
    await NotificationService.instance.scheduleNotification(
      id: todo.id.hashCode,
      title: "Todo Reminder",
      body: todo.description,
      scheduledTime: scheduledTime,
    );
  }

  DateTime? _calculateSmartStartReminder(DateTime? dueDate) {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    if (difference <= 0) return now;
    if (difference == 1) {
      return DateTime(now.year, now.month, now.day, 18, 0);
    }
    if (difference <= 3) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 0);
    }
    final startDay = dueDate.subtract(const Duration(days: 2));
    return DateTime(startDay.year, startDay.month, startDay.day, 18, 0);
  }
}
