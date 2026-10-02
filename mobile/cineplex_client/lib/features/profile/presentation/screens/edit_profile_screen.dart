import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialUser;

  const EditProfileScreen({super.key, this.initialUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _emailController;

  File? _avatarFile;
  String? _currentAvatarUrl;
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser ?? _getCurrentUserFromCubit();
    _currentAvatarUrl = user?['avatar']?.toString();
    _nameController = TextEditingController(text: user?['fullName'] ?? user?['name'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');

    _selectedGender = user?['gender'];
    if (_selectedGender != 'MALE' && _selectedGender != 'FEMALE') {
      _selectedGender = null;
    }

    final rawDob = user?['dateOfBirth'];
    if (rawDob != null && rawDob.toString().isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(rawDob.toString());
        _dobController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate!));
      } catch (_) {
        _dobController = TextEditingController();
      }
    } else {
      _dobController = TextEditingController();
    }
  }

  Map<String, dynamic>? _getCurrentUserFromCubit() {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      return state.user;
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  void _showImageSourceDialog(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.changeAvatar,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: colorScheme.primary),
                title: Text(l10n.chooseFromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveChanges(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _nameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fullNameRequired), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'fullName': fullName,
      'phone': _phoneController.text.trim(),
      if (_selectedGender != null) 'gender': _selectedGender,
      if (_selectedDate != null) 'dateOfBirth': DateFormat('yyyy-MM-dd').format(_selectedDate!),
    };

    final success = await context.read<ProfileCubit>().updateProfile(
      payload,
      avatarPath: _avatarFile?.path,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdated),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.pop();
    } else {
      final state = context.read<ProfileCubit>().state;
      final errorMsg = state is ProfileError ? state.message : l10n.error;
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: l10n.editProfile,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with camera button
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                              ? NetworkImage(_currentAvatarUrl!) as ImageProvider
                              : null),
                      child: (_avatarFile == null && (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                          ? Text(
                              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: colorScheme.primary,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _showImageSourceDialog(l10n),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email (Read-only)
              IgnorePointer(
                child: Opacity(
                  opacity: 0.6,
                  child: AppTextField(
                    label: l10n.email,
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Full Name (Required)
              AppTextField(
                label: l10n.fullName,
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fullNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              AppTextField(
                label: l10n.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.gender,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isDense: true,
                    isExpanded: true,
                    hint: Text(l10n.selectGender),
                    items: [
                      DropdownMenuItem(value: 'MALE', child: Text(l10n.male)),
                      DropdownMenuItem(value: 'FEMALE', child: Text(l10n.female)),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedGender = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date of Birth (DatePicker)
              GestureDetector(
                onTap: () => _pickDateOfBirth(context),
                child: AbsorbPointer(
                  child: AppTextField(
                    label: l10n.dateOfBirth,
                    controller: _dobController,
                    prefixIcon: Icons.calendar_today_outlined,
                    hint: 'YYYY-MM-DD',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSaving ? null : () => context.pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _isSaving ? l10n.loading : l10n.saveChanges,
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : () => _saveChanges(l10n),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
