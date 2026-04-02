import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc/todo_bloc.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc/todo_state.dart';
import 'package:todo_app/features/todo/presentation/screens/app_theme.dart';
import 'package:todo_app/features/settings/cubit/theme_cubit.dart';
import 'package:todo_app/features/todo/presentation/screens/status_config.dart';
import 'package:todo_app/features/todo/presentation/screens/streak_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsCubit>().state.settings.isDarkMode;

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        final todos = state is TodoLoaded
            ? state.todos
            : state is TodoDeleted
            ? state.todos
            : <TodoModel>[];

        final total = todos.length;
        final completed = todos.where((t) => t.isComplete).length;
        final pending = todos.where((t) => !t.isComplete).length;
        final overdue = todos
            .where((t) =>
        !t.isComplete &&
            t.dueDate != null &&
            t.dueDate!.isBefore(DateTime.now()))
            .length;
        final completionRate = total > 0 ? completed / total : 0.0;
        final streak = StreakService.instance.calculate(todos);

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Statistics',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: Container(
            decoration: AppTheme.backgroundDecoration(isDark),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                16,
                32,
              ),
              children: [
                // ── Top stat cards ────────────────────────────────────
                Row(
                  children: [
                    _StatCard(
                      label: 'Total',
                      value: '$total',
                      icon: Icons.list_alt_rounded,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: 'Completed',
                      value: '$completed',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF34D399),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: 'Pending',
                      value: '$pending',
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFFBBF24),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Completion rate ───────────────────────────────────
                _GlassSection(
                  title: 'Completion Rate',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(completionRate * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completionRate,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF34D399)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$completed completed',
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 12)),
                          if (overdue > 0)
                            Text('$overdue overdue',
                                style: const TextStyle(
                                    color: Color(0xFFF87171), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Streak ────────────────────────────────────────────
                _GlassSection(
                  title: 'Streak',
                  child: Row(
                    children: [
                      _streakStat('🏆', '${streak.bestStreak}', 'Best Streak'),
                      _divider(),
                      _streakStat('✅', '${streak.totalDone}', 'Total Done'),
                      _divider(),
                      _streakStat(
                        '📅',
                        streak.lastActive != null
                            ? '${streak.lastActive!.day}/${streak.lastActive!.month}'
                            : 'Never',
                        'Last Active',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Completed vs Pending ──────────────────────────────
                _GlassSection(
                  title: 'Completed vs Pending',
                  child: _BarChart(
                    bars: [
                      _Bar('Completed', completed, const Color(0xFF34D399)),
                      _Bar('Pending', pending, const Color(0xFFFBBF24)),
                      _Bar('Overdue', overdue, const Color(0xFFF87171)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tasks by Status ───────────────────────────────────
                _GlassSection(
                  title: 'Tasks by Status',
                  child: _BarChart(
                    bars: TodoStatus.values.map((s) {
                      final cfg = statusConfig(s);
                      return _Bar(
                        cfg.label,
                        todos.where((t) => t.status == s).length,
                        cfg.midColor,
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tasks by Category ─────────────────────────────────
                _GlassSection(
                  title: 'Tasks by Category',
                  child: _BarChart(
                    bars: TodoCategory.values.map((cat) {
                      final count =
                          todos.where((t) => t.category == cat).length;
                      const colors = {
                        TodoCategory.work:         Color(0xFF60A5FA),
                        TodoCategory.personal:     Color(0xFF34D399),
                        TodoCategory.professional: Color(0xFF818CF8),
                        TodoCategory.family:       Color(0xFFFBBF24),
                        TodoCategory.fitness:      Color(0xFFF87171),
                        TodoCategory.other:        Color(0xFF94A3B8),
                      };
                      const labels = {
                        TodoCategory.work:         'Work',
                        TodoCategory.personal:     'Personal',
                        TodoCategory.professional: 'Pro',
                        TodoCategory.family:       'Family',
                        TodoCategory.fitness:      'Fitness',
                        TodoCategory.other:        'Other',
                      };
                      return _Bar(labels[cat]!, count, colors[cat]!);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _streakStat(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 50,
    color: Colors.white.withOpacity(0.08),
  );
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Glass section ────────────────────────────────────────────────────────────

class _GlassSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _GlassSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsCubit>().state.settings.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(isDark: isDark, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Bar chart ────────────────────────────────────────────────────────────────

class _Bar {
  final String label;
  final int value;
  final Color color;
  const _Bar(this.label, this.value, this.color);
}

class _BarChart extends StatelessWidget {
  final List<_Bar> bars;
  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    final maxVal =
    bars.map((b) => b.value).fold(0, (a, b) => a > b ? a : b);

    return Column(
      children: bars.map((bar) {
        final fraction = maxVal > 0 ? bar.value / maxVal : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(bar.label,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      widthFactor: fraction,
                      child: Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: bar.color.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text('${bar.value}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: bar.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}