import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/repositories/profile_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    setState(() {
      _errorMessage = null;
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = context.read<ProfileRepository>();
      await repo.changePassword(
        _oldPasswordCtrl.text,
        _newPasswordCtrl.text,
        _confirmPasswordCtrl.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.changePasswordSuccess),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e is AppException ? e.message : e.toString();
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    return AppScaffold(
      title: l10n.changePassword,
      bottomSafeArea: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: colors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.changePasswordDescription,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Banner
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Password Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadowColor,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Old Password
                        AppTextField(
                          label: l10n.oldPassword,
                          hint: l10n.oldPassword,
                          controller: _oldPasswordCtrl,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return l10n.oldPasswordRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // New Password
                        AppTextField(
                          label: l10n.newPassword,
                          hint: l10n.newPassword,
                          controller: _newPasswordCtrl,
                          obscureText: true,
                          prefixIcon: Icons.lock_reset,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return l10n.newPasswordRequired;
                            }
                            if (val.length < 6) {
                              return l10n.passwordMinLength;
                            }
                            if (val == _oldPasswordCtrl.text && _oldPasswordCtrl.text.isNotEmpty) {
                              return l10n.newPasswordSameAsOld;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm New Password
                        AppTextField(
                          label: l10n.confirmPassword,
                          hint: l10n.confirmPassword,
                          controller: _confirmPasswordCtrl,
                          obscureText: true,
                          prefixIcon: Icons.check_circle_outline,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return l10n.confirmPasswordRequired;
                            }
                            if (val != _newPasswordCtrl.text) {
                              return l10n.passwordMismatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        AppButton(
                          text: l10n.changePassword,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : () => _submit(l10n),
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
  }
}
