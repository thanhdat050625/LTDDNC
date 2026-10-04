import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            final role = state.user.role.toUpperCase();
            if (role != 'ADMIN') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.accessDenied),
                  backgroundColor: colors.error,
                ),
              );
              context.read<AuthBloc>().add(LogoutRequested());
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cinema Brand Header
                        Center(
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 68,
                            height: 68,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.adminLoginTitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.adminLoginSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Form Container Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadowColor.withValues(
                                  alpha: 0.04,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email Field
                              AppTextField(
                                controller: _emailController,
                                label: l10n.email,
                                hintText: l10n.email,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.emailRequired;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Password Field
                              AppTextField(
                                controller: _passwordController,
                                label: l10n.password,
                                hintText: l10n.password,
                                obscureText: true,
                                prefixIcon: Icons.lock_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.passwordRequired;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              // Remember Me
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: colors.primary,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.rememberMe,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Submit Button
                              AppButton(
                                text: l10n.login,
                                isLoading: isLoading,
                                onPressed: _onLogin,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
