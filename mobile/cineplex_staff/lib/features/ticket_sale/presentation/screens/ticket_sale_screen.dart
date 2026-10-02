import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/ticket_sale_cubit.dart';
import '../cubit/ticket_sale_state.dart';

class TicketSaleScreen extends StatelessWidget {
  final Widget? drawer;
  const TicketSaleScreen({super.key, this.drawer});

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
  const _TicketSaleScreenView({this.drawer});

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
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<TicketSaleCubit>().loadInitialData(),
            );
          }

          if (state is TicketSaleLoaded) {
            if (state.cinemas.isEmpty) {
              return Center(
                child: Text(
                  l10n.noData,
                  style: TextStyle(color: theme.textSecondary),
                ),
              );
            }

            return SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top: Movies list (35% height)
                  Expanded(
                    flex: 35,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.surface,
                        border: Border(bottom: BorderSide(color: theme.textSecondary.withValues(alpha: 0.1))),
                      ),
                      child: Column(
                        children: [
                          _buildCinemaSelector(context, theme, l10n, state),
                          Divider(color: theme.textSecondary.withValues(alpha: 0.1), height: 1),
                          Expanded(
                            child: _buildMoviesList(context, theme, l10n, state),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Main content: Showtimes (65% height)
                  Expanded(
                    flex: 65,
                    child: state.selectedMovieId == null
                        ? Center(child: Text(l10n.noData, style: TextStyle(color: theme.textSecondary)))
                        : _buildShowtimes(context, theme, l10n, state),
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

  Widget _buildCinemaSelector(BuildContext context, CineplexColors theme, AppLocalizations l10n, TicketSaleLoaded state) {
    return Padding(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(color: theme.textSecondary.withValues(alpha: 0.2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: state.selectedCinemaId,
            isExpanded: true,
            dropdownColor: theme.surface,
            icon: Icon(LucideIcons.chevronDown, color: theme.textPrimary),
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
            onChanged: (value) {
              if (value != null) {
                context.read<TicketSaleCubit>().selectCinema(value);
              }
            },
            items: state.cinemas
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesList(BuildContext context, CineplexColors theme, AppLocalizations l10n, TicketSaleLoaded state) {
    if (state.moviesForCinema.isEmpty) {
      return Center(
        child: Text(l10n.noData, style: TextStyle(color: theme.textSecondary)),
      );
    }

    return ListView.builder(
      itemCount: state.moviesForCinema.length,
      itemBuilder: (context, index) {
        final movie = state.moviesForCinema[index];
        final isSelected = movie.id == state.selectedMovieId;
        
        return InkWell(
          onTap: () => context.read<TicketSaleCubit>().selectMovie(movie.id),
          child: Container(
            padding: EdgeInsets.all(theme.spacingMd),
            decoration: BoxDecoration(
              color: isSelected ? theme.primary.withValues(alpha: 0.1) : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected ? theme.primary : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                      ? AppCachedImage(imageUrl: movie.posterUrl!, fit: BoxFit.cover)
                      : Icon(LucideIcons.film, color: theme.textSecondary, size: 20),
                ),
                SizedBox(width: theme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        l10n.durationMinutes(movie.durationMinutes),
                        style: TextStyle(color: theme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShowtimes(BuildContext context, CineplexColors theme, AppLocalizations l10n, TicketSaleLoaded state) {
    final movieShowtimes = state.cinemaShowtimes.where((st) => st.movie?.id == state.selectedMovieId).toList();
    if (movieShowtimes.isEmpty) {
      return Center(child: Text(l10n.noData, style: TextStyle(color: theme.textSecondary)));
    }

    // Group by Date string
    final Map<String, List<ShowtimeModel>> grouped = {};
    for (var st in movieShowtimes) {
      final d = FormatUtils.formatDate(st.publicStartTime);
      if (!grouped.containsKey(d)) grouped[d] = [];
      grouped[d]!.add(st);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          final dateStr = entry.key;
          final list = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: AppTextStyles.title.copyWith(color: theme.textPrimary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list.map((st) => _buildShowtimeCard(context, theme, st)).toList(),
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShowtimeCard(BuildContext context, CineplexColors theme, ShowtimeModel st) {
    return GestureDetector(
      onTap: () {
        context.read<TicketSaleCubit>().selectShowtime(st);
        context.push('/ticket-sale/seat-selection', extra: context.read<TicketSaleCubit>());
      },
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          children: [
            Text(
              FormatUtils.formatTime(st.publicStartTime),
              style: TextStyle(
                color: theme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${st.room?.roomType ?? "Standard"} • ${st.format.replaceAll("FORMAT_", "")}',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
