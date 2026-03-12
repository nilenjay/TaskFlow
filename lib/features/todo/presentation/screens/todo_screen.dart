import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/todo_filter.dart';
import '../../data/models/todo_model.dart';
import '../bloc/todo_bloc/todo_bloc.dart';
import '../bloc/todo_bloc/todo_event.dart';
import '../bloc/todo_bloc/todo_state.dart';
import 'app_theme.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  bool _showCompleted = false;

  // ─── Progress indicator ──────────────────────────────────────────────────

  Widget _buildProgressIndicator(List<TodoModel> todos) {
    final total = todos.length;
    final completed = todos.where((t) => t.isComplete).length;
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard(radius: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Tasks',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$completed / $total completed',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor:
                const AlwaysStoppedAnimation(AppTheme.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Completed section ───────────────────────────────────────────────────

  Widget _buildCompletedSection(List<TodoModel> todos) {
    if (todos.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showCompleted = !_showCompleted),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              children: [
                const Text(
                  '✔ COMPLETED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${todos.length})',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12),
                ),
                const Spacer(),
                Icon(
                  _showCompleted
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_showCompleted) ...todos.map((t) => _buildTodoTile(t)),
      ],
    );
  }

  // ─── Section ─────────────────────────────────────────────────────────────

  Widget _buildSection(String title, List<TodoModel> todos) {
    if (todos.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentGlow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${todos.length}',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...todos.map((t) => _buildTodoTile(t)),
      ],
    );
  }

  // ─── Todo tile ───────────────────────────────────────────────────────────

  Widget _buildTodoTile(TodoModel todo) {
    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit, color: Colors.white70),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white70),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          context.read<TodoBloc>().add(DeleteTodo(id: todo.id));
          return true;
        } else {
          _showEditDialog(todo);
          return false;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Container(
          decoration: AppTheme.glassCard(radius: 16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority strip
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: getPriorityGradient(todo.priority),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: todo.isComplete
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                            decoration: todo.isComplete
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: AppTheme.textMuted,
                          ),
                          child: Text(todo.description),
                        ),
                        if (todo.dueDate != null ||
                            todo.startReminder != null ||
                            todo.reminderTime != null) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            children: [
                              if (todo.dueDate != null)
                                _infoChip(Icons.calendar_today,
                                    _formatDate(todo.dueDate!)),
                              if (todo.startReminder != null)
                                _infoChip(Icons.play_arrow,
                                    _formatTime(todo.startReminder!)),
                              if (todo.reminderTime != null)
                                _infoChip(Icons.notifications,
                                    _formatTime(todo.reminderTime!)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Checkbox
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: todo.isComplete,
                      onChanged: (_) => context
                          .read<TodoBloc>()
                          .add(ToggleTodoStatus(id: todo.id)),
                      activeColor: AppTheme.accent,
                      checkColor: Colors.white,
                      side: const BorderSide(
                          color: AppTheme.glassBorder, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: BlocConsumer<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state is TodoDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1E2240),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  content: const Text('Task deleted',
                      style: TextStyle(color: Colors.white)),
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: AppTheme.accent,
                    onPressed: () => context
                        .read<TodoBloc>()
                        .add(RestoreTodo(todo: state.deletedTodo)),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            List<TodoModel> todos = [];
            TodoFilter filter = TodoFilter.all;
            String searchQuery = '';

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

            // Filter
            List<TodoModel> filtered = List.from(todos);
            switch (filter) {
              case TodoFilter.active:
                filtered = todos.where((t) => !t.isComplete).toList();
                break;
              case TodoFilter.completed:
                filtered = todos.where((t) => t.isComplete).toList();
                break;
              case TodoFilter.overdue:
                filtered = todos
                    .where((t) =>
                !t.isComplete &&
                    t.dueDate != null &&
                    t.dueDate!.isBefore(DateTime.now()))
                    .toList();
                break;
              case TodoFilter.all:
                filtered = todos;
                break;
            }
            if (searchQuery.isNotEmpty) {
              filtered = filtered
                  .where((t) => t.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
                  .toList();
            }

            // Sectioning
            final now = DateTime.now();
            final tomorrow = now.add(const Duration(days: 1));
            List<TodoModel> completed = [],
                overdue = [],
                today = [],
                tmrw = [],
                upcoming = [];

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
              } else if (due.year == now.year &&
                  due.month == now.month &&
                  due.day == now.day) {
                today.add(todo);
              } else if (due.year == tomorrow.year &&
                  due.month == tomorrow.month &&
                  due.day == tomorrow.day) {
                tmrw.add(todo);
              } else {
                upcoming.add(todo);
              }
            }

            return Column(
              children: [
                // Status bar inset only — AppBar draws itself via extendBodyBehindAppBar
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight - 8),

                _buildProgressIndicator(todos),

                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    onChanged: (v) => context
                        .read<TodoBloc>()
                        .add(SearchTodos(query: v)),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.textMuted, size: 20),
                      filled: true,
                      fillColor: AppTheme.glassFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.accent, width: 1.5),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', TodoFilter.all, filter),
                        const SizedBox(width: 8),
                        _filterChip('Active', TodoFilter.active, filter),
                        const SizedBox(width: 8),
                        _filterChip('Completed', TodoFilter.completed, filter),
                        const SizedBox(width: 8),
                        _filterChip('Overdue', TodoFilter.overdue, filter,
                            accentColor: AppTheme.priorityHigh),
                      ],
                    ),
                  ),
                ),

                // List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(
                      bottom: kBottomNavigationBarHeight +
                          MediaQuery.of(context).padding.bottom +
                          80,
                    ),
                    children: [
                      _buildSection('⚠ OVERDUE', overdue),
                      _buildSection('📅 TODAY', today),
                      _buildSection('🟡 TOMORROW', tmrw),
                      _buildSection('📦 UPCOMING', upcoming),
                      _buildCompletedSection(completed),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentDim.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          backgroundColor: AppTheme.accentDim,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Task',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _filterChip(
      String label, TodoFilter value, TodoFilter current,
      {Color? accentColor}) {
    final selected = current == value;
    final color = accentColor ?? AppTheme.accent;
    return GestureDetector(
      onTap: () =>
          context.read<TodoBloc>().add(ChangeFilter(filter: value)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppTheme.glassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppTheme.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight:
            selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────

  void _showAddDialog() => _showEditDialog(null);

  void _showEditDialog(TodoModel? todo) {
    final controller =
    TextEditingController(text: todo?.description ?? '');
    DateTime? dueDate = todo?.dueDate;
    DateTime? reminder = todo?.reminderTime;
    DateTime? startReminder = todo?.startReminder;
    int selectedPriority = todo?.priority ?? 2;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo == null ? 'New Task' : 'Edit Task',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Priority
                DropdownButtonFormField<int>(
                  value: selectedPriority,
                  dropdownColor: const Color(0xFF1A1F3A),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _dialogInputDecoration('Priority'),
                  items: const [
                    DropdownMenuItem(
                        value: 1,
                        child: Text('🔴  High Priority')),
                    DropdownMenuItem(
                        value: 2,
                        child: Text('🟡  Medium Priority')),
                    DropdownMenuItem(
                        value: 3,
                        child: Text('🟢  Low Priority')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => selectedPriority = v);
                  },
                ),
                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: controller,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _dialogInputDecoration('Description'),
                ),
                const SizedBox(height: 16),

                // Date/time buttons
                Row(
                  children: [
                    Expanded(
                      child: _dialogButton(
                        icon: Icons.calendar_today,
                        label: dueDate != null
                            ? _formatDate(dueDate!)
                            : 'Due Date',
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null)
                            setState(() => dueDate = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _dialogButton(
                        icon: Icons.notifications,
                        label: reminder != null
                            ? _formatTime(reminder!)
                            : 'Reminder',
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            final base = dueDate ?? DateTime.now();
                            setState(() => reminder = DateTime(
                                base.year,
                                base.month,
                                base.day,
                                time.hour,
                                time.minute));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _dialogButton(
                  icon: Icons.play_arrow,
                  label: startReminder != null
                      ? 'Start: ${_formatTime(startReminder!)}'
                      : 'Start Reminder',
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      final base = dueDate ?? DateTime.now();
                      setState(() => startReminder = DateTime(
                          base.year,
                          base.month,
                          base.day,
                          time.hour,
                          time.minute));
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textMuted,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;
                          if (todo == null) {
                            context.read<TodoBloc>().add(AddTodo(
                                description: text,
                                dueDate: dueDate,
                                reminderTime: reminder,
                                startReminder: startReminder,
                                priority: selectedPriority));
                          } else {
                            context.read<TodoBloc>().add(EditTodo(
                                updatedTodo: todo.copyWith(
                                    description: text,
                                    dueDate: dueDate,
                                    reminderTime: reminder,
                                    startReminder: startReminder,
                                    priority: selectedPriority)));
                          }
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accentDim,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save',
                            style:
                            TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: AppTheme.textMuted, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppTheme.accent, width: 1.5),
      ),
    );
  }

  Widget _dialogButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppTheme.accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Formatters ───────────────────────────────────────────────────────────

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final p = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:${t.minute.toString().padLeft(2, '0')} $p';
  }
}

// ─── Priority helpers (kept public for calendar_screen reuse) ────────────────

Color getPriorityColor(int priority) {
  switch (priority) {
    case 1:
      return AppTheme.priorityHigh;
    case 2:
      return AppTheme.priorityMedium;
    case 3:
      return AppTheme.priorityLow;
    default:
      return Colors.grey;
  }
}

LinearGradient getPriorityGradient(int priority) {
  switch (priority) {
    case 1:
      return const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF3B3B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    case 2:
      return const LinearGradient(
        colors: [Color(0xFFFFE082), Color(0xFFFFC107)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    case 3:
      return const LinearGradient(
        colors: [Color(0xFF81C784), Color(0xFF43A047)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    default:
      return const LinearGradient(colors: [Colors.grey, Colors.grey]);
  }
}