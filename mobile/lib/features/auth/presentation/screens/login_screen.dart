import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:cineplex_mobile/core/widgets/app_button.dart';
import 'package:cineplex_mobile/core/widgets/app_text_field.dart';
import 'package:cineplex_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Let gradient show through
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text(
              'Bỏ qua', // TODO: Move to L10n later
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.cinematicGradient,
        ),
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'CINEPLEX',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              AppTextField(
                controller: _emailCtrl,
                hintText: l10n.email,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passCtrl,
                hintText: l10n.password,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                        activeColor: AppColors.primary,
                      ),
                      Text(l10n.rememberMe, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                    child: Text(l10n.forgotPassword, style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return AppButton(
                    isLoading: state is AuthLoading,
                    text: l10n.login,
                    onPressed: () {
                      if (_emailCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty) {
                        context.read<AuthBloc>().add(
                          LoginRequested(
                            _emailCtrl.text,
                            _passCtrl.text,
                            rememberMe: _rememberMe,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noAccount, style: theme.textTheme.bodyMedium),
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    child: Text(l10n.register, style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
