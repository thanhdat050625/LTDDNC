import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeOccupancyScreen extends StatefulWidget {
  final Widget? drawer;

  const ShowtimeOccupancyScreen({super.key, this.drawer});

  @override
  State<ShowtimeOccupancyScreen> createState() =>
      _ShowtimeOccupancyScreenState();
}

class _ShowtimeOccupancyScreenState extends State<ShowtimeOccupancyScreen> {
  int _selectedDateIndex = 0;
  List<CinemaModel> _cinemas = [];
  int? _selectedCinemaId;
  Map<String, dynamic> _showtimesMap = {};
  bool _isLoading = false;

  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day + i),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  DioClient? _getDioClient() {
    try {
      return context.read<DioClient>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadData() async {
    final dio = _getDioClient();
    if (dio == null) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      final cinemaRepo = CinemaManagementRepository(dio);
      final cinemas = await cinemaRepo.getAllCinemas();

      if (cinemas.isNotEmpty) {
        int initialCinemaId = cinemas.first.id;
        try {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            final userCinemaId = authState.user.cinema?.id ?? authState.user.cinemaId;
            if (userCinemaId != null && cinemas.any((c) => c.id == userCinemaId)) {
              initialCinemaId = userCinemaId;
            }
          }
        } catch (_) {}

        final currentCinemaId = _selectedCinemaId ?? initialCinemaId;
        final showtimeRepo = ShowtimeManagementRepository(dio);
        final map = await showtimeRepo.getByCinemaId(currentCinemaId);

        if (mounted) {
          setState(() {
            _cinemas = cinemas;
            _selectedCinemaId = currentCinemaId;
            _showtimesMap = map;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _cinemas = [];
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onCinemaChanged(int newCinemaId) async {
    final dio = _getDioClient();
    if (dio == null) return;

    setState(() {
      _selectedCinemaId = newCinemaId;
      _isLoading = true;
    });

    try {
      final showtimeRepo = ShowtimeManagementRepository(dio);
      final map = await showtimeRepo.getByCinemaId(newCinemaId);
      if (mounted) {
        setState(() {
          _showtimesMap = map;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDateChip(int index, AppLocalizations l10n) {
    if (index == 0) return l10n.today;
    if (index == 1) return l10n.tomorrow;
    final d = _dates[index];
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  String _getDateKey(int index) {
    final d = _dates[index];
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  List<ShowtimeModel> _getCurrentShowtimes() {
    final key = _getDateKey(_selectedDateIndex);
    final rawList = _showtimesMap[key];
    if (rawList is! List) return [];

    final list = <ShowtimeModel>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        final st = ShowtimeModel.fromJson(item);
        if (st.status != 'CANCELLED') {
          list.add(st);
        }
      }
    }
    list.sort((a, b) => a.publicStartTime.compareTo(b.publicStartTime));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);
    final showtimes = _getCurrentShowtimes();

    return AppScaffold(
      title: l10n.showtimesAndOccupancy,
      drawer: widget.drawer,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: theme.primary,
        child: Column(
          children: [
            // Cinema selector bar if multiple cinemas exist
            if (_cinemas.length > 1)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: theme.surface,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cinemas.map((cinema) {
                      final isSelected = cinema.id == _selectedCinemaId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cinema.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected && cinema.id != _selectedCinemaId) {
                              _onCinemaChanged(cinema.id);
                            }
                          },
                          selectedColor: theme.primary.withValues(alpha: 0.15),
                          backgroundColor: theme.background,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.primary
                                : theme.textSecondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.primary
                                  : theme.borderSubtle,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Horizontal Date Picker
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(bottom: BorderSide(color: theme.borderSubtle)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_dates.length, (index) {
                    final isSelected = index == _selectedDateIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_formatDateChip(index, l10n)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedDateIndex = index);
                          }
                        },
                        selectedColor: theme.primary,
                        backgroundColor: theme.surface,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : theme.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? theme.primary
                                : theme.borderSubtle,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Room Timeline Cards
            Expanded(
              child: _isLoading && showtimes.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(color: theme.primary),
                    )
                  : showtimes.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.calendarOff,
                                size: 48,
                                color: theme.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noShowtimes,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: showtimes.length,
                      itemBuilder: (context, index) {
                        final st = showtimes[index];
                        return _buildRoomCard(
                          context: context,
                          theme: theme,
                          l10n: l10n,
                          showtime: st,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard({
    required BuildContext context,
    required CineplexColors theme,
    required AppLocalizations l10n,
    required ShowtimeModel showtime,
  }) {
    final now = DateTime.now();
    final durationMinutes = showtime.movie?.durationMinutes ?? 120;
    final endTime = showtime.publicStartTime.add(
      Duration(minutes: durationMinutes),
    );
    final isPast = now.isAfter(endTime);
    final isScreening =
        now.isAfter(showtime.publicStartTime) && now.isBefore(endTime);
    final isPreparing =
        !isScreening &&
        !isPast &&
        now.isAfter(
          showtime.publicStartTime.subtract(const Duration(minutes: 15)),
        );

    final String status;
    final Color statusColor;
    final double progress;

    if (isPast) {
      status = l10n.roomStatusCleaning;
      statusColor = theme.textSecondary;
      progress = 1.0;
    } else if (isScreening) {
      status = l10n.roomStatusScreening;
      statusColor = theme.success;
      final totalSec = endTime.difference(showtime.publicStartTime).inSeconds;
      progress = totalSec > 0
          ? (now.difference(showtime.publicStartTime).inSeconds / totalSec)
                .clamp(0.0, 1.0)
          : 0.5;
    } else if (isPreparing) {
      status = l10n.roomStatusPreparing;
      statusColor = theme.warning;
      progress = 0.0;
    } else {
      status = l10n.roomStatusReady;
      statusColor = theme.info;
      progress = 0.0;
    }

    final capacity = showtime.totalSeats > 0
        ? showtime.totalSeats
        : (showtime.room?.totalSeats ?? 0);
    final booked = capacity > 0
        ? (capacity - showtime.availableSeats).clamp(0, capacity)
        : 0;
    final occupancyPercent = capacity > 0
        ? ((booked / capacity) * 100).round()
        : 0;
    final occupancyColor = occupancyPercent >= 90
        ? theme.error
        : (occupancyPercent >= 70 ? theme.warning : theme.success);

    final roomName =
        showtime.room?.name ?? l10n.roomPrefix(showtime.roomId.toString());
    final formatStr = showtime.format.replaceAll('FORMAT_', '');
    final timeStr =
        '${FormatUtils.formatTime(showtime.publicStartTime)} - ${FormatUtils.formatTime(endTime)}';
    final movieTitle = showtime.movie?.title ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Room Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$roomName ($formatStr)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Movie Info & Format
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movieTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$formatStr • $timeStr',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Screening Runtime Progress
          if (progress > 0 && progress < 1.0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Occupancy Meter & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(LucideIcons.users, size: 14, color: occupancyColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$booked/$capacity ${l10n.seatUnit} ($occupancyPercent%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: occupancyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () => _showQuickSeatMap(
                  context,
                  showtime,
                  roomName,
                  movieTitle,
                  capacity,
                  booked,
                ),
                icon: const Icon(LucideIcons.layoutGrid, size: 14),
                label: Text(
                  l10n.viewSeatMap,
                  style: const TextStyle(fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primary,
                  side: BorderSide(color: theme.primary.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickSeatMap(
    BuildContext context,
    ShowtimeModel showtime,
    String roomName,
    String movie,
    int capacity,
    int booked,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => _QuickSeatMapModal(
        showtime: showtime,
        roomName: roomName,
        movie: movie,
        capacity: capacity,
        booked: booked,
      ),
    );
  }
}

class _QuickSeatMapModal extends StatefulWidget {
  final ShowtimeModel showtime;
  final String roomName;
  final String movie;
  final int capacity;
  final int booked;

  const _QuickSeatMapModal({
    required this.showtime,
    required this.roomName,
    required this.movie,
    required this.capacity,
    required this.booked,
  });

  @override
  State<_QuickSeatMapModal> createState() => _QuickSeatMapModalState();
}

class _QuickSeatMapModalState extends State<_QuickSeatMapModal> {
  List<SeatModel> _seats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSeats());
  }

  Future<void> _loadSeats() async {
    try {
      final dio = context.read<DioClient>();
      final repo = BookingManagementRepository(dio);
      final seats = await repo.getShowtimeSeats(widget.showtime.id);
      if (mounted) {
        setState(() {
          _seats = seats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final actualTotal = _seats.isNotEmpty ? _seats.length : widget.capacity;
    final actualBooked = _seats.isNotEmpty
        ? _seats
              .where(
                (s) =>
                    s.status == SeatStatus.booked ||
                    s.status == SeatStatus.held,
              )
              .length
        : widget.booked;
    final actualAvailable = (actualTotal - actualBooked).clamp(0, actualTotal);

    // Group seats by row
    final Map<String, List<SeatModel>> rowMap = {};
    for (final s in _seats) {
      rowMap.putIfAbsent(s.row, () => []).add(s);
    }
    final rows = rowMap.keys.toList()..sort();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.roomName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      widget.movie,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Screen Curve
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.primary, width: 3)),
            ),
            child: Text(
              l10n.screen,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seat Grid
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.primary))
                : _seats.isEmpty
                ? Center(
                    child: Text(
                      l10n.noData,
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  )
                : InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 2.5,
                    constrained: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: rows.map((r) {
                          final rowSeats = rowMap[r]!
                            ..sort((a, b) => a.column.compareTo(b.column));
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    r,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ),
                                ...rowSeats.map((seat) {
                                  final isBooked =
                                      seat.status == SeatStatus.booked ||
                                      seat.status == SeatStatus.held;
                                  final isVIP = seat.isCouple;

                                  final seatColor = isBooked
                                      ? theme.seatBooked
                                      : (isVIP
                                            ? theme.seatVIP
                                            : theme.seatStandard);

                                  return Container(
                                    width: isVIP ? 52 : 26,
                                    height: 26,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: seatColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${seat.column}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isBooked
                                              ? theme.seatBookedText
                                              : theme.seatText,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(theme.seatStandard, l10n.seatStandard, theme),
              const SizedBox(width: 12),
              _buildLegend(theme.seatVIP, l10n.seatVIP, theme),
              const SizedBox(width: 12),
              _buildLegend(theme.seatBooked, l10n.seatBooked, theme),
            ],
          ),
          const SizedBox(height: 12),

          // Counters summary
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  l10n.availableCountLabel(actualAvailable),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.success,
                  ),
                ),
                Text(
                  l10n.bookedCountLabel(actualBooked),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.seatBooked,
                  ),
                ),
                Text(
                  l10n.totalCountLabel(actualTotal),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, CineplexColors theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
      ],
    );
  }
}
