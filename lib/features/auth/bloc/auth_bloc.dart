import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../data/service/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  late final StreamSubscription<User?> _authSubscription;

  AuthBloc(this._authService) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthEmailSignInRequested>(_onEmailSignIn);
    on<AuthEmailSignUpRequested>(_onEmailSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUserChanged>(_onUserChanged);

    _authSubscription = _authService.authStateChanges.listen(
          (user) => add(AuthUserChanged(user)),
    );
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
  }

  void _onUserChanged(
      AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null) emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailSignIn(
      AuthEmailSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.signInWithEmail(
          email: event.email, password: event.password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailSignUp(
      AuthEmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.signUpWithEmail(
          email: event.email,
          password: event.password,
          name: event.name);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}