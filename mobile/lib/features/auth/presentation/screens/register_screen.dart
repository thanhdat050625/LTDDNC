import 'package:flutter/material.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:cineplex_mobile/core/widgets/app_button.dart';
import 'package:cineplex_mobile/core/widgets/app_text_field.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';
import 'package:cineplex_mobile/features/auth/presentation/widgets/otp_input_widget.dart';

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
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep),
        title: Text(l10n.register),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentStep + 1) / 3, backgroundColor: AppColors.darkSurface, color: AppColors.primary),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(l10n),
                  _buildStep2(l10n),
                  _buildStep3(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l10n) {
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
          AppButton(text: l10n.sendOtp, onPressed: _nextStep),
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

  Widget _buildStep3(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.password, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          AppTextField(hintText: l10n.password, obscureText: true),
          const SizedBox(height: 16),
          AppTextField(hintText: l10n.confirmPassword, obscureText: true),
          const SizedBox(height: 32),
          AppButton(text: l10n.register, onPressed: () {
            if (_otp.isNotEmpty) {}
          }),
        ],
      ),
    );
  }
}
