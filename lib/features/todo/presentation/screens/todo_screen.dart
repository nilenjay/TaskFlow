import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/data/models/todo_filter.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_event.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {

  List<TodoModel> _extractTodos(TodoState state) {
    if (state is TodoLoaded) return state.todos;
    if (state is TodoDeleted) return state.todos;
    return [];
  }

  List<TodoModel> _applyFilters(
      List<TodoModel> todos,
      TodoFilter filter,
      String searchQuery,
      ) {
    List<TodoModel> filtered = List.from(todos);

    switch (filter) {
      case TodoFilter.active:
        filtered = filtered.where((t) => !t.isComplete).toList();
        break;

      case TodoFilter.completed:
        filtered = filtered.where((t) => t.isComplete).toList();
        break;

      case TodoFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
          t.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
      ),

      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoDeleted) {
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
          final todos = _extractTodos(state);

          TodoFilter filter = TodoFilter.all;
          String searchQuery = '';

          if (state is TodoLoaded) {
            filter = state.filter;
            searchQuery = state.searchQuery;
          } else if (state is TodoDeleted) {
            filter = state.filter;
            searchQuery = state.searchQuery;
          }

          final filteredTodos =
          _applyFilters(todos, filter, searchQuery);

          return Column(
            children: [
              const TodoSearchBar(),
              TodoFilterChips(currentFilter: filter),
              Expanded(
                child: TodoList(todos: filteredTodos),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final controller = TextEditingController();

    DateTime? selectedDueDate;
    DateTime? selectedReminderTime;
    DateTime? selectedStartReminder;

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
                        lastDate:
                        DateTime.now().add(const Duration(days: 3650)),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDueDate = picked;
                        });
                      }
                    },
                  ),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.alarm),
                    label: const Text('Pick Reminder Time (optional)'),
                    onPressed: () async {
                      final timeOfDay = await showTimePicker(
                        context: dialogContext,
                        initialTime: TimeOfDay.now(),
                      );

                      if (timeOfDay != null) {
                        final baseDate =
                            selectedDueDate ?? DateTime.now();

                        final reminder = DateTime(
                          baseDate.year,
                          baseDate.month,
                          baseDate.day,
                          timeOfDay.hour,
                          timeOfDay.minute,
                        );

                        setState(() {
                          selectedReminderTime = reminder;
                        });
                      }
                    },
                  ),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Pick Start Reminder (optional)'),
                    onPressed: () async {

                      final timeOfDay = await showTimePicker(
                        context: dialogContext,
                        initialTime: TimeOfDay.now(),
                      );

                      if (timeOfDay != null) {

                        final baseDate = selectedDueDate ?? DateTime.now();

                        final startReminder = DateTime(
                          baseDate.year,
                          baseDate.month,
                          baseDate.day,
                          timeOfDay.hour,
                          timeOfDay.minute,
                        );

                        setState(() {
                          selectedStartReminder = startReminder;
                        });
                      }
                    },
                  ),

                  if (selectedReminderTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Reminder: ${selectedReminderTime!.toLocal()}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  if (selectedStartReminder != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Start: ${selectedStartReminder!.toLocal()}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],

                  if (selectedDueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Due: ${selectedDueDate!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    final text = controller.text.trim();

                    if (text.isEmpty) return;

                    Navigator.pop(dialogContext);

                    context.read<TodoBloc>().add(
                      AddTodo(
                        description: text,
                        dueDate: selectedDueDate,
                        reminderTime: selectedReminderTime,
                      ),
                    );
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
  }
}

class TodoSearchBar extends StatelessWidget {
  const TodoSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class TodoFilterChips extends StatelessWidget {
  final TodoFilter currentFilter;

  const TodoFilterChips({super.key, required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class TodoList extends StatelessWidget {
  final List<TodoModel> todos;

  const TodoList({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No todos yet…'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoTile(todo: todos[index]);
      },
    );
  }
}

class TodoTile extends StatelessWidget {
  final TodoModel todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isComplete;

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TodoBloc>().add(DeleteTodo(id: todo.id));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [

                Checkbox(
                  value: todo.isComplete,
                  onChanged: (_) {
                    context.read<TodoBloc>().add(
                      ToggleTodoStatus(id: todo.id),
                    );
                  },
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        todo.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: todo.isComplete
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: todo.isComplete
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [

                          if (todo.dueDate != null)
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(todo.dueDate!),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(width: 12),

                          if (todo.reminderTime != null)
                            Row(
                              children: [
                                const Icon(Icons.notifications,
                                    size: 14,
                                    color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(todo.reminderTime!),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<TodoBloc>().add(
                      DeleteTodo(id: todo.id),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

void showEditTodoDialog(BuildContext context, TodoModel todo) {

  final controller = TextEditingController(text: todo.description);

  DateTime? selectedDueDate = todo.dueDate;
  DateTime? selectedReminderTime = todo.reminderTime;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {

          return AlertDialog(
            title: const Text("Edit Todo"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Edit description",
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Change Due Date"),
                  onPressed: () async {

                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 3650)),
                      lastDate:
                      DateTime.now().add(const Duration(days: 3650)),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedDueDate = picked;
                      });
                    }
                  },
                ),

                OutlinedButton.icon(
                  icon: const Icon(Icons.alarm),
                  label: const Text("Change Reminder"),
                  onPressed: () async {

                    final timeOfDay = await showTimePicker(
                      context: dialogContext,
                      initialTime: TimeOfDay.now(),
                    );

                    if (timeOfDay != null) {

                      final baseDate =
                          selectedDueDate ?? DateTime.now();

                      final reminder = DateTime(
                        baseDate.year,
                        baseDate.month,
                        baseDate.day,
                        timeOfDay.hour,
                        timeOfDay.minute,
                      );

                      setState(() {
                        selectedReminderTime = reminder;
                      });
                    }
                  },
                ),

                if (selectedReminderTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Reminder: ${selectedReminderTime!.toLocal()}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),

                if (selectedDueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Due: ${selectedDueDate!.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),

            actions: [

              TextButton(
                onPressed: () {

                  final text = controller.text.trim();

                  if (text.isEmpty) return;

                  final updatedTodo = todo.copyWith(
                    description: text,
                    dueDate: selectedDueDate,
                    reminderTime: selectedReminderTime,
                  );

                  Navigator.pop(dialogContext);

                  context.read<TodoBloc>().add(
                    EditTodo(updatedTodo: updatedTodo),
                  );
                },
                child: const Text("Save"),
              ),

              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    },
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();

  if (date.day == now.day &&
      date.month == now.month &&
      date.year == now.year) {
    return "Today";
  }

  final tomorrow = now.add(const Duration(days: 1));

  if (date.day == tomorrow.day &&
      date.month == tomorrow.month &&
      date.year == tomorrow.year) {
    return "Tomorrow";
  }

  return "${date.day}/${date.month}/${date.year}";
}

String _formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final period = time.hour >= 12 ? "PM" : "AM";

  return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
}