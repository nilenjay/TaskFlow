import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/focus/data/models/focus_model.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_event.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_state.dart';
import 'package:todo_app/features/settings/cubit/theme_cubit.dart';
import '../../../todo/presentation/screens/app_theme.dart';
class FocusSummaryScreen extends StatefulWidget {
  final FocusCompleted state;
  const FocusSummaryScreen({super.key, required this.state});

  @override
  State<FocusSummaryScreen> createState() => _FocusSummaryScreenState();
}

class _FocusSummaryScreenState extends State<FocusSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  late Animation<int> _plannedAnim;
  late Animation<int> _focusedAnim;
  late Animation<int> _breaksAnim;

  @override
  void initState() {
    super.initState();
    final session = widget.state.session;
    final completionPct =
    (session.actualFocusMinutes / session.plannedMinutes.clamp(1, 9999))
        .clamp(0.0, 1.0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final curve = CurvedAnimation(
        parent: _controller, curve: Curves.easeOutCubic);

    _progressAnim = Tween<double>(begin: 0, end: completionPct)
        .animate(curve);
    _plannedAnim =
        IntTween(begin: 0, end: session.plannedMinutes).animate(curve);
    _focusedAnim =
        IntTween(begin: 0, end: session.actualFocusMinutes).animate(curve);
    _breaksAnim =
        IntTween(begin: 0, end: session.breaksCompleted).animate(curve);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.state.session;
    final completionPct =
    (session.actualFocusMinutes / session.plannedMinutes.clamp(1, 9999))
        .clamp(0.0, 1.0);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isDark = settingsState.settings.isDarkMode;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Session Summary',
              style: TextStyle(
                color: AppTheme.getPrimaryText(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Container(
            decoration: AppTheme.backgroundDecoration(isDark),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    24, 24, 24,
                    24 + kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: completionPct >= 1.0
                              ? [const Color(0xFF4F46E5), const Color(0xFF7C3AED)]
                              : [const Color(0xFF6B7280), const Color(0xFF4B5563)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (completionPct >= 1.0
                                ? const Color(0xFF4F46E5)
                                : Colors.grey)
                                .withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            completionPct >= 1.0 ? '🎉' : '⏹',
                            style: const TextStyle(fontSize: 52),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            session.sessionName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${session.focusType.emoji} ${session.focusType.label}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _progressAnim.value,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                                Text(
                                  '${(_progressAnim.value * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          Text(
                            completionPct >= 1.0
                                ? 'Session complete!'
                                : 'Keep it up next time!',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        _AnimatedStatCard(
                          label: 'Planned',
                          value: '${_plannedAnim.value}m',
                          icon: Icons.schedule_rounded,
                          color: const Color(0xFF6366F1),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        _AnimatedStatCard(
                          label: 'Focused',
                          value: '${_focusedAnim.value}m',
                          icon: Icons.bolt_rounded,
                          color: const Color(0xFF059669),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        _AnimatedStatCard(
                          label: 'Breaks',
                          value: '${_breaksAnim.value}',
                          icon: Icons.coffee_rounded,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Text('Rate this session',
                        style: TextStyle(
                            color: AppTheme.getPrimaryText(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('How productive did you feel?',
                        style: TextStyle(
                            color: AppTheme.getMutedText(isDark), fontSize: 12)),
                    const SizedBox(height: 14),

                    BlocBuilder<FocusBloc, FocusState>(
                      builder: (context, s) {
                        final rating = s is FocusCompleted
                            ? s.session.rating
                            : session.rating;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return GestureDetector(
                              onTap: () => context
                                  .read<FocusBloc>()
                                  .add(RateSession(rating: i + 1)),
                              child: AnimatedScale(
                                scale: i < rating ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    i < rating
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: Colors.amber,
                                    size: 38,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    FilledButton(
                      onPressed: () =>
                          context.read<FocusBloc>().add(const ResetSession()),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'New Session',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _AnimatedStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.08 : 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(isDark ? 0.2 : 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}