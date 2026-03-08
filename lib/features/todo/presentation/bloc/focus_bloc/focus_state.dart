import 'package:equatable/equatable.dart';
import '../../../data/models/focus_model.dart';

abstract class FocusState extends Equatable {
  const FocusState();

  @override
  List<Object?> get props => [];
}

// ─── Initial (setup screen) ───────────────────────────────────────────────────

class FocusInitial extends FocusState {
  final List<SessionLog> sessions;

  const FocusInitial({this.sessions = const []});

  @override
  List<Object?> get props => [sessions];
}

// ─── Running (active timer screen) ───────────────────────────────────────────

class FocusRunning extends FocusState {
  final String sessionName;
  final FocusType focusType;
  final int totalSeconds;
  final int elapsedSeconds;
  final int phaseSecondsLeft;
  final SessionPhase phase;
  final int currentBreakIndex;
  final int totalBreaks;
  final bool isPaused;

  const FocusRunning({
    required this.sessionName,
    required this.focusType,
    required this.totalSeconds,
    required this.elapsedSeconds,
    required this.phaseSecondsLeft,
    required this.phase,
    required this.currentBreakIndex,
    required this.totalBreaks,
    required this.isPaused,
  });

  FocusRunning copyWith({
    int? elapsedSeconds,
    int? phaseSecondsLeft,
    SessionPhase? phase,
    int? currentBreakIndex,
    bool? isPaused,
  }) {
    return FocusRunning(
      sessionName: sessionName,
      focusType: focusType,
      totalSeconds: totalSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      phaseSecondsLeft: phaseSecondsLeft ?? this.phaseSecondsLeft,
      phase: phase ?? this.phase,
      currentBreakIndex: currentBreakIndex ?? this.currentBreakIndex,
      totalBreaks: totalBreaks,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  List<Object?> get props => [
    sessionName,
    focusType,
    totalSeconds,
    elapsedSeconds,
    phaseSecondsLeft,
    phase,
    currentBreakIndex,
    totalBreaks,
    isPaused,
  ];
}

// ─── Completed (summary screen) ───────────────────────────────────────────────

class FocusCompleted extends FocusState {
  final SessionLog session;
  final List<SessionLog> sessions;

  const FocusCompleted({
    required this.session,
    required this.sessions,
  });

  @override
  List<Object?> get props => [session, sessions];
}