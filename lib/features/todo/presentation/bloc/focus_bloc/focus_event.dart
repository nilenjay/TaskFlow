import 'package:equatable/equatable.dart';
import '../../../data/models/focus_model.dart';

abstract class FocusEvent extends Equatable {
  const FocusEvent();

  @override
  List<Object?> get props => [];
}

// ─── Session lifecycle ────────────────────────────────────────────────────────

class StartSession extends FocusEvent {
  final String sessionName;
  final int durationMinutes;
  final FocusType focusType;

  const StartSession({
    required this.sessionName,
    required this.durationMinutes,
    required this.focusType,
  });

  @override
  List<Object?> get props => [sessionName, durationMinutes, focusType];
}

class PauseSession extends FocusEvent {
  const PauseSession();
}

class ResumeSession extends FocusEvent {
  const ResumeSession();
}

class EndSession extends FocusEvent {
  const EndSession();
}

class ResetSession extends FocusEvent {
  const ResetSession();
}

// ─── Timer tick (internal — fired by Bloc's own periodic Timer) ───────────────

class TimerTicked extends FocusEvent {
  const TimerTicked();
}

// ─── Post-session ─────────────────────────────────────────────────────────────

class RateSession extends FocusEvent {
  final int rating; // 1–5

  const RateSession({required this.rating});

  @override
  List<Object?> get props => [rating];
}

// ─── History ──────────────────────────────────────────────────────────────────

class LoadSessions extends FocusEvent {
  const LoadSessions();
}