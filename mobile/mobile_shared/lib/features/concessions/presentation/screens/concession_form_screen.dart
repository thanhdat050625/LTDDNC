import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionFormScreen extends StatefulWidget {
  final ConcessionProductModel? concession;

  const ConcessionFormScreen({super.key, this.concession});

  @override
  State<ConcessionFormScreen> createState() => _ConcessionFormScreenState();
}

class _ConcessionFormScreenState extends State<ConcessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _descriptionCtrl;

  String? _pickedImagePath;
  bool _isImageRemoved = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final c = widget.concession;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _priceCtrl = TextEditingController(text: c?.price.toString() ?? '');
    _stockCtrl = TextEditingController(text: c?.stockQuantity.toString() ?? '');
    _imageUrlCtrl = TextEditingController(text: c?.imageUrl ?? '');
    _descriptionCtrl = TextEditingController(text: c?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageUrlCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedImagePath = picked.path;
          _isImageRemoved = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.imageUploadError}: $e')));
      }
    }
  }

  void _showImageSourceActionSheet() {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusLg),
        ),
      ),
      builder: (bCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(theme.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: theme.spacingMd),
              Text(
                l10n.productImage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: theme.spacingMd),
              ListTile(
                leading: Icon(LucideIcons.camera, color: theme.accent),
                title: Text(
                  l10n.takePhoto,
                  style: TextStyle(color: theme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(bCtx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.image, color: theme.accent),
                title: Text(
                  l10n.chooseFromGallery,
                  style: TextStyle(color: theme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(bCtx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_hasImage())
                ListTile(
                  leading: Icon(LucideIcons.trash2, color: theme.error),
                  title: Text(
                    l10n.removeImage,
                    style: TextStyle(color: theme.error),
                  ),
                  onTap: () {
                    Navigator.pop(bCtx);
                    setState(() {
                      _pickedImagePath = null;
                      _isImageRemoved = true;
                      _imageUrlCtrl.clear();
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasImage() {
    if (_pickedImagePath != null) return true;
    if (!_isImageRemoved && _imageUrlCtrl.text.trim().isNotEmpty) return true;
    return false;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'price': num.parse(_priceCtrl.text.trim()),
        'stockQuantity': int.parse(_stockCtrl.text.trim()),
        'description': _descriptionCtrl.text.trim(),
      };

      if (_pickedImagePath != null) {
        // Will be uploaded via multipart
      } else if (_isImageRemoved) {
        data['imageUrl'] = '';
      } else if (_imageUrlCtrl.text.trim().isNotEmpty) {
        data['imageUrl'] = _imageUrlCtrl.text.trim();
      }

      context.read<ConcessionFormCubit>().submit(
        isEdit: widget.concession != null,
        concessionId: widget.concession?.id,
        data: data,
        imageFilePath: _pickedImagePath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.concession != null;

    return AppScaffold(
      title: isEdit ? l10n.editProduct : l10n.addProduct,
      showBackButton: true,
      body: BlocConsumer<ConcessionFormCubit, ConcessionFormState>(
        listener: (context, state) {
          if (state is ConcessionFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? l10n.updateSuccess : l10n.addSuccess),
              ),
            );
            context.pop();
          } else if (state is ConcessionFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(color: theme.error),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ConcessionFormSubmitting;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              theme.spacingMd,
              6,
              theme.spacingMd,
              theme.spacingLg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker Container
                  Center(
                    child: GestureDetector(
                      onTap: _showImageSourceActionSheet,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(theme.radiusLg),
                          border: Border.all(
                            color: _hasImage()
                                ? theme.accent
                                : theme.textSecondary.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            theme.radiusLg - 1.5,
                          ),
                          child: _buildImagePreview(theme, l10n),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: theme.spacingLg),

                  // Name Field
                  AppTextField(
                    controller: _nameCtrl,
                    label: '${l10n.productName} *',
                    hintText: l10n.productName,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? l10n.fillRequiredFields
                        : null,
                  ),
                  SizedBox(height: theme.spacingMd),

                  // Price Field
                  AppTextField(
                    controller: _priceCtrl,
                    label: '${l10n.priceLabel} *',
                    hintText: l10n.pricePlaceholder,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return l10n.fillRequiredFields;
                      if (num.tryParse(val.trim()) == null)
                        return l10n.invalidAmount;
                      return null;
                    },
                  ),
                  SizedBox(height: theme.spacingMd),

                  // Stock Quantity Field
                  AppTextField(
                    controller: _stockCtrl,
                    label: '${l10n.stockQuantity} *',
                    hintText: l10n.stockPlaceholder,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return l10n.fillRequiredFields;
                      if (int.tryParse(val.trim()) == null)
                        return l10n.invalidAmount;
                      return null;
                    },
                  ),
                  SizedBox(height: theme.spacingMd),

                  // Description Field
                  AppTextField(
                    controller: _descriptionCtrl,
                    label: l10n.productDescription,
                    hintText: l10n.productDescription,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    minLines: 3,
                  ),
                  SizedBox(height: theme.spacingLg),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: l10n.save,
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(CineplexColors theme, AppLocalizations l10n) {
    if (_pickedImagePath != null) {
      if (!kIsWeb) {
        return Image.file(
          File(_pickedImagePath!),
          fit: BoxFit.cover,
          width: 140,
          height: 140,
        );
      }
    }

    if (!_isImageRemoved && _imageUrlCtrl.text.trim().isNotEmpty) {
      return AppCachedImage(
        imageUrl: _imageUrlCtrl.text.trim(),
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    }

    return Center(
      child: Icon(
        LucideIcons.imagePlus,
        size: 38,
        color: theme.textSecondary.withValues(alpha: 0.6),
      ),
    );
  }
}
