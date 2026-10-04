import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:cineplex_staff/features/home/presentation/widgets/staff_drawer.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);
    final authState = context.watch<AuthBloc>().state;
    final staffUser = authState is AuthAuthenticated ? authState.user : null;

    final staffName = staffUser?.fullName.isNotEmpty == true
        ? staffUser!.fullName
        : l10n.staffRole;
    const cinemaName = 'Cineplex Flagship';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shift Header Card
            _buildShiftHeader(context, theme, staffName, cinemaName, l10n),
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
              value: '148',
              subtitle: l10n.today,
            ),
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: LucideIcons.receipt,
              iconColor: theme.accent,
              title: l10n.counterRevenueToday,
              value: FormatUtils.formatCurrency(4650000),
              subtitle: l10n.counterRevenueSubtitle,
            ),
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: LucideIcons.clock,
              iconColor: theme.info,
              title: l10n.upcomingShowtimesCount,
              value: '6',
              subtitle: l10n.upcomingShowtimesSubtitle,
            ),
            _buildKpiCard(
              theme: theme,
              width: cardWidth,
              icon: LucideIcons.users,
              iconColor: theme.success,
              title: l10n.occupancyPercent(74),
              value: '74%',
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
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
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
    final sampleRooms = [
      {
        'name': '${l10n.roomPrefix('01')} (IMAX)',
        'movie': 'Mai',
        'time': '14:30 - 16:45',
        'status': l10n.roomStatusScreening,
        'statusColor': theme.success,
        'occupancy': '92/100',
        'percent': 92,
      },
      {
        'name': '${l10n.roomPrefix('02')} (Standard)',
        'movie': 'Dune: Part Two',
        'time': '15:15 - 18:00',
        'status': l10n.roomStatusPreparing,
        'statusColor': theme.warning,
        'occupancy': '75/120',
        'percent': 63,
      },
      {
        'name': '${l10n.roomPrefix('03')} (VIP)',
        'movie': 'Kung Fu Panda 4',
        'time': '16:00 - 17:35',
        'status': l10n.roomStatusReady,
        'statusColor': theme.info,
        'occupancy': '40/48',
        'percent': 83,
      },
    ];

    return Column(
      children: sampleRooms.map((room) {
        final percent = room['percent'] as int;
        final statusColor = room['statusColor'] as Color;

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
                      room['name'] as String,
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
                      room['status'] as String,
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
                      room['movie'] as String,
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
                    room['time'] as String,
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
                    '${room['occupancy']} ($percent%)',
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
