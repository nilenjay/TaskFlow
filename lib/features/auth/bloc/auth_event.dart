import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEmailSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthEmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthEmailSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Internal — fired by Firebase auth state stream
class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}