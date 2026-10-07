import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/auth/presentation/widgets/otp_input_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0;
  String _email = '';
  String _otp = '';
  String _newPassword = '';
  String _confirmPassword = '';

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
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
        title: Text(
          l10n.forgotPassword,
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is AuthOtpSent) {
                    if (_currentStep == 0) _nextStep();
                  } else if (state is AuthPasswordReset) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.resetPasswordSuccess)),
                    );
                    context.pop();
                  }
                },
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Step Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / 3,
                          backgroundColor: colors.surfaceVariant,
                          color: colors.primary,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Step Content in Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadowColor,
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _currentStep == 0
                              ? _buildStep1(l10n, colors, state is AuthLoading)
                              : _currentStep == 1
                                  ? _buildStep2(l10n, colors)
                                  : _buildStep3(l10n, colors, state is AuthLoading),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l10n, CineplexColors colors, bool isLoading) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.forgotPassword,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.email,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        AppTextField(
          hintText: l10n.email,
          prefixIcon: Icons.email_outlined,
          onChanged: (val) => _email = val,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: l10n.sendOtp,
          isLoading: isLoading,
          onPressed: () {
            if (_email.isNotEmpty) {
              context.read<AuthBloc>().add(SendOtpRequested(_email, 'FORGOT_PASSWORD'));
            }
          },
        ),
      ],
    );
  }

  Widget _buildStep2(AppLocalizations l10n, CineplexColors colors) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.otpVerify,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.otpSent,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        OtpInputWidget(onCompleted: (val) => _otp = val),
        const SizedBox(height: 24),
        AppButton(
          text: l10n.confirm,
          onPressed: () {
            if (_otp.isNotEmpty) _nextStep();
          },
        ),
      ],
    );
  }

  Widget _buildStep3(AppLocalizations l10n, CineplexColors colors, bool isLoading) {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.newPassword,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        AppTextField(
          hintText: l10n.newPassword,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          onChanged: (val) => _newPassword = val,
        ),
        const SizedBox(height: 16),
        AppTextField(
          hintText: l10n.confirmPassword,
          prefixIcon: Icons.lock_reset,
          obscureText: true,
          onChanged: (val) => _confirmPassword = val,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: l10n.confirm,
          isLoading: isLoading,
          onPressed: () {
            if (_otp.isNotEmpty && _newPassword.isNotEmpty && _newPassword == _confirmPassword) {
              context.read<AuthBloc>().add(ForgotPasswordRequested(_email, _otp, _newPassword, _confirmPassword));
            } else if (_newPassword != _confirmPassword) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordMismatch)));
            }
          },
        ),
      ],
    );
  }
}
