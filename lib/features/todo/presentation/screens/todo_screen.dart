import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/data/models/todo_filter.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_event.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';

import '../../data/datasources/todo_local_datasource.dart';
import '../../data/models/todo_model.dart';


class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: const Text('My Todo List'),
            ),

            body: BlocConsumer<TodoBloc, TodoState>(
              listener: (context, state) {
                if (state is TodoDeleted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Todo deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          context.read<TodoBloc>().add(
                            RestoreTodo(todo: state.deletedTodo),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {

                List<TodoModel> todos = [];
                TodoFilter currentFilter = TodoFilter.all;
                List<TodoModel> filteredTodos = todos;

                if (state is TodoLoaded) {
                  todos = state.todos;
                  currentFilter = state.filter;

                } else if (state is TodoDeleted) {
                  todos = state.todos;
                  currentFilter = state.filter;
                }

                switch (currentFilter) {
                  case TodoFilter.active:
                    filteredTodos =
                        todos.where((t) => !t.isComplete).toList();
                    break;

                  case TodoFilter.completed:
                    filteredTodos =
                        todos.where((t) => t.isComplete).toList();
                    break;

                  case TodoFilter.all:
                    filteredTodos = todos;
                    break;
                }
                String searchQuery = '';

                if (state is TodoLoaded) {
                  searchQuery = state.searchQuery;
                } else if (state is TodoDeleted) {
                  searchQuery = state.searchQuery;
                }

                if (searchQuery.isNotEmpty) {
                  filteredTodos = filteredTodos
                      .where((t) => t.description
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                      .toList();
                }

                return Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: TextField(
                        onChanged: (value) {
                          context.read<TodoBloc>().add(
                            SearchTodos(query: value),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search todos...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: currentFilter == TodoFilter.all,
                            onSelected: (_) {
                              context.read<TodoBloc>().add(
                                ChangeFilter(filter: TodoFilter.all),
                              );
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Active'),
                            selected: currentFilter == TodoFilter.active,
                            onSelected: (_) {
                              context.read<TodoBloc>().add(
                                ChangeFilter(filter: TodoFilter.active),
                              );
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Completed'),
                            selected: currentFilter == TodoFilter.completed,
                            onSelected: (_) {
                              context.read<TodoBloc>().add(
                                ChangeFilter(filter: TodoFilter.completed),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: filteredTodos.isNotEmpty
                          ? ListView.builder(
                        itemCount: filteredTodos.length,
                        itemBuilder: (context, index) {
                          final todo = filteredTodos[index];
                          final isOverdue = todo.dueDate != null &&
                              todo.dueDate!.isBefore(DateTime.now()) &&
                              !todo.isComplete;

                          return Dismissible(
                            key: ValueKey(todo.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              context.read<TodoBloc>().add(
                                DeleteTodo(id: todo.id),
                              );
                            },


                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),

                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                  leading: Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    value: todo.isComplete,
                                    onChanged: (_) {
                                      context.read<TodoBloc>().add(
                                        ToggleTodoStatus(id: todo.id),
                                      );
                                    },
                                  ),
                                  title: Text(
                                    todo.description,

                                    style: TextStyle(
                                      color: todo.isComplete
                                          ? Colors.grey
                                          : Colors.black,
                                      decoration: todo.isComplete
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: todo.dueDate != null
                                      ? Text(
                                    'Due: ${todo.dueDate!.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(
                                      color: isOverdue ? Colors.red : Colors.grey,
                                    ),
                                  )
                                      : null,
                                  trailing: IconButton(
                                    onPressed: () {
                                      context.read<TodoBloc>().add(
                                        DeleteTodo(id: todo.id),
                                      );
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                          : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No todos yet…'),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  final controller = TextEditingController();
                  DateTime? selectedDueDate;

                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Add Todo'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter description',
                                  ),
                                ),
                                const SizedBox(height: 12),

                                OutlinedButton.icon(
                                  icon: const Icon(Icons.calendar_today),
                                  label: const Text('Pick Due Date (optional)'),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: dialogContext,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now()
                                          .subtract(const Duration(days: 3650)),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 3650)),
                                    );

                                    if (picked != null) {
                                      setState(() {
                                        selectedDueDate = picked;
                                      });
                                    }
                                  },
                                ),

                                if (selectedDueDate != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Due: ${selectedDueDate!.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  final text = controller.text.trim();

                                  if (text.isNotEmpty) {
                                    dialogContext.read<TodoBloc>().add(
                                      AddTodo(
                                        description: text,
                                        dueDate: selectedDueDate,
                                      ),
                                    );
                                  }

                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Add'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: const Icon(Icons.add),
              ),

          );
        }


  }

