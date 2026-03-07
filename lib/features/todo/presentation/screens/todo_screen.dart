import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/todo_filter.dart';
import '../../data/models/todo_model.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  bool _showCompleted = false;

  Widget _buildCompletedSection(List<TodoModel> todos) {

    if (todos.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        InkWell(
          onTap: () {
            setState(() {
              _showCompleted = !_showCompleted;
            });
          },

          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              children: [

                const Text(
                  "✔ COMPLETED",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  "(${todos.length})",
                  style: const TextStyle(color: Colors.grey),
                ),

                const Spacer(),

                Icon(
                  _showCompleted
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        if (_showCompleted)
          ...todos.map((todo) => _buildTodoTile(todo)),
      ],
    );
  }

  Widget buildProgressIndicator(List<TodoModel> todos) {
    final total = todos.length;
    final completed = todos.where((t) => t.isComplete).length;

    double progress = 0;
    if (total > 0) {
      progress = completed / total;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$completed / $total tasks completed",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
      ),

      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {

          if (state is TodoDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Todo deleted"),
                action: SnackBarAction(
                  label: "UNDO",
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
          TodoFilter filter = TodoFilter.all;
          String searchQuery = "";

          if (state is TodoLoaded) {
            todos = state.todos;
            filter = state.filter;
            searchQuery = state.searchQuery;
          }

          if (state is TodoDeleted) {
            todos = state.todos;
            filter = state.filter;
            searchQuery = state.searchQuery;
          }

          /// FILTER

          List<TodoModel> filtered = List.from(todos);

          switch (filter) {
            case TodoFilter.active:
              filtered = todos.where((t) => !t.isComplete).toList();
              break;

            case TodoFilter.completed:
              filtered = todos.where((t) => t.isComplete).toList();
              break;

            case TodoFilter.all:
              filtered = todos;
              break;
          }

          /// SEARCH

          if (searchQuery.isNotEmpty) {
            filtered = filtered.where((t) =>
                t.description
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();
          }

          /// SECTIONING

          final now = DateTime.now();

          List<TodoModel> completed = [];
          List<TodoModel> overdue = [];
          List<TodoModel> today = [];
          List<TodoModel> tomorrow = [];
          List<TodoModel> upcoming = [];

          for (final todo in filtered) {

            if (todo.isComplete) {
              completed.add(todo);
              continue;
            }

            if (todo.dueDate == null) {
              upcoming.add(todo);
              continue;
            }

            final due = todo.dueDate!;

            if (due.isBefore(now)) {
              overdue.add(todo);
            }

            else if (due.year == now.year &&
                due.month == now.month &&
                due.day == now.day) {
              today.add(todo);
            }

            else if (due.year ==
                now.add(const Duration(days: 1)).year &&
                due.month ==
                    now.add(const Duration(days: 1)).month &&
                due.day ==
                    now.add(const Duration(days: 1)).day) {
              tomorrow.add(todo);
            }

            else {
              upcoming.add(todo);
            }
          }

          return Column(
            children:[
              buildProgressIndicator(todos),

              /// SEARCH

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: TextField(
                  onChanged: (value) {
                    context.read<TodoBloc>().add(
                      SearchTodos(query: value),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: "Search todos...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              /// FILTER CHIPS

              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    ChoiceChip(
                      label: const Text("All"),
                      selected: filter == TodoFilter.all,
                      onSelected: (_) {
                        context.read<TodoBloc>().add(
                          ChangeFilter(filter: TodoFilter.all),
                        );
                      },
                    ),

                    ChoiceChip(
                      label: const Text("Active"),
                      selected: filter == TodoFilter.active,
                      onSelected: (_) {
                        context.read<TodoBloc>().add(
                          ChangeFilter(filter: TodoFilter.active),
                        );
                      },
                    ),

                    ChoiceChip(
                      label: const Text("Completed"),
                      selected: filter == TodoFilter.completed,
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
                child: ListView(
                  children: [

                    _buildSection("⚠ OVERDUE", overdue),
                    _buildSection("📅 TODAY", today),
                    _buildSection("🟡 TOMORROW", tomorrow),
                    _buildSection("📦 UPCOMING", upcoming),
                    _buildCompletedSection(completed),

                    const SizedBox(height: 80),
                  ],
                ),
              )
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
        onPressed: _showAddDialog,
      ),
    );
  }

  /// SECTION

  Widget _buildSection(String title, List<TodoModel> todos) {

    if (todos.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),

        ...todos.map((todo) => _buildTodoTile(todo)),
      ],
    );
  }

  /// TODO TILE

  Widget _buildTodoTile(TodoModel todo) {

    return Dismissible(
      key: ValueKey(todo.id),

      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),

      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      confirmDismiss: (direction) async {

        if (direction == DismissDirection.endToStart) {

          context.read<TodoBloc>().add(
            DeleteTodo(id: todo.id),
          );

          return true;
        }

        else {

          _showEditDialog(todo);

          return false;
        }
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(16),

          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),

            child: Row(
              children: [

                /// PRIORITY STRIP
                Container(
                  width: 6,
                  height: 72,
                  decoration: BoxDecoration(
                    color: getPriorityColor(todo.priority),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// DESCRIPTION
                        Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: todo.isComplete
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// META INFO
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [

                            if (todo.dueDate != null)
                              _infoIcon(
                                  Icons.calendar_today,
                                  _formatDate(todo.dueDate!)
                              ),

                            if (todo.startReminder != null)
                              _infoIcon(
                                  Icons.play_arrow,
                                  _formatTime(todo.startReminder!)
                              ),

                            if (todo.reminderTime != null)
                              _infoIcon(
                                  Icons.notifications,
                                  _formatTime(todo.reminderTime!)
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /// CHECKBOX
                Padding(
                  padding: const EdgeInsets.only(right: 12),

                  child: Checkbox(
                    value: todo.isComplete,
                    onChanged: (_) {
                      context.read<TodoBloc>().add(
                        ToggleTodoStatus(id: todo.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoIcon(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.grey)),
      ],
    );
  }

  /// ADD DIALOG

  void _showAddDialog() {
    _showEditDialog(null);
  }

  /// EDIT / ADD DIALOG

  void _showEditDialog(TodoModel? todo) {

    final controller =
    TextEditingController(text: todo?.description ?? "");

    DateTime? dueDate = todo?.dueDate;
    DateTime? reminder = todo?.reminderTime;
    DateTime? startReminder = todo?.startReminder;
    int selectedPriority = todo?.priority ?? 2;

    showDialog(
      context: context,
      builder: (dialogContext) {

        return StatefulBuilder(
          builder: (context, setState) {

            return AlertDialog(
              title: Text(todo == null ? "Add Todo" : "Edit Todo"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  DropdownButtonFormField<int>(
                    value: selectedPriority,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("High Priority")),
                      DropdownMenuItem(value: 2, child: Text("Medium Priority")),
                      DropdownMenuItem(value: 3, child: Text("Low Priority")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPriority = value;
                        });
                      }
                    },
                  ),

                  TextField(
                    controller: controller,
                    decoration:
                    const InputDecoration(hintText: "Description"),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    child: const Text("Pick Due Date"),
                    onPressed: () async {

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() => dueDate = picked);
                      }
                    },
                  ),

                  ElevatedButton(
                    child: const Text("Pick Reminder"),
                    onPressed: () async {

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null) {

                        final base = dueDate ?? DateTime.now();

                        setState(() {
                          reminder = DateTime(
                              base.year,
                              base.month,
                              base.day,
                              time.hour,
                              time.minute);
                        });
                      }
                    },
                  ),

                  ElevatedButton(
                    child: const Text("Pick Start Reminder"),
                    onPressed: () async {

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null) {

                        final base = dueDate ?? DateTime.now();

                        setState(() {
                          startReminder = DateTime(
                              base.year,
                              base.month,
                              base.day,
                              time.hour,
                              time.minute);
                        });
                      }
                    },
                  ),
                ],
              ),

              actions: [

                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),

                TextButton(
                  child: const Text("Save"),
                  onPressed: () {

                    final text = controller.text.trim();
                    if (text.isEmpty) return;

                    if (todo == null) {

                      context.read<TodoBloc>().add(
                        AddTodo(
                          description: text,
                          dueDate: dueDate,
                          reminderTime: reminder,
                          startReminder: startReminder,
                          priority: selectedPriority,
                        ),
                      );
                    }

                    else {

                      context.read<TodoBloc>().add(
                        EditTodo(
                          updatedTodo: todo.copyWith(
                            description: text,
                            dueDate: dueDate,
                            reminderTime: reminder,
                            startReminder: startReminder,
                            priority: selectedPriority,
                          ),
                        ),
                      );
                    }

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year}";

  String _formatTime(DateTime time) {

    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? "PM" : "AM";

    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }
}

Color getPriorityColor(int priority) {
  switch (priority) {
    case 1:
      return Colors.red;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.green;
    default:
      return Colors.grey;
  }
}