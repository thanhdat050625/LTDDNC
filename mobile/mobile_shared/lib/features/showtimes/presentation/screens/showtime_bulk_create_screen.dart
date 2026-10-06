import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeBulkCreateScreen extends StatefulWidget {
  final int? initialCinemaId;
  final Widget? drawer;

  const ShowtimeBulkCreateScreen({
    super.key,
    this.initialCinemaId,
    this.drawer,
  });

  @override
  State<ShowtimeBulkCreateScreen> createState() =>
      _ShowtimeBulkCreateScreenState();
}

class _ShowtimeBulkCreateScreenState extends State<ShowtimeBulkCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _movieId;
  int? _cinemaId;
  int? _primaryRoomId;
  String _format = 'FORMAT_2D';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _preShowController =
      TextEditingController(text: '10');
  final TextEditingController _postBufferController =
      TextEditingController(text: '15');

  List<String> _timeSlots = ['09:00', '14:00', '19:00'];

  // Cache loaded dependencies in state to prevent dropdown assertion crashes during submit/rebuild
  List<MovieModel> _movies = [];
  List<CinemaModel> _cinemas = [];
  List<RoomModel> _rooms = [];
  bool _isLoadingRooms = false;

  @override
  void initState() {
    super.initState();
    _cinemaId = widget.initialCinemaId;
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate!.add(const Duration(days: 3));
    context.read<ShowtimeBulkCreateCubit>().loadDependencies(
          initialCinemaId: _cinemaId,
        );
  }

  @override
  void dispose() {
    _preShowController.dispose();
    _postBufferController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _editTimeSlot(int index) async {
    final parts = _timeSlots[index].split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && mounted) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _timeSlots[index] = '$hourStr:$minuteStr';
        _timeSlots.sort();
      });
    }
  }

  Future<void> _addTimeSlot() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null && mounted) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      final newSlot = '$hourStr:$minuteStr';
      if (!_timeSlots.contains(newSlot)) {
        setState(() {
          _timeSlots.add(newSlot);
          _timeSlots.sort();
        });
      }
    }
  }

  void _removeTimeSlot(int index) {
    if (_timeSlots.length > 1) {
      setState(() {
        _timeSlots.removeAt(index);
      });
    }
  }

  int get _previewDays {
    if (_startDate == null || _endDate == null) return 0;
    if (_endDate!.isBefore(_startDate!)) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  int get _previewTotal {
    return _previewDays * _timeSlots.length;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_movieId == null || _cinemaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fillRequiredFields),
          backgroundColor: theme.error,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fillRequiredFields),
          backgroundColor: theme.error,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.showtimeBulkDateRangeError),
          backgroundColor: theme.error,
        ),
      );
      return;
    }

    if (_timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.showtimeBulkTimeSlotsEmptyError),
          backgroundColor: theme.error,
        ),
      );
      return;
    }

    final payload = <String, dynamic>{
      'movieId': _movieId,
      'cinemaId': _cinemaId,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
      'timeSlots': _timeSlots,
      'format': _format,
      'preShowMinutes': int.tryParse(_preShowController.text.trim()) ?? 10,
      'postMovieBufferMinutes':
          int.tryParse(_postBufferController.text.trim()) ?? 15,
      'status': 'SCHEDULED',
    };

    if (_primaryRoomId != null) {
      payload['primaryRoomId'] = _primaryRoomId;
    }

    context.read<ShowtimeBulkCreateCubit>().submit(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.showtimeBulkCreateTitle,
      showBackButton: true,
      drawer: widget.drawer,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.x),
          tooltip: l10n.cancel,
          onPressed: () => context.pop(),
        ),
      ],
      body: BlocConsumer<ShowtimeBulkCreateCubit, ShowtimeBulkCreateState>(
        listener: (context, state) {
          if (state is ShowtimeBulkCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShowtimeBulkCreateLoadingDeps && _movies.isEmpty) {
            return const Center(child: AppLoading());
          }

          if (state is ShowtimeBulkCreateSuccess) {
            return _buildResultView(context, state, theme, l10n);
          }

          if (state is ShowtimeBulkCreateDepsLoaded) {
            _movies = state.movies;
            _cinemas = state.cinemas;
            _rooms = state.rooms;
            _isLoadingRooms = state.isLoadingRooms;
          }

          final isSubmitting = state is ShowtimeBulkCreateSubmitting;

          // Safe value check against current lists to prevent Assertion failed line 1852 pos 10
          final selectedMovieId =
              (_movieId != null && _movies.any((m) => m.id == _movieId))
                  ? _movieId
                  : null;
          final selectedCinemaId =
              (_cinemaId != null && _cinemas.any((c) => c.id == _cinemaId))
                  ? _cinemaId
                  : null;
          final selectedRoomId =
              (_primaryRoomId != null && _rooms.any((r) => r.id == _primaryRoomId))
                  ? _primaryRoomId
                  : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Fields Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie dropdown
                        DropdownButtonFormField<int>(
                          key: ValueKey('movie_${_movies.length}_$selectedMovieId'),
                          isExpanded: true,
                          initialValue: selectedMovieId,
                          decoration: InputDecoration(
                            labelText: '${l10n.movieLabel} *',
                            labelStyle: TextStyle(color: theme.textSecondary),
                            prefixIcon: Icon(
                              LucideIcons.film,
                              color: theme.textSecondary,
                              size: 20,
                            ),
                          ),
                          dropdownColor: theme.surface,
                          items: _movies.map((movie) {
                            return DropdownMenuItem<int>(
                              value: movie.id,
                              child: Text(
                                movie.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: theme.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: isSubmitting
                              ? null
                              : (val) {
                                  setState(() {
                                    _movieId = val;
                                  });
                                },
                          validator: (val) =>
                              val == null ? l10n.selectMovieReq : null,
                        ),
                        const SizedBox(height: 16),

                        // Cinema dropdown
                        DropdownButtonFormField<int>(
                          key: ValueKey('cinema_${_cinemas.length}_$selectedCinemaId'),
                          isExpanded: true,
                          initialValue: selectedCinemaId,
                          decoration: InputDecoration(
                            labelText: '${l10n.cinemaLabel} *',
                            labelStyle: TextStyle(color: theme.textSecondary),
                            prefixIcon: Icon(
                              LucideIcons.mapPin,
                              color: theme.textSecondary,
                              size: 20,
                            ),
                          ),
                          dropdownColor: theme.surface,
                          items: _cinemas.map((cinema) {
                            return DropdownMenuItem<int>(
                              value: cinema.id,
                              child: Text(
                                cinema.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: theme.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: isSubmitting
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() {
                                      _cinemaId = val;
                                      _primaryRoomId = null;
                                    });
                                    context
                                        .read<ShowtimeBulkCreateCubit>()
                                        .selectCinema(val);
                                  }
                                },
                          validator: (val) =>
                              val == null ? l10n.selectCinemaReq : null,
                        ),
                        const SizedBox(height: 16),

                        // Primary Room dropdown (Optional)
                        DropdownButtonFormField<int?>(
                          key: ValueKey('room_${_rooms.length}_$selectedRoomId'),
                          isExpanded: true,
                          initialValue: selectedRoomId,
                          decoration: InputDecoration(
                            labelText: l10n.showtimeBulkPrimaryRoom,
                            labelStyle: TextStyle(color: theme.textSecondary),
                            prefixIcon: Icon(
                              LucideIcons.doorOpen,
                              color: theme.textSecondary,
                              size: 20,
                            ),
                            suffixIcon: _isLoadingRooms
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          dropdownColor: theme.surface,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                l10n.showtimeBulkAutoAssignRoom,
                                style: TextStyle(color: theme.textSecondary),
                              ),
                            ),
                            ..._rooms.map((room) {
                              return DropdownMenuItem<int?>(
                                value: room.id,
                                child: Text(
                                  '${room.name} (${room.roomType})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: theme.textPrimary),
                                ),
                              );
                            }),
                          ],
                          onChanged: (_cinemaId == null ||
                                  _isLoadingRooms ||
                                  isSubmitting)
                              ? null
                              : (val) {
                                  setState(() {
                                    _primaryRoomId = val;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),

                        // Format dropdown
                        DropdownButtonFormField<String>(
                          key: ValueKey('format_$_format'),
                          isExpanded: true,
                          initialValue: _format,
                          decoration: InputDecoration(
                            labelText: '${l10n.formatLabel} *',
                            labelStyle: TextStyle(color: theme.textSecondary),
                            prefixIcon: Icon(
                              LucideIcons.clapperboard,
                              color: theme.textSecondary,
                              size: 20,
                            ),
                          ),
                          dropdownColor: theme.surface,
                          items: const [
                            DropdownMenuItem(
                              value: 'FORMAT_2D',
                              child: Text('2D'),
                            ),
                            DropdownMenuItem(
                              value: 'FORMAT_3D',
                              child: Text('3D'),
                            ),
                            DropdownMenuItem(
                              value: 'IMAX',
                              child: Text('IMAX'),
                            ),
                          ],
                          onChanged: isSubmitting
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() {
                                      _format = val;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Date Range Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.showtimeBulkStartDate} & ${l10n.showtimeBulkEndDate}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: isSubmitting
                                    ? null
                                    : () => _selectStartDate(context),
                                borderRadius:
                                    BorderRadius.circular(theme.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.border),
                                    borderRadius:
                                        BorderRadius.circular(theme.radiusMd),
                                    color: theme.surface,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.showtimeBulkStartDate,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.calendar,
                                            size: 15,
                                            color: theme.accent,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              _startDate != null
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .format(_startDate!)
                                                  : l10n.showtimeBulkSelectDate,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: theme.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: isSubmitting
                                    ? null
                                    : () => _selectEndDate(context),
                                borderRadius:
                                    BorderRadius.circular(theme.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.border),
                                    borderRadius:
                                        BorderRadius.circular(theme.radiusMd),
                                    color: theme.surface,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.showtimeBulkEndDate,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.calendar,
                                            size: 15,
                                            color: theme.accent,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              _endDate != null
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .format(_endDate!)
                                                  : l10n.showtimeBulkSelectDate,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: theme.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _preShowController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: l10n.showtimeBulkPreShowMinutes,
                                  labelStyle: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    LucideIcons.playCircle,
                                    color: theme.textSecondary,
                                    size: 18,
                                  ),
                                ),
                                style: TextStyle(color: theme.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _postBufferController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: l10n.showtimeBulkPostBufferMinutes,
                                  labelStyle: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    LucideIcons.sparkles,
                                    color: theme.textSecondary,
                                    size: 18,
                                  ),
                                ),
                                style: TextStyle(color: theme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Screening Time Slots Card
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.showtimeBulkTimeSlots,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: isSubmitting ? null : _addTimeSlot,
                              icon: const Icon(LucideIcons.plus, size: 16),
                              label: Text(l10n.showtimeBulkAddTimeSlot),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.accent,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_timeSlots.length, (idx) {
                            final slot = _timeSlots[idx];
                            return InputChip(
                              label: Text(
                                slot,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                              ),
                              avatar: Icon(
                                LucideIcons.clock,
                                size: 16,
                                color: theme.accent,
                              ),
                              backgroundColor: theme.surfaceVariant,
                              onPressed:
                                  isSubmitting ? null : () => _editTimeSlot(idx),
                              onDeleted: (_timeSlots.length > 1 && !isSubmitting)
                                  ? () => _removeTimeSlot(idx)
                                  : null,
                              deleteIcon: Icon(
                                LucideIcons.x,
                                size: 16,
                                color: theme.textSecondary,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Preview Box
                  if (_previewDays > 0 && _timeSlots.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.accent.withValues(alpha: 0.08),
                        border: Border.all(
                          color: theme.accent.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.info,
                            color: theme.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.showtimeBulkPreview,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.accent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.showtimeBulkPreviewDesc(
                                    _previewDays,
                                    _timeSlots.length,
                                    _previewTotal,
                                  ),
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Submit Button
                  AppButton(
                    text: isSubmitting
                        ? l10n.showtimeBulkSubmitting
                        : l10n.showtimeBulkSubmitBtn,
                    icon: LucideIcons.sparkles,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultView(
    BuildContext context,
    ShowtimeBulkCreateSuccess state,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header icon
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Icon(
              state.failedCount == 0
                  ? LucideIcons.circleCheck
                  : LucideIcons.alertTriangle,
              size: 54,
              color: state.failedCount == 0 ? theme.success : theme.warning,
            ),
          ),
          Center(
            child: Text(
              l10n.showtimeBulkResultTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Success Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.success.withValues(alpha: 0.12),
              border: Border.all(
                color: theme.success.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(theme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.check, color: theme.success, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.showtimeBulkSuccessSummary(state.successCount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Failed Summary Card (if any)
          if (state.failedCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.error.withValues(alpha: 0.1),
                border: Border.all(
                  color: theme.error.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(theme.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.alertCircle,
                          color: theme.error, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        l10n.showtimeBulkFailedSummary(state.failedCount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...state.failedSlots.map((slot) {
                    final dateStr = (slot is Map && slot.containsKey('date'))
                        ? slot['date'].toString()
                        : '';
                    final reasonStr = (slot is Map && slot.containsKey('reason'))
                        ? slot['reason'].toString()
                        : '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.x, color: theme.error, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '$dateStr: $reasonStr',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          AppButton(
            text: l10n.showtimeBulkDone,
            icon: LucideIcons.checkCheck,
            onPressed: () => context.pop(true),
          ),
        ],
      ),
    );
  }
}
