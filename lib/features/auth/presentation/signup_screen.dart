import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/presentation/screens/app_theme.dart';

import '../../settings/cubit/theme_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onGoToLogin;
  const SignupScreen({super.key, required this.onGoToLogin});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color(0xFF1E2240),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      content: Text(message,
          style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsCubit>().state.settings.isDarkMode;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        setState(() => _isLoading = state is AuthLoading);
        if (state is AuthError) _showError(state.message);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundDecoration(isDark),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  const TaskFlowLogo(),

                  const SizedBox(height: 36),

                  Text(
                    'Create\naccount ✨',
                    style: TextStyle(
                      color: AppTheme.getPrimaryText(isDark),
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start syncing your tasks across all devices',
                    style: TextStyle(
                        color: AppTheme.getMutedText(isDark), fontSize: 14),
                  ),

                  const SizedBox(height: 36),

                  GoogleButton(
                    label: 'Sign up with Google',
                    onTap: _isLoading
                        ? null
                        : () => context
                        .read<AuthBloc>()
                        .add(const AuthGoogleSignInRequested()),
                  ),

                  const SizedBox(height: 20),
                  const OrDivider(),
                  const SizedBox(height: 20),

                  AuthField(
                    controller: _nameController,
                    hint: 'Full name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),

                  AuthField(
                    controller: _emailController,
                    hint: 'Email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  AuthField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.getMutedText(isDark),
                        size: 20,
                      ),
                      onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 12),

                  AuthField(
                    controller: _confirmController,
                    hint: 'Confirm password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.getMutedText(isDark),
                        size: 20,
                      ),
                      onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),

                  const SizedBox(height: 28),

                  _isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accent))
                      : PrimaryButton(
                    label: 'Create Account',
                    onTap: () {
                      final name =
                      _nameController.text.trim();
                      final email =
                      _emailController.text.trim();
                      final password =
                      _passwordController.text.trim();
                      final confirm =
                      _confirmController.text.trim();

                      if (name.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty) {
                        _showError('Please fill in all fields.');
                        return;
                      }
                      if (password != confirm) {
                        _showError('Passwords do not match.');
                        return;
                      }
                      if (password.length < 6) {
                        _showError(
                            'Password must be at least 6 characters.');
                        return;
                      }
                      context.read<AuthBloc>().add(
                          AuthEmailSignUpRequested(
                              email: email,
                              password: password,
                              name: name));
                    },
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: TextStyle(
                              color: AppTheme.getMutedText(isDark),
                              fontSize: 14)),
                      GestureDetector(
                        onTap: widget.onGoToLogin,
                        child: const Text('Sign In',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}