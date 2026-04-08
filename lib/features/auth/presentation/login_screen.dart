import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/presentation/screens/app_theme.dart';

import '../../settings/cubit/theme_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onGoToSignup;
  const LoginScreen({super.key, required this.onGoToSignup});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    'Welcome\nback 👋',
                    style: TextStyle(
                      color: AppTheme.getPrimaryText(isDark),
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to sync your tasks across devices',
                    style: TextStyle(
                        color: AppTheme.getMutedText(isDark), fontSize: 14),
                  ),

                  const SizedBox(height: 40),

                  GoogleButton(
                    onTap: _isLoading
                        ? null
                        : () => context
                        .read<AuthBloc>()
                        .add(const AuthGoogleSignInRequested()),
                  ),

                  const SizedBox(height: 24),
                  const OrDivider(),
                  const SizedBox(height: 24),

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

                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPassword(context),
                      child: const Text('Forgot password?',
                          style: TextStyle(
                              color: AppTheme.accent, fontSize: 13)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accent))
                      : PrimaryButton(
                    label: 'Sign In',
                    onTap: () {
                      final email =
                      _emailController.text.trim();
                      final password =
                      _passwordController.text.trim();
                      if (email.isEmpty || password.isEmpty) {
                        _showError('Please fill in all fields.');
                        return;
                      }
                      context.read<AuthBloc>().add(
                          AuthEmailSignInRequested(
                              email: email,
                              password: password));
                    },
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: TextStyle(
                              color: AppTheme.getMutedText(isDark),
                              fontSize: 14)),
                      GestureDetector(
                        onTap: widget.onGoToSignup,
                        child: const Text('Sign Up',
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

  void _showForgotPassword(BuildContext ctx) {
    final isDark = ctx.read<SettingsCubit>().state.settings.isDarkMode;
    final controller = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Reset Password',
                  style: TextStyle(
                      color: AppTheme.getPrimaryText(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("We'll send a reset link to your email.",
                  style: TextStyle(
                      color: AppTheme.getMutedText(isDark), fontSize: 13)),
              const SizedBox(height: 20),
              AuthField(
                controller: controller,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final email = controller.text.trim();
                    if (email.isNotEmpty) {
                      Navigator.pop(ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentDim,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Send Reset Link',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}