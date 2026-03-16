import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/todo_model.dart';
import '../bloc/todo_bloc/todo_bloc.dart';
import '../bloc/todo_bloc/todo_state.dart';
import 'app_theme.dart';
import 'status_config.dart'; // ← replaces getPriorityGradient

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth =
  DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _buildGridDays() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final last = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final leading = first.weekday % 7;
    final trailing = 6 - (last.weekday % 7);
    final days = <DateTime>[];
    for (int i = leading; i > 0; i--)
      days.add(first.subtract(Duration(days: i)));
    for (int d = 1; d <= last.day; d++)
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    for (int i = 1; i <= trailing; i++)
      days.add(last.add(Duration(days: i)));
    return days;
  }

  Set<String> _dotsForDay(DateTime day, List<TodoModel> todos) {
    final dots = <String>{};
    for (final t in todos) {
      if (t.isComplete) continue;
      if (t.startReminder != null && _isSameDay(t.startReminder!, day))
        dots.add('start');
      if (t.dueDate != null && _isSameDay(t.dueDate!, day))
        dots.add('due');
    }
    return dots;
  }

  List<TodoModel> _startingOn(DateTime day, List<TodoModel> todos) =>
      todos
          .where((t) =>
      !t.isComplete &&
          t.startReminder != null &&
          _isSameDay(t.startReminder!, day))
          .toList();

  List<TodoModel> _dueOn(DateTime day, List<TodoModel> todos) => todos
      .where((t) =>
  !t.isComplete &&
      t.dueDate != null &&
      _isSameDay(t.dueDate!, day))
      .toList();

  static const _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];
  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        List<TodoModel> todos = [];
        if (state is TodoLoaded) todos = state.todos;
        if (state is TodoDeleted) todos = state.todos;

        final gridDays = _buildGridDays();
        final starting = _startingOn(_selectedDay, todos);
        final due = _dueOn(_selectedDay, todos);

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Calendar',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          body: Container(
            decoration: AppTheme.backgroundDecoration,
            child: Column(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).padding.top +
                        kToolbarHeight),

                // ── Month navigation ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: AppTheme.glassCard(radius: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: AppTheme.textSecondary),
                          onPressed: () => setState(() {
                            _focusedMonth = DateTime(
                                _focusedMonth.year, _focusedMonth.month - 1);
                          }),
                        ),
                        Text(
                          '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: AppTheme.textSecondary),
                          onPressed: () => setState(() {
                            _focusedMonth = DateTime(
                                _focusedMonth.year, _focusedMonth.month + 1);
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Weekday headers ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _weekdays
                        .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            )),
                      ),
                    ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Calendar grid ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: gridDays.length,
                    itemBuilder: (context, i) {
                      final day = gridDays[i];
                      final isCurrentMonth =
                          day.month == _focusedMonth.month;
                      final isSelected = _isSameDay(day, _selectedDay);
                      final isToday = _isSameDay(day, DateTime.now());
                      final dots = _dotsForDay(day, todos);

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accent
                                : isToday
                                ? AppTheme.accentGlow
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(
                                color: AppTheme.accent, width: 1)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : isCurrentMonth
                                      ? AppTheme.textSecondary
                                      : AppTheme.textMuted
                                      .withOpacity(0.4),
                                ),
                              ),
                              if (dots.isNotEmpty)
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    if (dots.contains('start'))
                                      _Dot(
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.accent),
                                    if (dots.contains('start') &&
                                        dots.contains('due'))
                                      const SizedBox(width: 2),
                                    if (dots.contains('due'))
                                      _Dot(
                                          color: isSelected
                                              ? Colors.white70
                                              : const Color(0xFFF87171)),
                                  ],
                                )
                              else
                                const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                      color: Colors.white.withOpacity(0.08), height: 1),
                ),

                // ── Task list ─────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16, 12, 16,
                      kBottomNavigationBarHeight +
                          MediaQuery.of(context).padding.bottom +
                          16,
                    ),
                    children: [
                      _TaskSection(
                        icon: Icons.play_circle,
                        iconColor: AppTheme.accent,
                        label: 'Starting',
                        todos: starting,
                      ),
                      const SizedBox(height: 8),
                      _TaskSection(
                        icon: Icons.flag,
                        iconColor: const Color(0xFFF87171),
                        label: 'Due',
                        todos: due,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Dot ──────────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Task section ─────────────────────────────────────────────────────────────

class _TaskSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final List<TodoModel> todos;

  const _TaskSection({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.todos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${todos.length}',
                  style: TextStyle(
                      color: iconColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text('No tasks',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 13)),
          )
        else
          ...todos.map((t) => _CalendarTile(todo: t)),
      ],
    );
  }
}

// ─── Calendar tile ────────────────────────────────────────────────────────────

class _CalendarTile extends StatelessWidget {
  final TodoModel todo;
  const _CalendarTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    final cfg = statusConfig(todo.status); // ← status-based colour

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: AppTheme.glassCard(radius: 14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status-coloured left strip (replaces priority gradient)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: cfg.colorA,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.description,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (todo.dueDate != null ||
                          todo.startReminder != null) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          children: [
                            if (todo.dueDate != null)
                              _chip(Icons.calendar_today,
                                  _fmt(todo.dueDate!)),
                            if (todo.startReminder != null)
                              _chip(Icons.play_arrow,
                                  _fmtT(todo.startReminder!)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppTheme.textMuted),
      const SizedBox(width: 3),
      Text(text,
          style: const TextStyle(
              fontSize: 11, color: AppTheme.textMuted)),
    ],
  );

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _fmtT(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
  }
}