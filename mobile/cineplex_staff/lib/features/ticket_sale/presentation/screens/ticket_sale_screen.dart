import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

import '../cubit/ticket_sale_cubit.dart';
import '../cubit/ticket_sale_state.dart';

class TicketSaleScreen extends StatelessWidget {
  final Widget? drawer;
  const TicketSaleScreen({super.key, this.drawer = const StaffDrawer()});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = context.read<DioClient>();
        return TicketSaleCubit(
          CinemaManagementRepository(dio),
          ShowtimeManagementRepository(dio),
          BookingManagementRepository(dio),
        )..loadInitialData();
      },
      child: _TicketSaleScreenView(drawer: drawer),
    );
  }
}

class _TicketSaleScreenView extends StatelessWidget {
  final Widget? drawer;
  const _TicketSaleScreenView({this.drawer = const StaffDrawer()});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.counterSale,
      drawer: drawer,
      body: BlocBuilder<TicketSaleCubit, TicketSaleState>(
        builder: (context, state) {
          if (state is TicketSaleLoading || state is TicketSaleInitial) {
            return const Center(child: AppLoading());
          }

          if (state is TicketSaleError) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<TicketSaleCubit>().loadInitialData(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<TicketSaleCubit>().loadInitialData(),
                  ),
                ],
              ),
            );
          }

          if (state is TicketSaleLoaded) {
            if (state.cinemas.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<TicketSaleCubit>().loadInitialData(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Text(
                        l10n.noData,
                        style: TextStyle(color: theme.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cinema Selector Header
                  _buildCinemaSelector(context, theme, l10n, state),

                  // Horizontal Movies Section
                  _buildMoviesSection(context, theme, l10n, state),

                  Divider(
                    color: theme.borderSubtle,
                    height: 1,
                  ),

                  // Main content: Showtimes for Selected Movie
                  Expanded(
                    child: _buildShowtimesContent(context, theme, l10n, state),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCinemaSelector(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
    TicketSaleLoaded state,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        theme.spacingMd,
        theme.spacingSm,
        theme.spacingMd,
        4.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.mapPin, size: 18, color: theme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: state.selectedCinemaId,
                isExpanded: true,
                dropdownColor: theme.surface,
                icon: Icon(
                  LucideIcons.chevronDown,
                  size: 18,
                  color: theme.textSecondary,
                ),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                onChanged: (value) {
                  if (value != null) {
                    context.read<TicketSaleCubit>().selectCinema(value);
                  }
                },
                items: state.cinemas
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesSection(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
    TicketSaleLoaded state,
  ) {
    if (state.moviesForCinema.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            l10n.noData,
            style: TextStyle(color: theme.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            theme.spacingMd,
            theme.spacingSm,
            theme.spacingMd,
            theme.spacingSm,
          ),
          child: Row(
            children: [
              Text(
                l10n.nowShowing,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${state.moviesForCinema.length}',
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 215,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(
              theme.spacingMd,
              0,
              theme.spacingMd,
              theme.spacingSm,
            ),
            itemCount: state.moviesForCinema.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = state.moviesForCinema[index];
              final isSelected = movie.id == state.selectedMovieId;

              return GestureDetector(
                onTap: () =>
                    context.read<TicketSaleCubit>().selectMovie(movie.id),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Poster Card
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                   ? theme.primary
                                  : theme.borderSubtle,
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                (movie.posterUrl != null &&
                                        movie.posterUrl!.isNotEmpty)
                                    ? AppCachedImage(
                                        imageUrl: movie.posterUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: theme.surfaceVariant,
                                        child: Icon(
                                          LucideIcons.film,
                                          color: theme.textSecondary,
                                          size: 28,
                                        ),
                                      ),
                                if (movie.ageLimit != null &&
                                    movie.ageLimit! > 0)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${movie.ageLimit}+',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (isSelected)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: BoxDecoration(
                                        color: theme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Movie Title
                      Text(
                        movie.title,
                        style: TextStyle(
                          color: isSelected ? theme.primary : theme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Duration
                      Text(
                        l10n.durationMinutes(movie.durationMinutes),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShowtimesContent(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
    TicketSaleLoaded state,
  ) {
    if (state.selectedMovieId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.film,
              size: 48,
              color: theme.textSecondary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.selectMovieReq,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final movieShowtimes = state.cinemaShowtimes
        .where((st) =>
            st.movie?.id == state.selectedMovieId &&
            st.status != 'COMPLETED' &&
            st.status != 'CANCELLED' &&
            st.publicStartTime.isAfter(now))
        .toList();

    if (movieShowtimes.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<TicketSaleCubit>().loadInitialData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 60),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.calendarX,
                    size: 48,
                    color: theme.textSecondary.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noShowtimesFound,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Group by Date string
    final Map<String, List<ShowtimeModel>> grouped = {};
    for (var st in movieShowtimes) {
      final d = FormatUtils.formatDate(st.publicStartTime);
      if (!grouped.containsKey(d)) grouped[d] = [];
      grouped[d]!.add(st);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TicketSaleCubit>().loadInitialData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: grouped.entries.map((entry) {
          final dateStr = entry.key;
          final list = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 4),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendarDays,
                      size: 16,
                      color: theme.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: list
                    .map((st) => _buildShowtimeCard(context, theme, l10n, st))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShowtimeCard(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
    ShowtimeModel st,
  ) {
    final formatStr = st.format.replaceAll('FORMAT_', '');
    final isImax = formatStr.contains('IMAX');
    final is3d = formatStr.contains('3D');
    final formatColor = isImax
        ? const Color(0xFFF59E0B)
        : (is3d ? const Color(0xFF8B5CF6) : theme.info);

    return InkWell(
      onTap: () {
        context.read<TicketSaleCubit>().selectShowtime(st);
        context.push(
          '/ticket-sale/seat-selection',
          extra: context.read<TicketSaleCubit>(),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 158,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time & Format Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatUtils.formatTime(st.publicStartTime),
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: formatColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: formatColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    formatStr,
                    style: TextStyle(
                      color: formatColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Room Name
            Text(
              st.room?.name ?? l10n.emptyRoom,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Seat availability & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (st.totalSeats > 0)
                  Flexible(
                    child: Text(
                      '${st.availableSeats}/${st.totalSeats} ${l10n.seatUnit}',
                      style: TextStyle(
                        color: st.availableSeats > 0
                            ? theme.success
                            : theme.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 6),
                Text(
                  FormatUtils.formatCurrency(st.pricePerSeat ?? 75000),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
