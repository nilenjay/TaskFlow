import 'package:flutter/material.dart';
import '../presentation/login_screen.dart';
import '../presentation/signup_screen.dart';

/// Switches between LoginScreen and SignupScreen without a Navigator push,
/// so the gradient background stays consistent and there's no page transition flash.
class AuthRouter extends StatefulWidget {
  const AuthRouter({super.key});

  @override
  State<AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: _showLogin
          ? LoginScreen(
        key: const ValueKey('login'),
        onGoToSignup: () =>
            setState(() => _showLogin = false),
      )
          : SignupScreen(
        key: const ValueKey('signup'),
        onGoToLogin: () =>
            setState(() => _showLogin = true),
      ),
    );
  }
}