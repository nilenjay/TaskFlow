import 'package:equatable/equatable.dart';
import 'package:todo_app/features/focus/data/models/focus_model.dart';

abstract class FocusEvent extends Equatable {
  const FocusEvent();

  @override
  List<Object?> get props => [];
}


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

/// Skips the current break and immediately returns to focus phase.
class SkipBreak extends FocusEvent {
  const SkipBreak();
}


class TimerTicked extends FocusEvent {
  const TimerTicked();
}


class RateSession extends FocusEvent {
  final int rating; // 1–5

  const RateSession({required this.rating});

  @override
  List<Object?> get props => [rating];
}


class LoadSessions extends FocusEvent {
  const LoadSessions();
}