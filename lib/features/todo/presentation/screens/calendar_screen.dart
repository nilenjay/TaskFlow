import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/todo_model.dart';
import '../bloc/todo_bloc/todo_bloc.dart';
import '../bloc/todo_bloc/todo_state.dart';
import 'todo_screen.dart'; // reuses getPriorityGradient, getPriorityColor

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns all days in the grid (including leading/trailing days from
  /// adjacent months to fill complete weeks).
  List<DateTime?> _buildGridDays() {
    final firstOfMonth =
    DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastOfMonth =
    DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    // Sunday = 0 ... Saturday = 6
    final leadingBlanks = firstOfMonth.weekday % 7;
    final trailingBlanks =
        6 - (lastOfMonth.weekday % 7);

    final days = <DateTime?>[];

    for (int i = 0; i < leadingBlanks; i++) {
      days.add(firstOfMonth.subtract(Duration(days: leadingBlanks - i)));
    }
    for (int d = 1; d <= lastOfMonth.day; d++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    for (int i = 1; i <= trailingBlanks; i++) {
      days.add(lastOfMonth.add(Duration(days: i)));
    }

    return days;
  }

  // ─── Dot logic ─────────────────────────────────────────────────────────────

  /// Returns which dot types a day should show.
  /// 'start' = purple dot (startReminder falls on this day)
  /// 'due'   = red dot    (dueDate falls on this day)
  Set<String> _dotsForDay(DateTime day, List<TodoModel> todos) {
    final dots = <String>{};
    for (final todo in todos) {
      if (todo.isComplete) continue;
      if (todo.startReminder != null &&
          _isSameDay(todo.startReminder!, day)) {
        dots.add('start');
      }
      if (todo.dueDate != null && _isSameDay(todo.dueDate!, day)) {
        dots.add('due');
      }
    }
    return dots;
  }

  // ─── Tasks for selected day ─────────────────────────────────────────────────

  List<TodoModel> _startingOn(DateTime day, List<TodoModel> todos) => todos
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

  // ─── Build ──────────────────────────────────────────────────────────────────

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
          appBar: AppBar(title: const Text('Calendar')),
          body: Column(
            children: [
              // ── Month navigation ──────────────────────────────────────
              _MonthHeader(
                focusedMonth: _focusedMonth,
                onPrev: () => setState(() {
                  _focusedMonth = DateTime(
                      _focusedMonth.year, _focusedMonth.month - 1);
                }),
                onNext: () => setState(() {
                  _focusedMonth = DateTime(
                      _focusedMonth.year, _focusedMonth.month + 1);
                }),
              ),

              // ── Day-of-week headers ───────────────────────────────────
              const _WeekdayRow(),

              // ── Calendar grid ─────────────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: gridDays.length,
                itemBuilder: (context, index) {
                  final day = gridDays[index];
                  if (day == null) return const SizedBox();

                  final isCurrentMonth =
                      day.month == _focusedMonth.month;
                  final isSelected = _isSameDay(day, _selectedDay);
                  final isToday = _isSameDay(day, DateTime.now());
                  final dots = _dotsForDay(day, todos);

                  return _DayCell(
                    day: day,
                    isCurrentMonth: isCurrentMonth,
                    isSelected: isSelected,
                    isToday: isToday,
                    hasDueDot: dots.contains('due'),
                    hasStartDot: dots.contains('start'),
                    onTap: () =>
                        setState(() => _selectedDay = day),
                  );
                },
              ),

              const Divider(height: 1),

              // ── Tasks for selected day ────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _TaskSection(
                      icon: Icons.play_circle,
                      iconColor: Colors.green,
                      label: 'Starting',
                      todos: starting,
                    ),
                    _TaskSection(
                      icon: Icons.flag,
                      iconColor: Colors.red,
                      label: 'Due',
                      todos: due,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Month Header ─────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.focusedMonth,
    required this.onPrev,
    required this.onNext,
  });

  static const _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Text(
            '${_months[focusedMonth.month - 1]} ${focusedMonth.year}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ─── Weekday Row ──────────────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _days
            .map((d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final bool hasDueDot;
  final bool hasStartDot;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.hasDueDot,
    required this.hasStartDot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? bgColor;
    Color textColor;

    if (isSelected) {
      bgColor = Colors.deepPurple;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = Colors.deepPurple.withOpacity(0.12);
      textColor = Colors.deepPurple;
    } else {
      textColor = isCurrentMonth
          ? theme.textTheme.bodyMedium!.color!
          : Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
            // Dots row
            if (hasDueDot || hasStartDot)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasStartDot)
                    _Dot(
                      color: isSelected ? Colors.white : Colors.deepPurple,
                    ),
                  if (hasDueDot && hasStartDot)
                    const SizedBox(width: 2),
                  if (hasDueDot)
                    _Dot(
                      color: isSelected ? Colors.white70 : Colors.red,
                    ),
                ],
              )
            else
              const SizedBox(height: 5), // keep cell height consistent
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Task Section (Starting / Due) ───────────────────────────────────────────

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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${todos.length}',
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (todos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No tasks',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          )
        else
          ...todos.map((todo) => _CalendarTodoTile(todo: todo)),
      ],
    );
  }
}

// ─── Calendar Todo Tile (same style as todo_screen _buildTodoTile) ────────────

class _CalendarTodoTile extends StatelessWidget {
  final TodoModel todo;
  const _CalendarTodoTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority strip
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: getPriorityGradient(todo.priority),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            if (todo.dueDate != null)
                              _infoIcon(Icons.calendar_today,
                                  _formatDate(todo.dueDate!)),
                            if (todo.startReminder != null)
                              _infoIcon(Icons.play_arrow,
                                  _formatTime(todo.startReminder!)),
                            if (todo.reminderTime != null)
                              _infoIcon(Icons.notifications,
                                  _formatTime(todo.reminderTime!)),
                          ],
                        ),
                      ],
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

  Widget _infoIcon(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}