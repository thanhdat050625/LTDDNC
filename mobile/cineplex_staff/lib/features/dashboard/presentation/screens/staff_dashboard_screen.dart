import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:cineplex_staff/features/home/presentation/widgets/staff_drawer.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  String _cinemaName = '';
  int _ticketsScanned = 0;
  num _counterRevenue = 0;
  int _upcomingShowtimesCount = 0;
  int _occupancyPercent = 0;
  List<ShowtimeModel> _todayShowtimes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  DioClient? _getDioClient() {
    try {
      return context.read<DioClient>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadDashboardData() async {
    final dio = _getDioClient();
    if (dio == null) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      // 1. Fetch cinemas to get assigned cinema name
      final cinemaRepo = CinemaManagementRepository(dio);
      final cinemas = await cinemaRepo.getAllCinemas();
      int? currentCinemaId;
      String currentCinemaName = '';

      if (cinemas.isNotEmpty) {
        currentCinemaId = cinemas.first.id;
        currentCinemaName = cinemas.first.name;
      }

      // 2. Fetch summary statistics
      int ticketsScanned = 0;
      num counterRevenue = 0;
      try {
        final res = await dio.get('/statistics/summary');
        final payload = (res.data is Map && res.data.containsKey('data'))
            ? res.data['data']
            : res.data;
        if (payload is Map<String, dynamic>) {
          final summary = SummaryModel.fromJson(payload);
          ticketsScanned = summary.checkedInTickets > 0
              ? summary.checkedInTickets
              : summary.tickets;
          counterRevenue = summary.revenue;
        }
      } catch (_) {}

      // 3. Fetch real showtimes for cinema
      List<ShowtimeModel> todayShowtimes = [];
      int upcomingCount = 0;
      int avgOccupancy = 0;

      if (currentCinemaId != null) {
        final showtimeRepo = ShowtimeManagementRepository(dio);
        final showtimesMap = await showtimeRepo.getByCinemaId(currentCinemaId);
        final now = DateTime.now();
        final todayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        dynamic todayRawList = showtimesMap[todayKey];
        if (todayRawList == null && showtimesMap.isNotEmpty) {
          final sortedKeys = showtimesMap.keys.toList()..sort();
          for (final k in sortedKeys) {
            if (k.compareTo(todayKey) >= 0 && showtimesMap[k] is List) {
              todayRawList = showtimesMap[k];
              break;
            }
          }
          todayRawList ??= showtimesMap.values.first;
        }

        if (todayRawList is List) {
          for (final item in todayRawList) {
            if (item is Map<String, dynamic>) {
              final st = ShowtimeModel.fromJson(item);
              if (st.status != 'CANCELLED') {
                todayShowtimes.add(st);
              }
            }
          }
        }

        todayShowtimes.sort(
          (a, b) => a.publicStartTime.compareTo(b.publicStartTime),
        );

        int totalCap = 0;
        int totalBooked = 0;
        for (final st in todayShowtimes) {
          final duration = st.movie?.durationMinutes ?? 120;
          final endTime = st.publicStartTime.add(Duration(minutes: duration));
          if (endTime.isAfter(now)) {
            upcomingCount++;
          }
          final cap = st.totalSeats > 0
              ? st.totalSeats
              : (st.room?.totalSeats ?? 0);
          final booked = cap > 0 ? (cap - st.availableSeats).clamp(0, cap) : 0;
          totalCap += cap;
          totalBooked += booked;
        }

        avgOccupancy = totalCap > 0
            ? ((totalBooked / totalCap) * 100).round()
            : 0;
      }

      if (mounted) {
        setState(() {
          _cinemaName = currentCinemaName;
          _ticketsScanned = ticketsScanned;
          _counterRevenue = counterRevenue;
          _upcomingShowtimesCount = upcomingCount;
          _occupancyPercent = avgOccupancy;
          _todayShowtimes = todayShowtimes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);
    final authState = context.watch<AuthBloc>().state;
    final staffUser = authState is AuthAuthenticated ? authState.user : null;

    final staffName = staffUser?.fullName.isNotEmpty == true
        ? staffUser!.fullName
        : l10n.staffRole;
    final cinemaDisplayName = _cinemaName;

    return AppScaffold(
      title: l10n.staffDashboard,
      drawer: const StaffDrawer(),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.user),
          tooltip: l10n.profile,
          onPressed: () => context.go('/profile'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: theme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shift Header Card
              _buildShiftHeader(
                context,
                theme,
                staffName,
                cinemaDisplayName,
                l10n,
              ),
              const SizedBox(height: 16),

              // 2x2 KPI Cards
              Text(
                l10n.shiftInfo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildKpiGrid(context, theme, l10n),
              const SizedBox(height: 20),

              // Quick Action Shortcuts
              Text(
                l10n.quickActions,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildQuickActions(context, theme, l10n),
              const SizedBox(height: 20),

              // Live Room Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.showtimesAndOccupancy,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/showtimes-occupancy'),
                    child: Text(
                      l10n.seeAll,
                      style: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildLiveRoomList(context, theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftHeader(
    BuildContext context,
    CineplexColors theme,
    String staffName,
    String cinemaName,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.primary.withValues(alpha: 0.15),
            child: Text(
              staffName.isNotEmpty ? staffName[0].toUpperCase() : 'S',
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        staffName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.staffBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (cinemaName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 13,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cinemaName,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: theme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${l10n.currentShift}: 14:00 - 22:00',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.success,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: LucideIcons.scanLine,
              iconColor: theme.primary,
              title: l10n.ticketsScannedToday,
              value: '$_ticketsScanned',
              subtitle: l10n.today,
            ),
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: LucideIcons.receipt,
              iconColor: theme.accent,
              title: l10n.counterRevenueToday,
              value: FormatUtils.formatCurrency(_counterRevenue),
              subtitle: l10n.counterRevenueSubtitle,
            ),
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: LucideIcons.clock,
              iconColor: theme.info,
              title: l10n.upcomingShowtimesCount,
              value: '$_upcomingShowtimesCount',
              subtitle: l10n.upcomingShowtimesSubtitle,
            ),
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: LucideIcons.users,
              iconColor: theme.success,
              title: l10n.occupancyPercent(_occupancyPercent),
              value: '$_occupancyPercent%',
              subtitle: l10n.averageSubtitle,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required CineplexColors theme,
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: width,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: theme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: theme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    final actions = [
      {
        'title': l10n.actionScanTicket,
        'icon': LucideIcons.scanLine,
        'color': theme.primary,
        'onTap': () => context.go('/scanner'),
      },
      {
        'title': l10n.actionCounterSale,
        'icon': LucideIcons.shoppingBag,
        'color': theme.accent,
        'onTap': () => context.go('/pos'),
      },
      {
        'title': l10n.actionFastPOS,
        'icon': LucideIcons.popcorn,
        'color': theme.warning,
        'onTap': () => context.go('/pos'),
      },
      {
        'title': l10n.actionRoomStatus,
        'icon': LucideIcons.film,
        'color': theme.info,
        'onTap': () => context.go('/showtimes-occupancy'),
      },
    ];

    return Row(
      children: actions.map((a) {
        final color = a['color'] as Color;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: a['onTap'] as VoidCallback,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.borderSubtle),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        a['icon'] as IconData,
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLiveRoomList(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    if (_isLoading && _todayShowtimes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: theme.primary),
        ),
      );
    }

    if (_todayShowtimes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.calendarOff, size: 36, color: theme.textSecondary),
            const SizedBox(height: 8),
            Text(
              l10n.noShowtimes,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();

    return Column(
      children: _todayShowtimes.map((st) {
        final durationMinutes = st.movie?.durationMinutes ?? 120;
        final endTime = st.publicStartTime.add(
          Duration(minutes: durationMinutes),
        );
        final isPast = now.isAfter(endTime);
        final isScreening =
            now.isAfter(st.publicStartTime) && now.isBefore(endTime);
        final isPreparing =
            !isScreening &&
            !isPast &&
            now.isAfter(
              st.publicStartTime.subtract(const Duration(minutes: 15)),
            );

        final String status;
        final Color statusColor;

        if (isPast) {
          status = l10n.roomStatusCleaning;
          statusColor = theme.textSecondary;
        } else if (isScreening) {
          status = l10n.roomStatusScreening;
          statusColor = theme.success;
        } else if (isPreparing) {
          status = l10n.roomStatusPreparing;
          statusColor = theme.warning;
        } else {
          status = l10n.roomStatusReady;
          statusColor = theme.info;
        }

        final cap = st.totalSeats > 0
            ? st.totalSeats
            : (st.room?.totalSeats ?? 0);
        final booked = cap > 0 ? (cap - st.availableSeats).clamp(0, cap) : 0;
        final percent = cap > 0 ? ((booked / cap) * 100).round() : 0;
        final roomName = st.room?.name ?? l10n.roomPrefix(st.roomId.toString());
        final formatStr = st.format.replaceAll('FORMAT_', '');
        final displayName = '$roomName ($formatStr)';
        final movieTitle = st.movie?.title ?? '';
        final timeStr =
            '${FormatUtils.formatTime(st.publicStartTime)} - ${FormatUtils.formatTime(endTime)}';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      movieTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 6,
                        backgroundColor: theme.borderSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent > 90
                              ? theme.error
                              : (percent > 70 ? theme.warning : theme.success),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$booked/$cap ($percent%)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
