import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/settings/cubit/theme_cubit.dart';
import 'package:todo_app/features/todo/presentation/screens/app_theme.dart';
import 'package:todo_app/features/todo/presentation/screens/animated_theme_toggle.dart';
import '../../../auth/bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _focusTypes = ['Study 📚', 'Deep Work 💼', 'Creative 🎨'];

  static const _quickDurations = [25, 50, 90, 120];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final isDark = settings.isDarkMode;

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Settings',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          body: Container(
            decoration: AppTheme.backgroundDecoration(isDark),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                20,
                kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    24,
              ),
              children: [
                _SectionHeader(label: 'APPEARANCE'),
                const SizedBox(height: 10),

                _GlassCard(
                  isDark: isDark,
                  child: _SettingsRow(
                    isDark: isDark,
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    iconColor: isDark
                        ? AppTheme.accent
                        : const Color(0xFFF59E0B),
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Currently dark' : 'Currently light',
                    trailing: AnimatedThemeToggle(
                      isDark: isDark,
                      onChanged: (_) =>
                          context.read<SettingsCubit>().toggleTheme(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _SectionHeader(label: 'NOTIFICATIONS'),
                const SizedBox(height: 10),

                _GlassCard(
                  isDark: isDark,
                  child: _SettingsRow(
                    isDark: isDark,
                    icon: settings.notificationsEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    iconColor: settings.notificationsEnabled
                        ? const Color(0xFF34D399)
                        : AppTheme.textMuted,
                    title: 'Session Notifications',
                    subtitle: settings.notificationsEnabled
                        ? 'Break & completion alerts on'
                        : 'All session alerts off',
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (_) => context
                          .read<SettingsCubit>()
                          .toggleNotifications(),
                      activeThumbColor: const Color(0xFF34D399),
                      activeTrackColor:
                      const Color(0xFF34D399).withOpacity(0.3),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _SectionHeader(label: 'FOCUS DEFAULTS'),
                const SizedBox(height: 10),

                _GlassCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsRow(
                        isDark: isDark,
                        icon: Icons.psychology_rounded,
                        iconColor: AppTheme.accent,
                        title: 'Default Focus Type',
                        subtitle: _focusTypes[
                        settings.defaultFocusTypeIndex],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          _focusTypes.length,
                              (i) {
                            final selected =
                                settings.defaultFocusTypeIndex == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<SettingsCubit>()
                                    .setDefaultFocusType(i),
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 180),
                                  margin: i < _focusTypes.length - 1
                                      ? const EdgeInsets.only(right: 8)
                                      : EdgeInsets.zero,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppTheme.accent
                                        .withOpacity(0.2)
                                        : Colors.white
                                        .withOpacity(0.05),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.accent
                                          : Colors.white
                                          .withOpacity(0.1),
                                      width: selected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    _focusTypes[i]
                                        .split(' ')
                                        .last, // just the emoji
                                    textAlign: TextAlign.center,
                                    style:
                                    const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      Divider(
                          color: Colors.white.withOpacity(0.08),
                          height: 1),
                      const SizedBox(height: 20),

                      _SettingsRow(
                        isDark: isDark,
                        icon: Icons.timer_rounded,
                        iconColor: const Color(0xFFA78BFA),
                        title: 'Default Duration',
                        subtitle:
                        '${settings.defaultDurationMinutes} minutes',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._quickDurations.map((min) {
                            final selected =
                                settings.defaultDurationMinutes == min;
                            return _DurationChip(
                              label: '${min}m',
                              selected: selected,
                              isDark: isDark,
                              onTap: () => context
                                  .read<SettingsCubit>()
                                  .setDefaultDuration(min),
                            );
                          }),
                          _DurationChip(
                            label: settings.defaultDurationMinutes >
                                _quickDurations.last
                                ? '${settings.defaultDurationMinutes}m ✎'
                                : 'Custom',
                            selected: !_quickDurations.contains(
                                settings.defaultDurationMinutes),
                            isDark: isDark,
                            accentColor: const Color(0xFFA78BFA),
                            onTap: () => _showCustomDurationPicker(
                                context, settings.defaultDurationMinutes),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _SectionHeader(label: 'ACCOUNT'),
                const SizedBox(height: 10),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      final user = authState.user;
                      return _GlassCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                  AppTheme.accentGlow,
                                  backgroundImage: user.photoURL != null
                                      ? NetworkImage(user.photoURL!)
                                      : null,
                                  child: user.photoURL == null
                                      ? Text(
                                    (user.displayName ?? 'U')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.displayName ?? 'User',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppTheme.textPrimary
                                              : const Color(0xFF1E293B),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        user.email ?? '',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34D399)
                                        .withOpacity(0.12),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFF34D399)
                                            .withOpacity(0.3)),
                                  ),
                                  child: const Text('Synced',
                                      style: TextStyle(
                                          color: Color(0xFF34D399),
                                          fontSize: 11,
                                          fontWeight:
                                          FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Divider(
                                color: Colors.white.withOpacity(0.08),
                                height: 1),
                            const SizedBox(height: 4),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF87171)
                                      .withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.logout_rounded,
                                    color: Color(0xFFF87171),
                                    size: 18),
                              ),
                              title: const Text('Sign Out',
                                  style: TextStyle(
                                    color: Color(0xFFF87171),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  )),
                              onTap: () {
                                context.read<AuthBloc>().add(
                                    const AuthSignOutRequested());
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return _GlassCard(
                      isDark: isDark,
                      child: _SettingsRow(
                        isDark: isDark,
                        icon: Icons.cloud_off_rounded,
                        iconColor: AppTheme.textMuted,
                        title: 'Not signed in',
                        subtitle: 'Tasks are local only',
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _SectionHeader(label: 'ABOUT'),
                const SizedBox(height: 10),
                _GlassCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TaskFlow',
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.textPrimary
                                      : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(
                          color: Colors.white.withOpacity(0.08), height: 1),
                      const SizedBox(height: 4),
                      _SettingsRow(
                        isDark: isDark,
                        icon: Icons.code_rounded,
                        iconColor: const Color(0xFF34D399),
                        title: 'Built with Flutter',
                        subtitle: 'Plan. Focus. Achieve.',
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

  void _showCustomDurationPicker(
      BuildContext context, int currentMinutes) {
    int hours = currentMinutes ~/ 60;
    int minutes = currentMinutes % 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1F3A),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Custom Duration',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _SliderRow(
                label: 'Hours',
                value: hours,
                min: 0,
                max: 8,
                color: AppTheme.accent,
                onChanged: (v) => setState(() => hours = v),
              ),

              const SizedBox(height: 16),

              _SliderRow(
                label: 'Minutes',
                value: minutes,
                min: 0,
                max: 55,
                divisions: 11, // every 5 min
                color: const Color(0xFFA78BFA),
                onChanged: (v) =>
                    setState(() => minutes = (v ~/ 5) * 5),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Total: ${hours * 60 + minutes} minutes',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final total = hours * 60 + minutes;
                    if (total >= 5) {
                      context
                          .read<SettingsCubit>()
                          .setDefaultDuration(total);
                    }
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentDim,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Set Duration',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _GlassCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassFill
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.glassBorder
              : Colors.white.withOpacity(0.8),
        ),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isDark;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimary
                      : const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textMuted
                      : const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final Color? accentColor;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.white.withOpacity(0.15),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.textMuted,
            fontSize: 13,
            fontWeight:
            selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int? divisions;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions ?? (max - min),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}