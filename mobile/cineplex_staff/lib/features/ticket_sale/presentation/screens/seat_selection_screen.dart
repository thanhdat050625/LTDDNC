import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

import '../../data/models/checkout_args.dart';
import '../cubit/ticket_sale_cubit.dart';
import '../cubit/ticket_sale_state.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  bool _isHoldingSeats = false;

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: l10n.seatSelection,
      body: BlocBuilder<TicketSaleCubit, TicketSaleState>(
        builder: (context, state) {
          final ticketState = state is TicketSaleLoaded ? state : null;
          final selectedSeats = ticketState?.selectedSeats ?? <SeatModel>[];
          final showtime = ticketState?.selectedShowtime;
          final pricePerSeat = showtime?.pricePerSeat?.toInt() ?? 75000;
          final totalPrice = selectedSeats.length * pricePerSeat;

          if (ticketState == null) {
            return const Center(child: AppLoading());
          }

          if (ticketState.seats.isEmpty) {
            return Center(
              child: AppEmptyView(
                icon: Icons.event_seat_outlined,
                title: l10n.noData,
              ),
            );
          }

          final room = showtime?.room;
          final int rows = room?.rows ?? 10;
          int columns = room?.columns ?? 10;
          if (ticketState.seats.isNotEmpty) {
            final maxCol = ticketState.seats
                .map((s) => s.column)
                .reduce((a, b) => a > b ? a : b);
            if (maxCol > columns) columns = maxCol;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Movie & Showtime Header Info
              if (showtime != null)
                _buildHeader(theme, l10n, showtime),

              // 2. Screen curved indicator & glow effect
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 10.0, 28.0, 6.0),
                child: Column(
                  children: [
                    CustomPaint(
                      size: const Size(double.infinity, 24),
                      painter: ScreenPainter(color: theme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.seatLayoutTitle,
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w700,
                        color: theme.textSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Interactive Seat Map (Shared SeatLayoutWidget)
              Expanded(
                child: SeatLayoutWidget(
                  seats: ticketState.seats,
                  selectedSeatIds: selectedSeats.map((s) => s.seatId).toList(),
                  rows: rows,
                  columns: columns,
                  onSeatTap: (seatId) {
                    final seat = ticketState.seats.firstWhere(
                      (s) => s.seatId == seatId,
                    );
                    context.read<TicketSaleCubit>().toggleSeat(seat);
                  },
                ),
              ),

              // 4. Legend
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SeatLegend(),
              ),

              // 5. Bottom Sticky Order Panel
              _buildBottomPanel(
                context,
                theme,
                l10n,
                isDark,
                showtime,
                selectedSeats,
                totalPrice,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    CineplexColors theme,
    AppLocalizations l10n,
    ShowtimeModel showtime,
  ) {
    final movieTitle = showtime.movie?.title ?? l10n.defaultMovieTitle;
    final roomName = showtime.room?.name ?? '1';
    final startTimeStr = FormatUtils.formatTime(showtime.publicStartTime);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingLg,
        vertical: theme.spacingSm,
      ),
      color: theme.surface,
      child: Row(
        children: [
          Icon(LucideIcons.film, color: theme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movieTitle,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.roomPrefix(roomName)} • $startTimeStr',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
    bool isDark,
    ShowtimeModel? showtime,
    List<SeatModel> selectedSeats,
    int totalPrice,
  ) {
    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selected seats chips & count row
            if (selectedSeats.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.seatCount(selectedSeats.length),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: selectedSeats.map((s) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: _buildSeatBadge(theme, s.label),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Total price & Continue button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalAmount,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        FormatUtils.formatCurrency(totalPrice),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: l10n.continueBtn,
                  width: 135,
                  isLoading: _isHoldingSeats,
                  onPressed: (selectedSeats.isEmpty || _isHoldingSeats || showtime == null)
                      ? null
                      : () => _onContinue(context, showtime, selectedSeats),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatBadge(CineplexColors theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _onContinue(
    BuildContext context,
    ShowtimeModel showtime,
    List<SeatModel> selectedSeats,
  ) async {
    setState(() => _isHoldingSeats = true);
    try {
      final cubit = context.read<TicketSaleCubit>();
      final success = await cubit.holdSelectedSeats();
      if (!context.mounted) return;

      if (!success) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.seatHeldByOther ?? ''),
            backgroundColor: CineplexColors.of(context).error,
          ),
        );
        return;
      }

      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: selectedSeats,
      );
      context.push('/ticket-sale/concessions', extra: args);
    } finally {
      if (mounted) {
        setState(() => _isHoldingSeats = false);
      }
    }
  }
}
