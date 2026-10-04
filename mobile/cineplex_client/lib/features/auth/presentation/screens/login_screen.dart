import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
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
    final colors = CineplexColors.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              l10n.skip,
              style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Icon & Title Badge
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.movie_filter_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.appTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      l10n.login,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Inputs Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.textSecondary.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _emailCtrl,
                          hintText: l10n.email,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 14),
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
                            Flexible(
                              child: InkWell(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                        activeColor: colors.primary,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        l10n.rememberMe,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13, color: colors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => context.push('/forgot-password'),
                              child: Text(
                                l10n.forgotPassword,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.isDark ? colors.secondary : colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                      _emailCtrl.text.trim(),
                                      _passCtrl.text,
                                      rememberMe: _rememberMe,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.noAccount,
                        style: TextStyle(color: colors.textSecondary, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          l10n.register,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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

