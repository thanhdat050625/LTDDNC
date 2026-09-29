import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineplex_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:cineplex_mobile/core/widgets/app_button.dart';
import 'package:cineplex_mobile/core/widgets/app_text_field.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';
import 'package:cineplex_mobile/features/auth/presentation/widgets/otp_input_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  String _email = '';
  String _otp = '';
  String _newPassword = '';
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
    return Scaffold(
      backgroundColor: Colors.transparent, // Let gradient show through
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep),
        title: Text(l10n.forgotPassword),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.cinematicGradient,
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AuthOtpSent) {
                if (_currentStep == 0) _nextStep();
              } else if (state is AuthPasswordReset) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
                context.pop();
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  LinearProgressIndicator(value: (_currentStep + 1) / 3, backgroundColor: AppColors.darkSurface, color: AppColors.primary),
                  Expanded(
                    child: PageView(
                      controller: _pageCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(l10n, state is AuthLoading),
                        _buildStep2(l10n),
                        _buildStep3(l10n, state is AuthLoading),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l10n, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.forgotPassword, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          AppTextField(hintText: l10n.email, onChanged: (val) => _email = val),
          const SizedBox(height: 32),
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
      ),
    );
  }

  Widget _buildStep2(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.otpVerify, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          OtpInputWidget(onCompleted: (val) => _otp = val),
          const SizedBox(height: 32),
          AppButton(text: l10n.confirm, onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep3(AppLocalizations l10n, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppTextField(hintText: l10n.newPassword, obscureText: true, onChanged: (val) => _newPassword = val),
          const SizedBox(height: 16),
          AppTextField(hintText: l10n.confirmPassword, obscureText: true, onChanged: (val) => _confirmPassword = val),
          const SizedBox(height: 32),
          AppButton(
            text: l10n.confirm,
            isLoading: isLoading,
            onPressed: () {
              if (_otp.isNotEmpty && _newPassword.isNotEmpty && _newPassword == _confirmPassword) {
                context.read<AuthBloc>().add(ForgotPasswordRequested(_email, _otp, _newPassword, _confirmPassword));
              } else if (_newPassword != _confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu không khớp')));
              }
            },
          ),
        ],
      ),
    );
  }
}
