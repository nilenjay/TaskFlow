import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:todo_app/core/notifications/notification_service.dart';
import 'package:todo_app/features/focus/data/datasourses/focus_local_datasourse.dart';
import 'package:todo_app/features/focus/data/models/focus_model.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_event.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_state.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  final FocusLocalDataSource _localDataSource;

  Timer? _ticker;

  List<BreakInterval> _breaks = [];
  int _focusElapsedSeconds = 0;

  FocusBloc(this._localDataSource) : super(const FocusInitial()) {
    on<LoadSessions>(_loadSessions);
    on<StartSession>(_startSession);
    on<TimerTicked>(_timerTicked);
    on<PauseSession>(_pauseSession);
    on<ResumeSession>(_resumeSession);
    on<EndSession>(_endSession);
    on<ResetSession>(_resetSession);
    on<RateSession>(_rateSession);
    on<SkipBreak>(_skipBreak);

    add(const LoadSessions());
  }


  Future<void> _loadSessions(
      LoadSessions event, Emitter<FocusState> emit) async {
    final sessions = await _localDataSource.loadSessions();
    emit(FocusInitial(sessions: sessions));
  }


  Future<void> _startSession(
      StartSession event, Emitter<FocusState> emit) async {
    _cancelTicker();
    _focusElapsedSeconds = 0;
    _breaks = calculateBreaks(event.durationMinutes, event.focusType);

    final totalSeconds = event.durationMinutes * 60;
    final firstPhaseSeconds = _breaks.isNotEmpty
        ? _breaks[0].afterMinutes * 60
        : totalSeconds;

    emit(FocusRunning(
      sessionName: event.sessionName,
      focusType: event.focusType,
      totalSeconds: totalSeconds,
      elapsedSeconds: 0,
      phaseSecondsLeft: firstPhaseSeconds,
      phase: SessionPhase.focus,
      currentBreakIndex: 0,
      totalBreaks: _breaks.length,
      isPaused: false,
    ));

    _startTicker();
  }


  Future<void> _timerTicked(
      TimerTicked event, Emitter<FocusState> emit) async {
    if (state is! FocusRunning) return;
    final current = state as FocusRunning;
    if (current.isPaused) return;

    final newElapsed = current.elapsedSeconds + 1;
    final newPhaseLeft = current.phaseSecondsLeft - 1;

    if (current.phase == SessionPhase.focus) {
      _focusElapsedSeconds++;
    }

    if (newElapsed >= current.totalSeconds) {
      _cancelTicker();
      await _completeSession(current, emit);
      return;
    }

    if (newPhaseLeft <= 0) {
      if (current.phase == SessionPhase.focus) {
        final breakDuration =
            _breaks[current.currentBreakIndex].breakMinutes * 60;

        await NotificationService.instance.scheduleNotification(
          id: 0,
          title: '☕ Break Time!',
          body:
          'Take a ${_breaks[current.currentBreakIndex].breakMinutes}-min break. You earned it.',
          scheduledTime: DateTime.now(),
        );

        emit(current.copyWith(
          elapsedSeconds: newElapsed,
          phaseSecondsLeft: breakDuration,
          phase: SessionPhase.breakTime,
        ));
      } else {
        await _transitionToFocus(current, newElapsed, emit);
      }
      return;
    }

    emit(current.copyWith(
      elapsedSeconds: newElapsed,
      phaseSecondsLeft: newPhaseLeft,
    ));
  }


  Future<void> _skipBreak(SkipBreak event, Emitter<FocusState> emit) async {
    if (state is! FocusRunning) return;
    final current = state as FocusRunning;
    if (current.phase != SessionPhase.breakTime) return;

    await NotificationService.instance.scheduleNotification(
      id: 1,
      title: '🎯 Back to Focus!',
      body: 'Break skipped — let\'s keep going.',
      scheduledTime: DateTime.now(),
    );

    await _transitionToFocus(current, current.elapsedSeconds, emit);
  }


  Future<void> _transitionToFocus(
      FocusRunning current, int newElapsed, Emitter<FocusState> emit) async {
    final nextBreakIndex = current.currentBreakIndex + 1;
    final remainingSeconds = current.totalSeconds - newElapsed;

    final nextFocusSeconds = nextBreakIndex < _breaks.length
        ? (_breaks[nextBreakIndex].afterMinutes -
        _breaks[current.currentBreakIndex].afterMinutes) *
        60
        : remainingSeconds;

    await NotificationService.instance.scheduleNotification(
      id: 1,
      title: '🎯 Back to Focus!',
      body: 'Break\'s over — let\'s get back to it.',
      scheduledTime: DateTime.now(),
    );

    emit(current.copyWith(
      elapsedSeconds: newElapsed,
      phaseSecondsLeft: nextFocusSeconds.clamp(0, remainingSeconds),
      phase: SessionPhase.focus,
      currentBreakIndex: nextBreakIndex,
    ));
  }


  Future<void> _pauseSession(
      PauseSession event, Emitter<FocusState> emit) async {
    if (state is! FocusRunning) return;
    _cancelTicker();
    emit((state as FocusRunning).copyWith(isPaused: true));
  }

  Future<void> _resumeSession(
      ResumeSession event, Emitter<FocusState> emit) async {
    if (state is! FocusRunning) return;
    emit((state as FocusRunning).copyWith(isPaused: false));
    _startTicker();
  }


  Future<void> _endSession(
      EndSession event, Emitter<FocusState> emit) async {
    if (state is! FocusRunning) return;
    _cancelTicker();
    await _completeSession(state as FocusRunning, emit);
  }


  Future<void> _resetSession(
      ResetSession event, Emitter<FocusState> emit) async {
    _cancelTicker();
    _focusElapsedSeconds = 0;
    _breaks = [];

    List<SessionLog> sessions = [];
    if (state is FocusInitial) {
      sessions = (state as FocusInitial).sessions;
    } else if (state is FocusCompleted) {
      sessions = (state as FocusCompleted).sessions;
    }

    emit(FocusInitial(sessions: sessions));
  }


  Future<void> _rateSession(
      RateSession event, Emitter<FocusState> emit) async {
    if (state is! FocusCompleted) return;
    final current = state as FocusCompleted;

    final updatedSession = current.session.copyWith(rating: event.rating);
    final updatedSessions = current.sessions.map((s) {
      return s.id == updatedSession.id ? updatedSession : s;
    }).toList();

    await _localDataSource.saveSessions(updatedSessions);

    emit(FocusCompleted(
      session: updatedSession,
      sessions: updatedSessions,
    ));
  }


  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTicked());
    });
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _completeSession(
      FocusRunning current, Emitter<FocusState> emit) async {
    List<SessionLog> existingSessions = [];
    if (state is FocusInitial) {
      existingSessions = (state as FocusInitial).sessions;
    }

    final breaksCompleted = current.phase == SessionPhase.breakTime
        ? current.currentBreakIndex + 1
        : current.currentBreakIndex;

    final newSession = SessionLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionName: current.sessionName,
      focusType: current.focusType,
      plannedMinutes: current.totalSeconds ~/ 60,
      actualFocusMinutes: _focusElapsedSeconds ~/ 60,
      breaksCompleted: breaksCompleted,
      rating: 0,
      date: DateTime.now(),
    );

    final updatedSessions = [...existingSessions, newSession];
    await _localDataSource.saveSessions(updatedSessions);

    final completionPct =
    (current.elapsedSeconds / current.totalSeconds).clamp(0.0, 1.0);

    await NotificationService.instance.scheduleNotification(
      id: 2,
      title:
      completionPct >= 1.0 ? '🎉 Session Complete!' : '⏹ Session Ended',
      body: completionPct >= 1.0
          ? 'Great work on "${current.sessionName}"!'
          : 'You focused for ${_focusElapsedSeconds ~/ 60} min on "${current.sessionName}".',
      scheduledTime: DateTime.now(),
    );

    emit(FocusCompleted(
      session: newSession,
      sessions: updatedSessions,
    ));
  }

  @override
  Future<void> close() {
    _cancelTicker();
    return super.close();
  }
}