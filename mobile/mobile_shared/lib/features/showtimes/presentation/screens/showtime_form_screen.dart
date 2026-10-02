import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeFormScreen extends StatefulWidget {
  final ShowtimeModel? showtime; // If null, create mode

  const ShowtimeFormScreen({super.key, this.showtime});

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
  int _preShowMinutes = 15;
  int _postMovieBufferMinutes = 15;

  @override
  void initState() {
    super.initState();
    if (widget.showtime != null) {
      final st = widget.showtime!;
      _movieId = st.movieId;
      _roomId = st.roomId;
      _format = st.format;
      _status = st.status;
      _publicStartTime = st.publicStartTime;
      // We assume cinemaId can be derived from room, but backend doesn't give it directly in ShowtimeModel.
      // We might need a separate way or let the user re-select.
      _cinemaId = st.room?.cinemaId; 
    }
    context.read<ShowtimeFormCubit>().loadDependencies(initialCinemaId: _cinemaId);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_movieId == null || _roomId == null || _publicStartTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.fillRequiredFields)),
        );
        return;
      }
      
      final data = {
        'movieId': _movieId,
        'roomId': _roomId,
        'format': _format,
        'status': _status,
        'publicStartTime': _publicStartTime!.toIso8601String(),
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
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final isEditMode = widget.showtime != null;

    return AppScaffold(
      title: isEditMode ? AppLocalizations.of(context)!.editShowtime : AppLocalizations.of(context)!.addShowtime,
      body: BlocConsumer<ShowtimeFormCubit, ShowtimeFormState>(
        listener: (context, state) {
          if (state is ShowtimeFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEditMode ? AppLocalizations.of(context)!.updateSuccess : AppLocalizations.of(context)!.addSuccess)),
            );
            context.pop();
          } else if (state is ShowtimeFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ShowtimeFormLoadingDeps) {
            return const Center(child: CircularProgressIndicator());
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
            padding: EdgeInsets.all(theme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Dropdown
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _movieId,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.movieLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: movies.map((m) => DropdownMenuItem(value: m.id, child: Text(m.title, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: isEditMode ? null : (val) => setState(() => _movieId = val),
                    validator: (val) => val == null ? AppLocalizations.of(context)!.selectMovieReq : null,
                  ),
                  SizedBox(height: theme.spacingMd),

                  // Cinema Dropdown
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _cinemaId,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.cinemaLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: cinemas.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: isEditMode
                        ? null
                        : (val) {
                            setState(() {
                              _cinemaId = val;
                              _roomId = null; // Reset room
                            });
                            if (val != null) {
                              context.read<ShowtimeFormCubit>().selectCinema(val);
                            }
                          },
                    validator: (val) => val == null ? AppLocalizations.of(context)!.selectCinemaReq : null,
                  ),
                  SizedBox(height: theme.spacingMd),

                  // Room Dropdown
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _roomId,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.roomLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: rooms.map((r) => DropdownMenuItem(value: r.id, child: Text('${r.name} (${r.roomType})', overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: isEditMode || _cinemaId == null
                        ? null
                        : (val) => setState(() => _roomId = val),
                    validator: (val) => val == null ? AppLocalizations.of(context)!.selectRoomReq : null,
                  ),
                  SizedBox(height: theme.spacingMd),

                  // Time Selection
                  GestureDetector(
                    onTap: () => _selectDateTime(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.textSecondary.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _publicStartTime != null
                                ? DateFormat('dd/MM/yyyy HH:mm').format(_publicStartTime!)
                                : AppLocalizations.of(context)!.selectStartTimeReq,
                            style: TextStyle(
                              color: _publicStartTime != null ? theme.textPrimary : theme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: theme.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (_publicStartTime == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(AppLocalizations.of(context)!.selectStartTimeReq, style: TextStyle(color: theme.error, fontSize: 12)),
                    ),
                  SizedBox(height: theme.spacingMd),

                  // Format
                  DropdownButtonFormField<String>(
                    initialValue: _format,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.formatLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: ['FORMAT_2D', 'FORMAT_3D', 'IMAX']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) => setState(() => _format = val!),
                  ),
                  SizedBox(height: theme.spacingMd),

                  // Status
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.statusLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.radiusMd)),
                    ),
                    items: ['SCHEDULED', 'BOOKING', 'FULL', 'CANCELLED', 'COMPLETED']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                  SizedBox(height: theme.spacingLg),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: AppButton(
                      text: isEditMode ? AppLocalizations.of(context)!.saveChanges : AppLocalizations.of(context)!.createShowtimeBtn,
                      onPressed: state is ShowtimeFormSubmitting ? null : _submit,
                      isLoading: state is ShowtimeFormSubmitting,
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
}
