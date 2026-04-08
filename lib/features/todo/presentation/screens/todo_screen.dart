import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/todo_filter.dart';
import '../../data/models/todo_model.dart';
import '../bloc/todo_bloc/todo_bloc.dart';
import '../bloc/todo_bloc/todo_event.dart';
import '../../../settings/cubit/theme_cubit.dart';
import '../bloc/todo_bloc/todo_state.dart';
import 'app_theme.dart';
import 'status_config.dart';
import 'streak_service.dart';
import 'statistics_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  bool _showCompleted = false;


  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 👋';
    if (h < 21) return 'Good evening 🌆';
    return 'Good night 🌙';
  }


  static const _catConfig = {
    TodoCategory.work:         (label: 'Work',         emoji: '💼', color: Color(0xFF60A5FA)),
    TodoCategory.personal:     (label: 'Personal',     emoji: '👤', color: Color(0xFF34D399)),
    TodoCategory.professional: (label: 'Professional', emoji: '🧳', color: Color(0xFF818CF8)),
    TodoCategory.family:       (label: 'Family',       emoji: '👨‍👩‍👧', color: Color(0xFFFBBF24)),
    TodoCategory.fitness:      (label: 'Fitness',      emoji: '💪', color: Color(0xFFF87171)),
    TodoCategory.other:        (label: 'Other',        emoji: '📌', color: Color(0xFF94A3B8)),
  };


  Widget _buildStatsRow(List<TodoModel> todos, bool isDark) {
    final now = DateTime.now();
    final total = todos.length;
    final done = todos.where((t) => t.isComplete).length;
    final overdue = todos.where((t) =>
    !t.isComplete &&
        t.dueDate != null &&
        t.dueDate!.isBefore(now)).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _statChip('$total', 'Total',
              const Color(0xFF818CF8), const Color(0x22818CF8)),
          const SizedBox(width: 10),
          _statChip('$done', 'Done',
              const Color(0xFF34D399), const Color(0x2234D399)),
          const SizedBox(width: 10),
          _statChip('$overdue', 'Overdue',
              const Color(0xFFF87171), const Color(0x22F87171)),
        ],
      ),
    );
  }

  Widget _statChip(String val, String label, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7, height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text('$val ', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }


  Widget _buildStreakBanner(List<TodoModel> todos, bool isDark) {
    final streak = StreakService.instance.calculate(todos);
    if (streak.currentStreak == 0 && streak.totalDone == 0) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFFF97316).withOpacity(0.15),
            const Color(0xFFEF4444).withOpacity(0.08),
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF97316).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak.currentStreak > 0
                        ? '${streak.currentStreak} day streak!'
                        : 'No active streak',
                    style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  Text(
                    StreakService.instance.streakMessage(streak.currentStreak),
                    style: TextStyle(
                        color: const Color(0xFFF97316).withOpacity(0.7),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Best: ${streak.bestStreak}',
                    style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                Text('${streak.totalDone} done',
                    style: TextStyle(
                        color: const Color(0xFFF97316).withOpacity(0.7),
                        fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProgressBar(List<TodoModel> todos, bool isDark) {
    final total = todos.length;
    final completed = todos.where((t) => t.isComplete).length;
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.glassCard(isDark: isDark, radius: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Tasks',
                    style: TextStyle(
                        color: AppTheme.getPrimaryText(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text('$completed / $total completed',
                    style: TextStyle(
                        color: AppTheme.getMutedText(isDark), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSection(String title, List<TodoModel> todos, bool isDark) {
    if (todos.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getMutedText(isDark),
                      fontSize: 12,
                      letterSpacing: 0.8)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentGlow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${todos.length}',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ...todos.map((t) => _buildTodoTile(t, isDark)),
      ],
    );
  }

  Widget _buildCompletedSection(List<TodoModel> todos, bool isDark) {
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
                const Text('✔ COMPLETED',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        letterSpacing: 0.8)),
                const SizedBox(width: 6),
                Text('(${todos.length})',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                const Spacer(),
                Icon(
                  _showCompleted ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.textMuted, size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_showCompleted) ...todos.map((t) => _buildTodoTile(t, isDark)),
      ],
    );
  }


  Widget _buildTodoTile(TodoModel todo, bool isDark) {
    final cfg = statusConfig(todo.status);
    final catCfg = _catConfig[todo.category]!;
    final isDone = todo.isComplete;

    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white70),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white70),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDone
                  ? [
                isDark ? const Color(0xFF0D1117) : Colors.white.withOpacity(0.4),
                isDark ? const Color(0xFF070B14) : Colors.white.withOpacity(0.4)
              ]
                  : [
                cfg.colorA.withOpacity(isDark ? 0.18 : 0.1),
                isDark ? const Color(0xFF0D1520) : Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDone
                  ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
                  : cfg.colorA.withOpacity(isDark ? 0.35 : 0.2),
              width: 1,
            ),
            boxShadow: isDone
                ? []
                : [
              BoxShadow(
                color: cfg.colorA.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showEditDialog(todo),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            todo.description,
                            style: TextStyle(
                              color: isDone
                                  ? AppTheme.getMutedText(isDark)
                                  : AppTheme.getPrimaryText(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => context
                              .read<TodoBloc>()
                              .add(ToggleTodoStatus(id: todo.id)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? const Color(0xFF34D399)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isDone
                                    ? const Color(0xFF34D399)
                                    : Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: isDone
                                ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14)
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _statusBadge(cfg),
                        _categoryTag(catCfg.emoji, catCfg.label, catCfg.color),
                        if (todo.dueDate != null)
                          _metaTag(
                            Icons.access_time_rounded,
                            _formatDateTime(todo.dueDate!),
                            _isOverdue(todo) ? const Color(0xFFF87171) : AppTheme.textMuted,
                          ),
                        if (todo.startReminder != null)
                          _metaTag(
                            Icons.play_circle_outline_rounded,
                            'Start: ${_formatDateTime(todo.startReminder!)}',
                            AppTheme.textMuted,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isOverdue(TodoModel todo) =>
      !todo.isComplete &&
          todo.dueDate != null &&
          todo.dueDate!.isBefore(DateTime.now());


  Widget _statusBadge(StatusConfig cfg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: cfg.gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.colorA.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 11, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTag(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text('$emoji $label',
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _metaTag(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }


  void _showSortSheet(TodoSortOrder current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Sort by',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            ...[
              (TodoSortOrder.dateAdded, 'Date Added', Icons.calendar_today_rounded),
              (TodoSortOrder.dueDate,   'Due Date',   Icons.event_rounded),
              (TodoSortOrder.status,    'Status',     Icons.label_rounded),
              (TodoSortOrder.category,  'Category',   Icons.folder_outlined),
            ].map((item) {
              final (order, label, icon) = item;
              final sel = current == order;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon,
                    color: sel ? AppTheme.accent : AppTheme.textMuted,
                    size: 20),
                title: Text(label,
                    style: TextStyle(
                        color: sel ? AppTheme.accent : AppTheme.textSecondary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                trailing: sel
                    ? const Icon(Icons.check_rounded,
                    color: AppTheme.accent, size: 18)
                    : null,
                onTap: () {
                  context
                      .read<TodoBloc>()
                      .add(ChangeSortOrder(sortOrder: order));
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsCubit>().state.settings.isDarkMode;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(),
                style: TextStyle(
                    color: AppTheme.getMutedText(isDark), fontSize: 12)),
            Text('My Tasks',
                style: TextStyle(
                    color: AppTheme.getPrimaryText(isDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
          ],
        ),
        actions: [
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              final sort = state is TodoLoaded
                  ? state.sortOrder
                  : TodoSortOrder.dateAdded;
              return _appBarBtn(
                  Icons.sort_rounded, () => _showSortSheet(sort));
            },
          ),
          _appBarBtn(
            Icons.bar_chart_rounded,
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                    value: context.read<TodoBloc>(),
                    child: const StatisticsScreen()),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final isDark = settingsState.settings.isDarkMode;
          return Container(
            decoration: AppTheme.backgroundDecoration(isDark),
        child: BlocConsumer<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state is TodoDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
              ));
            }
          },
          builder: (context, state) {
            List<TodoModel> todos = [];
            TodoFilter filter = TodoFilter.all;
            String searchQuery = '';
            TodoSortOrder sortOrder = TodoSortOrder.dateAdded;

            if (state is TodoLoaded) {
              todos = state.todos;
              filter = state.filter;
              searchQuery = state.searchQuery;
              sortOrder = state.sortOrder;
            }
            if (state is TodoDeleted) {
              todos = state.todos;
              filter = state.filter;
              searchQuery = state.searchQuery;
              sortOrder = state.sortOrder;
            }

            final now = DateTime.now();
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
                    t.dueDate!.isBefore(now))
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

            filtered.sort((a, b) {
              switch (sortOrder) {
                case TodoSortOrder.dueDate:
                  if (a.dueDate == null && b.dueDate == null) return 0;
                  if (a.dueDate == null) return 1;
                  if (b.dueDate == null) return -1;
                  return a.dueDate!.compareTo(b.dueDate!);
                case TodoSortOrder.status:
                  return a.status.index.compareTo(b.status.index);
                case TodoSortOrder.category:
                  return a.category.index.compareTo(b.category.index);
                case TodoSortOrder.dateAdded:
                  return b.addedDate.compareTo(a.addedDate);
                case TodoSortOrder.priority:
                  throw UnimplementedError();
              }
            });

            final tomorrow = now.add(const Duration(days: 1));
            List<TodoModel> completed = [], overdue = [],
                today = [], tmrw = [], upcoming = [];

            for (final todo in filtered) {
              if (todo.isComplete) { completed.add(todo); continue; }
              if (todo.dueDate == null) { upcoming.add(todo); continue; }
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
                SizedBox(
                    height: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        8),

                _buildStatsRow(todos, isDark),
                _buildStreakBanner(todos, isDark),
                _buildProgressBar(todos, isDark),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                    onChanged: (v) =>
                        context.read<TodoBloc>().add(SearchTodos(query: v)),
                    style: TextStyle(color: AppTheme.getPrimaryText(isDark)),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(
                          color: AppTheme.getMutedText(isDark), fontSize: 14),
                      prefixIcon: Icon(Icons.search,
                          color: AppTheme.getMutedText(isDark), size: 20),
                      filled: true,
                      fillColor: isDark ? AppTheme.glassFill : Colors.white.withOpacity(0.5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDark ? AppTheme.glassBorder : Colors.blueGrey.withOpacity(0.1))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDark ? AppTheme.glassBorder : Colors.blueGrey.withOpacity(0.1))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.accent, width: 1.5)),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

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
                            accentColor: const Color(0xFFF87171)),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(
                      bottom: kBottomNavigationBarHeight +
                          MediaQuery.of(context).padding.bottom +
                          80,
                    ),
                    children: [
                      _buildSection('⚠ OVERDUE', overdue, isDark),
                      _buildSection('📅 TODAY', today, isDark),
                      _buildSection('🟡 TOMORROW', tmrw, isDark),
                      _buildSection('📦 UPCOMING', upcoming, isDark),
                      _buildCompletedSection(completed, isDark),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _appBarBtn(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.glassFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 18),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _filterChip(String label, TodoFilter value, TodoFilter current,
      {Color? accentColor}) {
    final selected = current == value;
    final color = accentColor ?? AppTheme.accent;
    return GestureDetector(
      onTap: () => context.read<TodoBloc>().add(ChangeFilter(filter: value)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppTheme.glassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppTheme.glassBorder),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }


  void _showAddDialog() => _showEditDialog(null);

  void _showEditDialog(TodoModel? todo) {
    final controller =
    TextEditingController(text: todo?.description ?? '');
    DateTime? dueDate = todo?.dueDate;
    DateTime? reminder = todo?.reminderTime;
    DateTime? startReminder = todo?.startReminder;
    TodoStatus selectedStatus = todo?.status ?? TodoStatus.toDo;
    TodoCategory selectedCategory = todo?.category ?? TodoCategory.personal;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(todo == null ? 'New Task' : 'Edit Task',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _inputDeco('What needs to be done?'),
                    autofocus: todo == null,
                  ),
                  const SizedBox(height: 16),

                  _sheetLabel('Status'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TodoStatus.values.map((s) {
                      final cfg = statusConfig(s);
                      final sel = selectedStatus == s;
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedStatus = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: sel ? cfg.gradient : null,
                            color: sel
                                ? null
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? cfg.colorA.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cfg.icon, size: 12,
                                  color: sel
                                      ? Colors.white
                                      : AppTheme.textMuted),
                              const SizedBox(width: 5),
                              Text(cfg.label,
                                  style: TextStyle(
                                      color: sel
                                          ? Colors.white
                                          : AppTheme.textMuted,
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.normal)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  _sheetLabel('Category'),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TodoCategory.values.map((cat) {
                        final cfg = _catConfig[cat]!;
                        final sel = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setSheet(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? cfg.color.withOpacity(0.18)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: sel
                                      ? cfg.color
                                      : Colors.white.withOpacity(0.08),
                                  width: sel ? 1.5 : 1),
                            ),
                            child: Column(
                              children: [
                                Text(cfg.emoji,
                                    style:
                                    const TextStyle(fontSize: 20)),
                                const SizedBox(height: 4),
                                Text(cfg.label,
                                    style: TextStyle(
                                        color: sel
                                            ? cfg.color
                                            : AppTheme.textMuted,
                                        fontSize: 10,
                                        fontWeight: sel
                                            ? FontWeight.w700
                                            : FontWeight.normal)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _dialogButton(
                          icon: Icons.flag_outlined,
                          label: startReminder != null
                              ? 'Start: ${_formatDateTime(startReminder!)}'
                              : 'Start Date',
                          onTap: () async {
                            final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100));
                            if (d != null) {
                              final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now());
                              if (t != null) {
                                setSheet(() => startReminder = DateTime(
                                    d.year, d.month, d.day,
                                    t.hour, t.minute));
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dialogButton(
                          icon: Icons.event_outlined,
                          label: dueDate != null
                              ? 'Due: ${_formatDateTime(dueDate!)}'
                              : 'Due Date',
                          onTap: () async {
                            final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100));
                            if (d != null) {
                              final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now());
                              if (t != null) {
                                setSheet(() => dueDate = DateTime(
                                    d.year, d.month, d.day,
                                    t.hour, t.minute));
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        final isComplete = selectedStatus == TodoStatus.done;
                        if (todo == null) {
                          context.read<TodoBloc>().add(AddTodo(
                            description: text,
                            dueDate: dueDate,
                            reminderTime: reminder,
                            startReminder: startReminder,
                            status: selectedStatus,
                            category: selectedCategory,
                          ));
                        } else {
                          context.read<TodoBloc>().add(EditTodo(
                            updatedTodo: todo.copyWith(
                              description: text,
                              dueDate: dueDate,
                              reminderTime: reminder,
                              startReminder: startReminder,
                              status: selectedStatus,
                              category: selectedCategory,
                              isComplete: isComplete,
                            ),
                          ));
                        }
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentDim,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Save Task',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetLabel(String text) => Text(text,
      style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle:
    const TextStyle(color: AppTheme.textMuted, fontSize: 14),
    filled: true,
    fillColor: Colors.white.withOpacity(0.04),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.glassBorder)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.glassBorder)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppTheme.accent, width: 1.5)),
  );

  Widget _dialogButton(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day}/${d.month}/${d.year} $h:${d.minute.toString().padLeft(2, '0')} $p';
  }
}


Color getPriorityColor(int priority) => AppTheme.accent;

LinearGradient getPriorityGradient(int priority) => LinearGradient(
    colors: [AppTheme.accent.withOpacity(0.6), AppTheme.accentDim],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter);