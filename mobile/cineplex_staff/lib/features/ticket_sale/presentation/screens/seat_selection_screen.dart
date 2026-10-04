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
  final Map<int, int> _concessions = {};
  bool _isHoldingSeats = false;
  List<ConcessionProductModel> _concessionProducts = [];

  static const List<Map<String, dynamic>> _catalogConcessions = [
    {'id': 1, 'price': 55000},
    {'id': 2, 'price': 45000},
    {'id': 3, 'price': 115000},
  ];

  String _getConcessionName(int id, AppLocalizations l10n) {
    switch (id) {
      case 1:
        return l10n.posCategoryPopcorn;
      case 2:
        return l10n.defaultDrink;
      case 3:
        return l10n.defaultCombo;
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    for (final item in _catalogConcessions) {
      _concessions[item['id'] as int] = 0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRealConcessions());
  }

  Future<void> _loadRealConcessions() async {
    try {
      final dio = context.read<DioClient>();
      final repo = ConcessionManagementRepository(dio);
      final products = await repo.getAllConcessions();
      if (mounted && products.isNotEmpty) {
        setState(() {
          _concessionProducts = products;
          for (final p in products) {
            _concessions.putIfAbsent(p.id, () => 0);
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.seatSelection,
      body: BlocBuilder<TicketSaleCubit, TicketSaleState>(
        builder: (context, state) {
          final ticketState = state is TicketSaleLoaded ? state : null;
          final selectedSeats = ticketState?.selectedSeats ?? <SeatModel>[];
          final showtime = ticketState?.selectedShowtime;
          final pricePerSeat = showtime?.pricePerSeat?.toInt() ?? 75000;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top: Seat Map (55% height)
              Expanded(
                flex: 55,
                child: _buildSeatMap(context, theme, l10n, ticketState),
              ),

              // Bottom: Order Summary & Concessions (45% height)
              Expanded(
                flex: 45,
                child: Container(
                  color: theme.surface,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(theme.spacingMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildConcessions(theme, l10n),
                              SizedBox(height: theme.spacingLg),
                              _buildOrderSummary(
                                theme,
                                l10n,
                                selectedSeats,
                                pricePerSeat,
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildBottomActions(
                        context,
                        theme,
                        l10n,
                        ticketState,
                        selectedSeats,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeatMap(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
    TicketSaleLoaded? state,
  ) {
    return Container(
      color: theme.background,
      padding: EdgeInsets.all(theme.spacingLg),
      child: Column(
        children: [
          // Screen curve
          Container(
            height: 40,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primary.withValues(alpha: 0),
                  theme.primary.withValues(alpha: 0.5),
                  theme.primary.withValues(alpha: 0),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.elliptical(300, 40),
              ),
            ),
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                l10n.screen,
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),

          // Seat Grid
          Expanded(
            child: Builder(
              builder: (context) {
                if (state == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.seats.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noData,
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  );
                }

                // Group seats by row
                final Map<String, List<SeatModel>> rowMap = {};
                for (final s in state.seats) {
                  if (!rowMap.containsKey(s.row)) {
                    rowMap[s.row] = [];
                  }
                  rowMap[s.row]!.add(s);
                }

                final rows = rowMap.keys.toList()..sort();

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 2.5,
                  constrained: false,
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacingMd),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: rows.map((r) {
                        final rowSeats = rowMap[r]!
                          ..sort((a, b) => a.column.compareTo(b.column));
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              alignment: Alignment.center,
                              child: Text(
                                r,
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...rowSeats.map((seat) {
                              final isSelected = state.selectedSeats.any(
                                (s) => s.seatId == seat.seatId,
                              );
                              final isBooked =
                                  seat.status == SeatStatus.booked ||
                                  seat.status == SeatStatus.held;

                              Color seatColor = theme.seatStandard;
                              if (isBooked) {
                                seatColor = theme.seatBooked;
                              } else if (isSelected) {
                                seatColor = theme.seatSelected;
                              } else if (seat.isCouple) {
                                seatColor = theme.seatVIP;
                              }

                              final textColor = isBooked
                                  ? theme.seatBookedText
                                  : (isSelected
                                        ? Colors.white
                                        : theme.seatText);

                              return GestureDetector(
                                onTap: isBooked
                                    ? null
                                    : () => context
                                          .read<TicketSaleCubit>()
                                          .toggleSeat(seat),
                                child: Container(
                                  width: seat.isCouple ? 70 : 34,
                                  height: 34,
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: seatColor,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    seat.isCouple
                                        ? '${seat.column},${seat.column + 1}'
                                        : '${seat.column}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),

          // Legend
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLegendItem(theme, theme.seatStandard, l10n.seatStandard),
                const SizedBox(width: 14),
                _buildLegendItem(theme, theme.seatVIP, l10n.seatVIP),
                const SizedBox(width: 14),
                _buildLegendItem(theme, theme.seatSelected, l10n.seatSelected),
                const SizedBox(width: 14),
                _buildLegendItem(theme, theme.seatBooked, l10n.seatBooked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(CineplexColors theme, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildConcessions(CineplexColors theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.concessions,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: theme.spacingSm),
        if (_concessionProducts.isNotEmpty)
          ..._concessionProducts.map((p) {
            return _buildConcessionItem(theme, p.id, p.name, p.price.toInt());
          })
        else
          ..._catalogConcessions.map((item) {
            final id = item['id'] as int;
            final name = _getConcessionName(id, l10n);
            final price = item['price'] as int;
            return _buildConcessionItem(theme, id, name, price);
          }),
      ],
    );
  }

  Widget _buildConcessionItem(
    CineplexColors theme,
    int id,
    String name,
    int price,
  ) {
    final qty = _concessions[id] ?? 0;
    return Container(
      margin: EdgeInsets.only(bottom: theme.spacingSm),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingMd,
        vertical: theme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  FormatUtils.formatCurrency(price),
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.minusCircle,
                  color: theme.textSecondary,
                  size: 20,
                ),
                onPressed: qty > 0
                    ? () => setState(() => _concessions[id] = qty - 1)
                    : null,
              ),
              Text(
                '$qty',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.plusCircle,
                  color: theme.primary,
                  size: 20,
                ),
                onPressed: () => setState(() => _concessions[id] = qty + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    CineplexColors theme,
    AppLocalizations l10n,
    List<SeatModel> selectedSeats,
    int pricePerSeat,
  ) {
    final totalTickets = selectedSeats.length * pricePerSeat;

    int totalConcessions = 0;
    if (_concessionProducts.isNotEmpty) {
      for (final p in _concessionProducts) {
        final qty = _concessions[p.id] ?? 0;
        totalConcessions += qty * p.price.toInt();
      }
    } else {
      for (final item in _catalogConcessions) {
        final id = item['id'] as int;
        final price = item['price'] as int;
        final qty = _concessions[id] ?? 0;
        totalConcessions += qty * price;
      }
    }

    final grandTotal = totalTickets + totalConcessions;

    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderSummary,
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Divider(color: theme.borderSubtle),
          _buildSummaryRow(
            theme,
            l10n.seatCount(selectedSeats.length),
            totalTickets,
          ),
          if (selectedSeats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                selectedSeats.map((s) => '${s.row}${s.column}').join(', '),
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          _buildSummaryRow(theme, l10n.concessions, totalConcessions),
          Divider(color: theme.borderSubtle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.totalAmount,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                FormatUtils.formatCurrency(grandTotal),
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(CineplexColors theme, String title, int amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            FormatUtils.formatCurrency(amount),
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
    TicketSaleLoaded? state,
    List<SeatModel> selectedSeats,
  ) {
    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: l10n.cancel,
              isOutlined: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: AppButton(
              text: l10n.continueBtn,
              isLoading: _isHoldingSeats,
              onPressed:
                  (selectedSeats.isEmpty || state?.selectedShowtime == null)
                  ? null
                  : () async {
                      setState(() => _isHoldingSeats = true);
                      try {
                        final success = await context
                            .read<TicketSaleCubit>()
                            .holdSelectedSeats();
                        if (!context.mounted) return;

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.seatHeldByOther),
                              backgroundColor: theme.error,
                            ),
                          );
                          return;
                        }

                        // Collect selected concessions
                        final List<SelectedConcession> concessionsList = [];
                        if (_concessionProducts.isNotEmpty) {
                          for (final p in _concessionProducts) {
                            final qty = _concessions[p.id] ?? 0;
                            if (qty > 0) {
                              concessionsList.add(
                                SelectedConcession(
                                  name: p.name,
                                  productId: p.id,
                                  price: p.price.toInt(),
                                  quantity: qty,
                                ),
                              );
                            }
                          }
                        } else {
                          for (final item in _catalogConcessions) {
                            final id = item['id'] as int;
                            final qty = _concessions[id] ?? 0;
                            if (qty > 0) {
                              concessionsList.add(
                                SelectedConcession(
                                  name: _getConcessionName(id, l10n),
                                  productId: item['id'] as int,
                                  price: item['price'] as int,
                                  quantity: qty,
                                ),
                              );
                            }
                          }
                        }

                        final args = CheckoutArgs(
                          showtime: state!.selectedShowtime!,
                          selectedSeats: selectedSeats,
                          concessions: concessionsList,
                        );

                        context.push('/ticket-sale/checkout', extra: args);
                      } finally {
                        if (mounted) setState(() => _isHoldingSeats = false);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
