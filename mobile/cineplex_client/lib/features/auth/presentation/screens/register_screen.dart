import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineplex_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cineplex_client/l10n/app_localizations.dart';
import 'package:cineplex_client/core/widgets/app_button.dart';
import 'package:cineplex_client/core/widgets/app_text_field.dart';
import 'package:cineplex_client/core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent, // Let gradient show through
      extendBodyBehindAppBar: true, // Make gradient go behind appbar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep),
        title: Text(l10n.register),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text(
              'Bỏ qua', // TODO: L10n
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
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AuthOtpSent) {
                if (_currentStep == 0) _nextStep();
              } else if (state is AuthAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
                context.go('/home');
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
          Text(l10n.email, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          AppTextField(
            hintText: l10n.email,
            onChanged: (val) => _email = val,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 32),
          AppButton(
            text: l10n.sendOtp,
            isLoading: isLoading,
            onPressed: () {
              if (_email.isNotEmpty) {
                context.read<AuthBloc>().add(SendOtpRequested(_email, 'REGISTER'));
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
          const SizedBox(height: 8),
          Text("${l10n.otpSent} $_email", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
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
          Text(l10n.password, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          AppTextField(
            hintText: l10n.password,
            obscureText: true,
            onChanged: (val) => _password = val,
          ),
          const SizedBox(height: 16),
          AppTextField(
            hintText: l10n.confirmPassword,
            obscureText: true,
            onChanged: (val) => _confirmPassword = val,
          ),
          const SizedBox(height: 32),
          AppButton(
            text: l10n.register,
            isLoading: isLoading,
            onPressed: () {
              if (_otp.isNotEmpty && _password.isNotEmpty && _password == _confirmPassword) {
                context.read<AuthBloc>().add(RegisterRequested(_email, _otp, _password, _confirmPassword));
              } else if (_password != _confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu không khớp')));
              }
            },
          ),
        ],
      ),
    );
  }
}
