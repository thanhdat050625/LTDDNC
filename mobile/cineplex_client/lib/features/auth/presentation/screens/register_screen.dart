import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/auth/presentation/widgets/otp_input_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  String _email = '';
  String _otp = '';
  String _password = '';
  String _confirmPassword = '';

  void _nextStep() {
    if (_currentStep < 2) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: _prevStep,
        ),
        title: Text(l10n.register, style: TextStyle(color: colors.textPrimary)),
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
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is AuthOtpSent) {
              if (_currentStep == 0) _nextStep();
            } else if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.registerSuccess)));
              context.go('/home');
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 3,
                      backgroundColor: colors.textSecondary.withValues(alpha: 0.2),
                      color: colors.primary,
                      minHeight: 6,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: () {
                            switch (_currentStep) {
                              case 0:
                                return _buildStep1(l10n, colors, state is AuthLoading);
                              case 1:
                                return _buildStep2(l10n, colors);
                              case 2:
                              default:
                                return _buildStep3(l10n, colors, state is AuthLoading);
                            }
                          }(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l10n, CineplexColors colors, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.email,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 16),
        AppTextField(
          hintText: l10n.email,
          onChanged: (val) => _email = val,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        AppButton(
          text: l10n.sendOtp,
          isLoading: isLoading,
          onPressed: () {
            if (_email.trim().isNotEmpty) {
              context.read<AuthBloc>().add(SendOtpRequested(_email.trim(), 'REGISTER'));
            }
          },
        ),
      ],
    );
  }

  Widget _buildStep2(AppLocalizations l10n, CineplexColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.otpVerify,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          "${l10n.otpSent} $_email",
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        OtpInputWidget(onCompleted: (val) => _otp = val),
        const SizedBox(height: 24),
        AppButton(text: l10n.confirm, onPressed: _nextStep),
      ],
    );
  }

  Widget _buildStep3(AppLocalizations l10n, CineplexColors colors, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.password,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 16),
        AppTextField(
          hintText: l10n.password,
          obscureText: true,
          onChanged: (val) => _password = val,
        ),
        const SizedBox(height: 12),
        AppTextField(
          hintText: l10n.confirmPassword,
          obscureText: true,
          onChanged: (val) => _confirmPassword = val,
        ),
        const SizedBox(height: 20),
        AppButton(
          text: l10n.register,
          isLoading: isLoading,
          onPressed: () {
            if (_otp.isNotEmpty && _password.isNotEmpty && _password == _confirmPassword) {
              context.read<AuthBloc>().add(RegisterRequested(_email.trim(), _otp, _password, _confirmPassword));
            } else if (_password != _confirmPassword) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordMismatch)));
            }
          },
        ),
      ],
    );
  }
}
