import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

// ─── FocusType enum ───────────────────────────────────────────────────────────

@HiveType(typeId: 1)
enum FocusType {
  @HiveField(0)
  study,
  @HiveField(1)
  deepWork,
  @HiveField(2)
  creative,
}

extension FocusTypeLabel on FocusType {
  String get label {
    switch (this) {
      case FocusType.study:
        return 'Study';
      case FocusType.deepWork:
        return 'Deep Work';
      case FocusType.creative:
        return 'Creative';
    }
  }

  String get emoji {
    switch (this) {
      case FocusType.study:
        return '📚';
      case FocusType.deepWork:
        return '💼';
      case FocusType.creative:
        return '🎨';
    }
  }
}

// ─── SessionPhase (runtime only — not persisted) ──────────────────────────────

enum SessionPhase { focus, breakTime }

// ─── BreakInterval (runtime only — not persisted) ─────────────────────────────

class BreakInterval {
  final int afterMinutes;  // elapsed focus minutes when break triggers
  final int breakMinutes;  // how long the break lasts

  const BreakInterval({
    required this.afterMinutes,
    required this.breakMinutes,
  });
}

// ─── SessionLog (persisted to Hive) ──────────────────────────────────────────

@HiveType(typeId: 2)
class SessionLog extends Equatable {
  static const _noValue = Object();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionName;

  @HiveField(2)
  final FocusType focusType;

  @HiveField(3)
  final int plannedMinutes;

  @HiveField(4)
  final int actualFocusMinutes;

  @HiveField(5)
  final int breaksCompleted;

  @HiveField(6)
  final int rating; // 0 = unrated, 1–5 = user rating

  @HiveField(7)
  final DateTime date;

  const SessionLog({
    required this.id,
    required this.sessionName,
    required this.focusType,
    required this.plannedMinutes,
    required this.actualFocusMinutes,
    required this.breaksCompleted,
    required this.rating,
    required this.date,
  });

  SessionLog copyWith({
    Object? rating = _noValue,
  }) {
    return SessionLog(
      id: id,
      sessionName: sessionName,
      focusType: focusType,
      plannedMinutes: plannedMinutes,
      actualFocusMinutes: actualFocusMinutes,
      breaksCompleted: breaksCompleted,
      rating: identical(rating, _noValue) ? this.rating : rating as int,
      date: date,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sessionName,
    focusType,
    plannedMinutes,
    actualFocusMinutes,
    breaksCompleted,
    rating,
    date,
  ];
}

// ─── Smart Break Calculator ───────────────────────────────────────────────────

List<BreakInterval> calculateBreaks(int totalMinutes, FocusType type) {
  double multiplier = 1.0;
  if (type == FocusType.creative) multiplier = 0.9;
  if (type == FocusType.deepWork) multiplier = 1.1;

  if (totalMinutes < 30) return [];

  final List<BreakInterval> breaks = [];

  if (totalMinutes <= 60) {
    breaks.add(BreakInterval(
      afterMinutes: (totalMinutes / 2 * multiplier).round(),
      breakMinutes: 5,
    ));
  } else if (totalMinutes <= 120) {
    int focusBlock = (45 * multiplier).round();
    int t = focusBlock;
    while (t < totalMinutes) {
      breaks.add(BreakInterval(afterMinutes: t, breakMinutes: 10));
      t += focusBlock + 10;
    }
  } else if (totalMinutes <= 180) {
    int focusBlock = (50 * multiplier).round();
    int t = focusBlock;
    while (t < totalMinutes) {
      breaks.add(BreakInterval(afterMinutes: t, breakMinutes: 15));
      t += focusBlock + 15;
    }
  } else {
    int focusBlock = (60 * multiplier).round();
    int t = focusBlock;
    while (t < totalMinutes) {
      breaks.add(BreakInterval(afterMinutes: t, breakMinutes: 20));
      t += focusBlock + 20;
    }
  }

  return breaks;
}