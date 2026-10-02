import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieFormScreen extends StatefulWidget {
  final MovieModel? movie;

  const MovieFormScreen({super.key, this.movie});

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

    context.read<MovieFormCubit>().submit(
      isEdit: widget.movie != null,
      movieId: widget.movie?.id,
      data: data,
      posterPath: _posterFile?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final isEdit = widget.movie != null;

    return AppScaffold(
      title: isEdit ? 'Cập nhật phim' : 'Thêm phim mới',
      body: BlocConsumer<MovieFormCubit, MovieFormState>(
        listener: (context, state) {
          if (state is MovieFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEdit ? 'Cập nhật thành công!' : 'Thêm phim thành công!')),
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
            padding: EdgeInsets.all(theme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster Section
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : _pickImage,
                      child: Container(
                        width: 140,
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          border: Border.all(color: theme.textSecondary.withValues(alpha: 0.3)),
                        ),
                        child: _posterFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(theme.radiusMd),
                                child: Image.file(_posterFile!, fit: BoxFit.cover),
                              )
                            : (widget.movie?.posterUrl != null && widget.movie!.posterUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(theme.radiusMd),
                                    child: AppCachedImage(imageUrl: widget.movie!.posterUrl!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.imagePlus, size: 40, color: theme.textSecondary),
                                      SizedBox(height: theme.spacingSm),
                                      Text('Chọn poster', style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.0),

                  // Basic Info
                  AppTextField(
                    controller: _titleCtrl,
                    label: 'Tên phim *',
                    hintText: 'Nhập tên phim',
                    validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên phim' : null,
                  ),
                  SizedBox(height: theme.spacingMd),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _genreCtrl,
                          label: 'Thể loại *',
                          hintText: 'Hành động, Hài...',
                          validator: (val) => val == null || val.isEmpty ? 'Bắt buộc' : null,
                        ),
                      ),
                      SizedBox(width: theme.spacingMd),
                      Expanded(
                        child: AppTextField(
                          controller: _durationCtrl,
                          label: 'Thời lượng (phút) *',
                          hintText: '120',
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty ? 'Bắt buộc' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _directorCtrl,
                    label: 'Đạo diễn',
                    hintText: 'Tên đạo diễn',
                  ),
                  SizedBox(height: theme.spacingMd),
                  AppTextField(
                    controller: _castCtrl,
                    label: 'Diễn viên',
                    hintText: 'Tên diễn viên...',
                  ),
                  SizedBox(height: theme.spacingMd),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _langCtrl,
                          label: 'Ngôn ngữ',
                          hintText: 'Tiếng Anh, Tiếng Việt...',
                        ),
                      ),
                      SizedBox(width: theme.spacingMd),
                      Expanded(
                        child: AppTextField(
                          controller: _ageLimitCtrl,
                          label: 'Độ tuổi',
                          hintText: '13, 16, 18...',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: theme.spacingMd),
                  
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: isLoading ? null : () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ngày phát hành',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                            ),
                            child: Text(
                              _releaseDate != null ? '${_releaseDate!.day}/${_releaseDate!.month}/${_releaseDate!.year}' : 'Chọn ngày',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: theme.spacingMd),
                      Expanded(
                        child: InkWell(
                          onTap: isLoading ? null : () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ngày kết thúc',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                            ),
                            child: Text(
                              _screeningEndDate != null ? '${_screeningEndDate!.day}/${_screeningEndDate!.month}/${_screeningEndDate!.year}' : 'Chọn ngày',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: theme.spacingMd),
                  
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'NOW_SHOWING', child: Text('Đang chiếu')),
                      DropdownMenuItem(value: 'COMING_SOON', child: Text('Sắp chiếu')),
                      DropdownMenuItem(value: 'STOPPED', child: Text('Ngừng chiếu')),
                    ],
                    onChanged: isLoading ? null : (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                  SizedBox(height: theme.spacingMd),
                  
                  AppTextField(
                    controller: _trailerCtrl,
                    label: 'Trailer URL',
                    hintText: 'https://youtube.com/...',
                  ),
                  SizedBox(height: theme.spacingMd),
                  
                  AppTextField(
                    controller: _descCtrl,
                    label: 'Mô tả',
                    hintText: 'Nội dung phim...',
                  ),
                  SizedBox(height: 32.0),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? 'Lưu thay đổi' : 'Tạo phim'),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
