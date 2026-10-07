import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeFormScreen extends StatefulWidget {
  final ShowtimeModel? showtime;
  final Widget? drawer;

  const ShowtimeFormScreen({super.key, this.showtime, this.drawer});

  @override
  State<ShowtimeFormScreen> createState() => _ShowtimeFormScreenState();
}

class _ShowtimeFormScreenState extends State<ShowtimeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _movieId;
  int? _cinemaId;
  int? _roomId;
  String _format = 'FORMAT_2D';
  String _status = 'SCHEDULED';
  DateTime? _publicStartTime;
  final int _preShowMinutes = 15;
  final int _postMovieBufferMinutes = 15;

  @override
  void initState() {
    super.initState();
    if (widget.showtime != null) {
      final st = widget.showtime!;
      _movieId = st.movieId;
      _roomId = st.roomId;
      _format = st.format;
      _status = (st.status == 'BOOKING') ? 'ACTIVE' : st.status;
      if (!const [
        'SCHEDULED',
        'ACTIVE',
        'COMPLETED',
        'CANCELLED',
      ].contains(_status)) {
        _status = 'SCHEDULED';
      }
      _publicStartTime = st.publicStartTime;
      _cinemaId = st.room?.cinemaId;
    }
    context.read<ShowtimeFormCubit>().loadDependencies(
      initialCinemaId: _cinemaId,
    );
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_movieId == null || _roomId == null || _publicStartTime == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.fillRequiredFields)));
        return;
      }

      final data = {
        'movieId': _movieId,
        'roomId': _roomId,
        'format': _format,
        'status': _status,
        // Gửi UTC ISO string để backend lưu đúng múi giờ
        'publicStartTime': _publicStartTime!.toUtc().toIso8601String(),
        'preShowMinutes': _preShowMinutes,
        'postMovieBufferMinutes': _postMovieBufferMinutes,
      };

      context.read<ShowtimeFormCubit>().submit(
        isEdit: widget.showtime != null,
        showtimeId: widget.showtime?.id,
        data: data,
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _publicStartTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_publicStartTime ?? DateTime.now()),
      );
      if (time != null && mounted) {
        setState(() {
          _publicStartTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditMode = widget.showtime != null;

    return AppScaffold(
      title: isEditMode ? l10n.editShowtime : l10n.addShowtime,
      showBackButton: true,
      drawer: widget.drawer,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.x),
          tooltip: l10n.cancel,
          onPressed: () => context.pop(),
        ),
      ],
      body: BlocConsumer<ShowtimeFormCubit, ShowtimeFormState>(
        listener: (context, state) {
          if (state is ShowtimeFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditMode ? l10n.updateSuccess : l10n.addSuccess,
                ),
                backgroundColor: theme.success,
              ),
            );
            context.pop();
          } else if (state is ShowtimeFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShowtimeFormLoadingDeps) {
            return const Center(child: AppLoading());
          }

          List<MovieModel> movies = [];
          List<CinemaModel> cinemas = [];
          List<RoomModel> rooms = [];

          if (state is ShowtimeFormDepsLoaded) {
            movies = state.movies;
            cinemas = state.cinemas;
            rooms = state.rooms;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie Dropdown
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _movieId,
                          decoration: InputDecoration(
                            labelText: l10n.movieLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                theme.radiusMd,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: movies
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m.id,
                                  child: Text(
                                    m.title,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isEditMode
                              ? null
                              : (val) => setState(() => _movieId = val),
                          validator: (val) =>
                              val == null ? l10n.selectMovieReq : null,
                        ),
                        const SizedBox(height: 14),

                        // Cinema Dropdown
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _cinemaId,
                          decoration: InputDecoration(
                            labelText: l10n.cinemaLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                theme.radiusMd,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: cinemas
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isEditMode
                              ? null
                              : (val) {
                                  setState(() {
                                    _cinemaId = val;
                                    _roomId = null;
                                  });
                                  if (val != null) {
                                    context
                                        .read<ShowtimeFormCubit>()
                                        .selectCinema(val);
                                  }
                                },
                          validator: (val) =>
                              val == null ? l10n.selectCinemaReq : null,
                        ),
                        const SizedBox(height: 14),

                        // Room Dropdown
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _roomId,
                          decoration: InputDecoration(
                            labelText: l10n.roomLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                theme.radiusMd,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: rooms
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r.id,
                                  child: Text(
                                    '${r.name} (${r.roomType})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isEditMode || _cinemaId == null
                              ? null
                              : (val) => setState(() => _roomId = val),
                          validator: (val) =>
                              val == null ? l10n.selectRoomReq : null,
                        ),
                        const SizedBox(height: 14),

                        // Time Selection
                        InkWell(
                          onTap: () => _selectDateTime(context),
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.startTime,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  theme.radiusMd,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              suffixIcon: Icon(
                                LucideIcons.calendar,
                                color: theme.textSecondary,
                                size: 20,
                              ),
                            ),
                            child: Text(
                              _publicStartTime != null
                                  ? DateFormat('dd/MM/yyyy • HH:mm')
                                        .format(_publicStartTime!)
                                  : l10n.selectStartTimeReq,
                              style: TextStyle(
                                color: _publicStartTime != null
                                    ? theme.textPrimary
                                    : theme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Format
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _format,
                          decoration: InputDecoration(
                            labelText: l10n.formatLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                theme.radiusMd,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'FORMAT_2D',
                              child: Text(l10n.format2D),
                            ),
                            DropdownMenuItem(
                              value: 'FORMAT_3D',
                              child: Text(l10n.format3D),
                            ),
                            DropdownMenuItem(
                              value: 'IMAX',
                              child: Text(l10n.formatIMAX),
                            ),
                          ],
                          onChanged: (val) => setState(() => _format = val!),
                        ),
                        const SizedBox(height: 14),

                        // Status
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _status,
                          decoration: InputDecoration(
                            labelText: l10n.statusLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                theme.radiusMd,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'SCHEDULED',
                              child: Text(l10n.statusScheduled),
                            ),
                            DropdownMenuItem(
                              value: 'ACTIVE',
                              child: Text(l10n.statusBooking),
                            ),
                            DropdownMenuItem(
                              value: 'COMPLETED',
                              child: Text(l10n.statusCompleted),
                            ),
                            DropdownMenuItem(
                              value: 'CANCELLED',
                              child: Text(l10n.statusCancelled),
                            ),
                          ],
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  AppButton(
                    text: isEditMode
                        ? l10n.saveChanges
                        : l10n.createShowtimeBtn,
                    onPressed: _submit,
                    isLoading: state is ShowtimeFormSubmitting,
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
