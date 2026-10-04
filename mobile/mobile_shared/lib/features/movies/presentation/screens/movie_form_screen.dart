import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieFormScreen extends StatefulWidget {
  final MovieModel? movie;
  final int? movieId;

  const MovieFormScreen({super.key, this.movie, this.movieId});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _genreCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _directorCtrl;
  late TextEditingController _castCtrl;
  late TextEditingController _trailerCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _langCtrl;
  late TextEditingController _ageLimitCtrl;

  DateTime? _releaseDate;
  DateTime? _screeningEndDate;
  String _status = 'COMING_SOON';
  File? _posterFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    _titleCtrl = TextEditingController(text: m?.title ?? '');
    _genreCtrl = TextEditingController(text: m?.genre ?? '');
    _durationCtrl = TextEditingController(text: m != null ? m.durationMinutes.toString() : '');
    _directorCtrl = TextEditingController(text: m?.director ?? '');
    _castCtrl = TextEditingController(text: m?.cast ?? '');
    _trailerCtrl = TextEditingController(text: m?.trailerUrl ?? '');
    _descCtrl = TextEditingController(text: m?.description ?? '');
    _langCtrl = TextEditingController(text: m?.language ?? '');
    _ageLimitCtrl = TextEditingController(text: m?.ageLimit?.toString() ?? '');
    
    _releaseDate = m?.releaseDate;
    _screeningEndDate = m?.screeningEndDate;
    if (m != null) _status = m.status;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _genreCtrl.dispose();
    _durationCtrl.dispose();
    _directorCtrl.dispose();
    _castCtrl.dispose();
    _trailerCtrl.dispose();
    _descCtrl.dispose();
    _langCtrl.dispose();
    _ageLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _posterFile = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isReleaseDate) async {
    final initialDate = isReleaseDate 
        ? (_releaseDate ?? DateTime.now()) 
        : (_screeningEndDate ?? DateTime.now().add(const Duration(days: 30)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isReleaseDate) {
          _releaseDate = picked;
        } else {
          _screeningEndDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    final data = {
      'title': _titleCtrl.text.trim(),
      'genre': _genreCtrl.text.trim(),
      'durationMinutes': int.tryParse(_durationCtrl.text) ?? 0,
      'director': _directorCtrl.text.trim(),
      'cast': _castCtrl.text.trim(),
      'language': _langCtrl.text.trim(),
      'ageLimit': int.tryParse(_ageLimitCtrl.text),
      'status': _status,
      'trailerUrl': _trailerCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      if (_releaseDate != null) 'releaseDate': _releaseDate!.toIso8601String(),
      if (_screeningEndDate != null) 'screeningEndDate': _screeningEndDate!.toIso8601String(),
    };

    final isEdit = widget.movie != null || widget.movieId != null;
    final effectiveId = widget.movie?.id ?? widget.movieId;

    context.read<MovieFormCubit>().submit(
      isEdit: isEdit,
      movieId: effectiveId,
      data: data,
      posterPath: _posterFile?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.movie != null || widget.movieId != null;

    return AppScaffold(
      title: isEdit ? l10n.editMovieTitle : l10n.addMovieTitle,
      body: BlocConsumer<MovieFormCubit, MovieFormState>(
        listener: (context, state) {
          if (state is MovieFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit ? l10n.updateMovieSuccess : l10n.addMovieSuccess),
                backgroundColor: theme.success,
              ),
            );
            context.pop();
          } else if (state is MovieFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is MovieFormSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Poster Section Card
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : _pickImage,
                      child: Container(
                        width: 120,
                        height: 168,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _posterFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_posterFile!, fit: BoxFit.cover),
                              )
                            : (widget.movie?.posterUrl != null && widget.movie!.posterUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AppCachedImage(imageUrl: widget.movie!.posterUrl!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.imagePlus, size: 36, color: theme.accent),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.selectPoster,
                                        style: TextStyle(color: theme.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Section 1: Basic Info
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _titleCtrl,
                          label: l10n.movieTitleLabel,
                          hintText: l10n.enterMovieTitle,
                          validator: (val) => val == null || val.trim().isEmpty ? l10n.movieTitleRequired : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _genreCtrl,
                                label: l10n.genreLabel,
                                hintText: l10n.genrePlaceholder,
                                validator: (val) => val == null || val.trim().isEmpty ? l10n.fillRequiredFields : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppTextField(
                                controller: _durationCtrl,
                                label: l10n.durationMinutesLabel,
                                hintText: '120',
                                keyboardType: TextInputType.number,
                                validator: (val) => val == null || val.trim().isEmpty ? l10n.fillRequiredFields : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _langCtrl,
                                label: l10n.language,
                                hintText: l10n.languagePlaceholder,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppTextField(
                                controller: _ageLimitCtrl,
                                label: l10n.ageLimit,
                                hintText: l10n.ageLimitPlaceholder,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 2: Production Crew
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _directorCtrl,
                          label: l10n.director,
                          hintText: l10n.directorPlaceholder,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _castCtrl,
                          label: l10n.cast,
                          hintText: l10n.castPlaceholder,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 3: Schedule & Status
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: isLoading ? null : () => _selectDate(context, true),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.releaseDateLabel,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  child: Text(
                                    _releaseDate != null ? '${_releaseDate!.day}/${_releaseDate!.month}/${_releaseDate!.year}' : l10n.selectDatePrompt,
                                    style: TextStyle(
                                      color: _releaseDate != null ? theme.textPrimary : theme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: isLoading ? null : () => _selectDate(context, false),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.screeningEndDate,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  child: Text(
                                    _screeningEndDate != null ? '${_screeningEndDate!.day}/${_screeningEndDate!.month}/${_screeningEndDate!.year}' : l10n.selectDatePrompt,
                                    style: TextStyle(
                                      color: _screeningEndDate != null ? theme.textPrimary : theme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: InputDecoration(
                            labelText: l10n.statusLabel,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            DropdownMenuItem(value: 'NOW_SHOWING', child: Text(l10n.statusNowShowing)),
                            DropdownMenuItem(value: 'COMING_SOON', child: Text(l10n.statusComingSoon)),
                            DropdownMenuItem(value: 'STOPPED', child: Text(l10n.statusStopped)),
                          ],
                          onChanged: isLoading ? null : (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 4: Media & Synopsis
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _trailerCtrl,
                          label: l10n.trailerUrl,
                          hintText: l10n.trailerUrlPlaceholder,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _descCtrl,
                          label: l10n.description,
                          hintText: l10n.movieDescriptionPlaceholder,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  AppButton(
                    text: isEdit ? l10n.saveChanges : l10n.createMovieBtn,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
