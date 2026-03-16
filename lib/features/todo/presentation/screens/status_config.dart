import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

class StatusConfig {
  final String label;
  final String emoji;
  final Color colorA; // gradient start
  final Color colorB; // gradient end
  final IconData icon;

  const StatusConfig({
    required this.label,
    required this.emoji,
    required this.colorA,
    required this.colorB,
    required this.icon,
  });

  LinearGradient get gradient => LinearGradient(
    colors: [colorA, colorB],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Color get midColor => Color.lerp(colorA, colorB, 0.5)!;
}

const statusConfigs = <TodoStatus, StatusConfig>{
  TodoStatus.toDo: StatusConfig(
    label: 'To-do',
    emoji: '➕',
    colorA: Color(0xFF3B4A6B),
    colorB: Color(0xFF1E2D4A),
    icon: Icons.add_circle_outline_rounded,
  ),
  TodoStatus.inProgress: StatusConfig(
    label: 'In Progress',
    emoji: '⚡',
    colorA: Color(0xFF0E7490),
    colorB: Color(0xFF164E63),
    icon: Icons.timelapse_rounded,
  ),
  TodoStatus.inReview: StatusConfig(
    label: 'In Review',
    emoji: '📋',
    colorA: Color(0xFF92400E),
    colorB: Color(0xFF78350F),
    icon: Icons.rate_review_outlined,
  ),
  TodoStatus.done: StatusConfig(
    label: 'Done',
    emoji: '✅',
    colorA: Color(0xFF065F46),
    colorB: Color(0xFF064E3B),
    icon: Icons.check_circle_outline_rounded,
  ),
  TodoStatus.blocked: StatusConfig(
    label: 'Blocked',
    emoji: '🚫',
    colorA: Color(0xFF9B1C1C),
    colorB: Color(0xFF7F1D1D),
    icon: Icons.block_rounded,
  ),
  TodoStatus.onHold: StatusConfig(
    label: 'On Hold',
    emoji: '⏸',
    colorA: Color(0xFF1E3A5F),
    colorB: Color(0xFF172554),
    icon: Icons.pause_circle_outline_rounded,
  ),
  TodoStatus.rework: StatusConfig(
    label: 'Rework',
    emoji: '🔄',
    colorA: Color(0xFF5B21B6),
    colorB: Color(0xFF4C1D95),
    icon: Icons.refresh_rounded,
  ),
};

StatusConfig statusConfig(TodoStatus s) => statusConfigs[s]!;