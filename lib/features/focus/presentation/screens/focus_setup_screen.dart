import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/focus/data/models/focus_model.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_event.dart';
import 'package:todo_app/features/settings/cubit/theme_cubit.dart';
import 'package:todo_app/features/todo/presentation/screens/app_theme.dart';

class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  final _nameController = TextEditingController(text: 'Focus Session');
  late int _durationMinutes;
  late FocusType _selectedType;
  bool _defaultsLoaded = false;

  static const List<int> _quickDurations = [15, 25, 30, 45, 50, 60, 90, 120];

  static const _typeConfig = {
    FocusType.study: (
    emoji: '📚',
    label: 'Study',
    color: Color(0xFF60A5FA),
    ),
    FocusType.deepWork: (
    emoji: '💼',
    label: 'Deep Work',
    color: Color(0xFF818CF8),
    ),
    FocusType.creative: (
    emoji: '🎨',
    label: 'Creative',
    color: Color(0xFFA78BFA),
    ),
  };

  static const _focusTypesList = [
    FocusType.study,
    FocusType.deepWork,
    FocusType.creative,
  ];

  void _loadDefaults(SettingsState settingsState) {
    if (_defaultsLoaded) return;
    _durationMinutes = settingsState.settings.defaultDurationMinutes;
    _selectedType =
    _focusTypesList[settingsState.settings.defaultFocusTypeIndex];
    _defaultsLoaded = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Custom duration bottom sheet ─────────────────────────────────────────

  void _showCustomDurationPicker(bool isDark) {
    int hours = _durationMinutes ~/ 60;
    int minutes = _durationMinutes % 60;
    minutes = (minutes ~/ 5) * 5;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F3A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 20, 24,
            MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Custom Duration',
                style: TextStyle(
                  color: AppTheme.getPrimaryText(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Set any duration from 5 minutes to 8 hours',
                style: TextStyle(
                    color: AppTheme.getMutedText(isDark), fontSize: 13),
              ),
              const SizedBox(height: 28),

              _SliderRow(
                label: 'Hours',
                value: hours,
                min: 0,
                max: 8,
                color: AppTheme.accent,
                displayValue: '${hours}h',
                isDark: isDark,
                onChanged: (v) => setSheetState(() => hours = v),
              ),

              const SizedBox(height: 20),

              _SliderRow(
                label: 'Minutes',
                value: minutes ~/ 5,
                min: 0,
                max: 11,
                divisions: 11,
                color: const Color(0xFFA78BFA),
                displayValue: '${minutes}m',
                isDark: isDark,
                onChanged: (v) =>
                    setSheetState(() => minutes = v * 5),
              ),

              const SizedBox(height: 20),

              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGlow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accent),
                  ),
                  child: Text(
                        () {
                      final total = hours * 60 + minutes;
                      if (total == 0) return 'Select a duration';
                      final h = hours > 0 ? '${hours}h ' : '';
                      final m = minutes > 0 ? '${minutes}m' : '';
                      return '$h$m  =  $total minutes total';
                    }(),
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
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
                      setState(() => _durationMinutes = total);
                    }
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentDim,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Set Duration',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        _loadDefaults(settingsState);
        final isDark = settingsState.settings.isDarkMode;
        final breaks = calculateBreaks(_durationMinutes, _selectedType);
        final isCustom = !_quickDurations.contains(_durationMinutes);

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Focus Session',
              style: TextStyle(
                color: AppTheme.getPrimaryText(isDark),
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
                _sectionLabel('SESSION NAME', isDark),
                const SizedBox(height: 8),
                Container(
                  decoration: AppTheme.glassCard(isDark: isDark, radius: 14),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                        color: AppTheme.getPrimaryText(isDark), fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. Chapter 5 Review',
                      hintStyle: TextStyle(
                          color: AppTheme.getMutedText(isDark), fontSize: 14),
                      prefixIcon: Icon(Icons.edit_outlined,
                          color: AppTheme.getMutedText(isDark), size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                _sectionLabel('FOCUS TYPE', isDark),
                const SizedBox(height: 12),
                Row(
                  children: FocusType.values.map((type) {
                    final cfg = _typeConfig[type]!;
                    final selected = _selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: FocusType.values.last == type
                              ? EdgeInsets.zero
                              : const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? cfg.color.withOpacity(0.18)
                                : (isDark ? AppTheme.glassFill : Colors.white.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? cfg.color.withOpacity(0.6)
                                  : (isDark ? AppTheme.glassBorder : Colors.black.withOpacity(0.05)),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(cfg.emoji,
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 6),
                              Text(
                                cfg.label,
                                style: TextStyle(
                                  color: selected
                                      ? cfg.color
                                      : AppTheme.getSecondaryText(isDark),
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                 ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(child: _sectionLabel('DURATION', isDark)),
                    if (isCustom)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGlow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_durationMinutes min',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._quickDurations.map((min) {
                      final selected = _durationMinutes == min;
                      return _DurationChip(
                        label: '${min}m',
                        selected: selected,
                        isDark: isDark,
                        onTap: () =>
                            setState(() => _durationMinutes = min),
                      );
                    }),
                    _DurationChip(
                      label: isCustom
                          ? '$_durationMinutes m ✎'
                          : 'Custom ✎',
                      selected: isCustom,
                      isDark: isDark,
                      accentColor: const Color(0xFFA78BFA),
                      onTap: () => _showCustomDurationPicker(isDark),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassCard(isDark: isDark, radius: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('⏱',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            'Scheduled Breaks',
                            style: TextStyle(
                              color: AppTheme.getSecondaryText(isDark),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGlow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${breaks.length}',
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (breaks.isEmpty)
                        Text(
                          'No breaks — session under 30 minutes.',
                          style: TextStyle(
                              color: AppTheme.getMutedText(isDark), fontSize: 13),
                        )
                      else
                        ...breaks.asMap().entries.map((e) {
                          final i = e.key;
                          final b = e.value;
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Break ${i + 1}:  after ${b.afterMinutes}m  →  ${b.breakMinutes}m rest',
                                  style: TextStyle(
                                    color: AppTheme.getMutedText(isDark),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) return;
                    context.read<FocusBloc>().add(StartSession(
                      sessionName: name,
                      durationMinutes: _durationMinutes,
                      focusType: _selectedType,
                    ));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(0xFF4F46E5).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Start Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      color: AppTheme.getMutedText(isDark),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
  );
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
        const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.2)
              : (isDark ? AppTheme.glassFill : Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : (isDark ? AppTheme.glassBorder : Colors.black.withOpacity(0.05)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.getSecondaryText(isDark),
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
  final String displayValue;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.displayValue,
    required this.isDark,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
                color: AppTheme.getSecondaryText(isDark), fontSize: 13),
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
          width: 40,
          child: Text(
            displayValue,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}