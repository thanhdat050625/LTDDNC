import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/user_management_cubit.dart';

class CreateStaffBottomSheet extends StatefulWidget {
  final UserModel? staff;

  const CreateStaffBottomSheet({super.key, this.staff});

  static Future<bool?> show(BuildContext context, {UserModel? staff}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<UserManagementCubit>(),
        child: CreateStaffBottomSheet(staff: staff),
      ),
    );
  }

  @override
  State<CreateStaffBottomSheet> createState() => _CreateStaffBottomSheetState();
}

class _CreateStaffBottomSheetState extends State<CreateStaffBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _avatarFile;
  String? _currentAvatarUrl;
  List<CinemaModel> _cinemas = [];
  int? _selectedCinemaId;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEdit => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.staff?.fullName ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _phoneController = TextEditingController(text: widget.staff?.phone ?? '');
    _currentAvatarUrl = widget.staff?.avatar;
    _selectedCinemaId = widget.staff?.cinemaId;
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    try {
      final cinemas = await context.read<UserManagementCubit>().repository.getCinemas();
      if (mounted) {
        setState(() {
          _cinemas = cinemas;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = CineplexColors.of(ctx);
        final l10n = AppLocalizations.of(ctx)!;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(LucideIcons.camera, color: theme.primary),
                  title: Text(l10n.takePhoto, style: TextStyle(color: theme.textPrimary)),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(LucideIcons.image, color: theme.primary),
                  title: Text(l10n.chooseFromGallery, style: TextStyle(color: theme.textPrimary)),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked != null && mounted) {
        setState(() {
          _avatarFile = File(picked.path);
        });
      }
    } catch (_) {}
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cubit = context.read<UserManagementCubit>();
    final bool success;

    if (_isEdit) {
      success = await cubit.updateStaff(
        staffId: widget.staff!.id,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        avatarFilePath: _avatarFile?.path,
        cinemaId: _selectedCinemaId,
      );
    } else {
      success = await cubit.createStaff(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        avatarFilePath: _avatarFile?.path,
        cinemaId: _selectedCinemaId,
      );
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = l10n.errorOccurred;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 14 + bottomInset),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: theme.textSecondary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A86FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isEdit ? LucideIcons.pencil : LucideIcons.userPlus,
                      color: const Color(0xFF3A86FF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit ? l10n.editStaffTitle : l10n.createStaffTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          _isEdit ? l10n.editStaffSubtitle : l10n.createStaffSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(LucideIcons.x, color: theme.textSecondary, size: 20),
                    tooltip: l10n.close,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Avatar picker
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.surface,
                        border: Border.all(
                          color: theme.primary,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _avatarFile != null
                            ? Image.file(
                                _avatarFile!,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              )
                            : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                ? AppCachedImage(
                                    imageUrl: _currentAvatarUrl!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    LucideIcons.user,
                                    size: 36,
                                    color: theme.textSecondary.withValues(alpha: 0.5),
                                  )),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: theme.primary,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _pickAvatar,
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              LucideIcons.camera,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Error display if any
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle, size: 16, color: theme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 12, color: theme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Full Name
              AppTextField(
                controller: _fullNameController,
                label: l10n.fullNameLabel,
                hint: l10n.fullNameLabel,
                prefixIcon: LucideIcons.user,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Email
              AppTextField(
                controller: _emailController,
                label: l10n.emailLabel,
                hint: l10n.emailPlaceholder,
                prefixIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fieldRequired;
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(val.trim())) {
                    return l10n.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Phone
              AppTextField(
                controller: _phoneController,
                label: l10n.phoneLabel,
                hint: l10n.phonePlaceholder,
                prefixIcon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),

              // Branch / Cinema Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedCinemaId,
                isExpanded: true,
                dropdownColor: theme.surface,
                style: TextStyle(color: theme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: l10n.staffBranch,
                  hintText: l10n.selectStaffBranch,
                  labelStyle: TextStyle(color: theme.textSecondary, fontSize: 14),
                  hintStyle: TextStyle(color: theme.textSecondary.withValues(alpha: 0.6), fontSize: 14),
                  prefixIcon: Icon(LucideIcons.mapPin, size: 20, color: theme.textSecondary),
                  filled: true,
                  fillColor: theme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                items: [
                  ..._cinemas.map((c) => DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.textPrimary),
                    ),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedCinemaId = val),
              ),
              const SizedBox(height: 8),

              // Password
              AppTextField(
                controller: _passwordController,
                label: l10n.passwordLabel,
                hint: _isEdit ? l10n.optionalPasswordHint : l10n.passwordPlaceholder,
                prefixIcon: LucideIcons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: theme.textSecondary,
                    size: 20,
                  ),
                  tooltip: l10n.togglePasswordVisibility,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (val) {
                  if (!_isEdit && (val == null || val.isEmpty)) return l10n.fieldRequired;
                  if (val != null && val.isNotEmpty && val.length < 6) return l10n.passwordMinLength;
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                label: l10n.confirmPasswordLabel,
                hint: _isEdit ? l10n.optionalPasswordHint : l10n.confirmPasswordPlaceholder,
                prefixIcon: LucideIcons.lockKeyhole,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: theme.textSecondary,
                    size: 20,
                  ),
                  tooltip: l10n.togglePasswordVisibility,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (val) {
                  if (!_isEdit && (val == null || val.isEmpty)) return l10n.fieldRequired;
                  if (_passwordController.text.isNotEmpty && val != _passwordController.text) {
                    return l10n.confirmPasswordMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Submit Button
              AppButton(
                text: _isEdit ? l10n.updateStaffButton : l10n.saveStaffButton,
                isLoading: _isLoading,
                icon: LucideIcons.check,
                onPressed: () => _submit(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
