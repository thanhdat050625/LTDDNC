import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shared/mobile_shared.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final Set<String> _selectedSeats = {};
  
  String _customerSearch = '';

  late Map<String, int> _concessions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _concessions = {
      l10n.popcornOnly: 0,
      l10n.largeDrinkOnly: 0,
      l10n.combo1Popcorn2Drinks: 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.seatSelection,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top: Seat Map (55% height)
          Expanded(
            flex: 55,
            child: _buildSeatMap(theme, l10n),
          ),
          
          // Bottom: Order Summary & Customer (45% height)
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
                          _buildCustomerSearch(theme, l10n),
                          SizedBox(height: theme.spacingLg),
                          _buildConcessions(theme, l10n),
                          SizedBox(height: theme.spacingLg),
                          _buildOrderSummary(theme, l10n),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(theme, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap(CineplexColors theme, AppLocalizations l10n) {
    return Container(
      color: theme.background,
      padding: EdgeInsets.all(theme.spacingLg),
      child: Column(
        children: [
          // Screen curve
          Container(
            height: 40,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary.withValues(alpha: 0), theme.primary.withValues(alpha: 0.5), theme.primary.withValues(alpha: 0)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.elliptical(300, 40)),
            ),
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(l10n.screen, style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, letterSpacing: 4)),
            ),
          ),
          
          // Seat Grid (Dummy 8x10)
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 2.0,
              constrained: false,
              child: Padding(
                padding: EdgeInsets.all(theme.spacingLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (r) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(String.fromCharCode(65 + r), style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                      ...List.generate(10, (c) {
                        final seatId = '${String.fromCharCode(65 + r)}${c + 1}';
                        final isSelected = _selectedSeats.contains(seatId);
                        final isBooked = (r == 3 && c == 4) || (r == 3 && c == 5); // some dummy booked
                        
                        Color seatColor = theme.seatStandard;
                        if (isBooked) seatColor = theme.seatBooked;
                        else if (isSelected) seatColor = theme.seatSelected;
                        else if (r > 5) seatColor = theme.seatVIP;
                        
                        return GestureDetector(
                          onTap: isBooked ? null : () {
                            setState(() {
                              if (isSelected) _selectedSeats.remove(seatId);
                              else _selectedSeats.add(seatId);
                            });
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: seatColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${c + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
          
          // Legend
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLegendItem(theme, theme.seatStandard, l10n.seatStandard),
                SizedBox(width: 16),
                _buildLegendItem(theme, theme.seatVIP, l10n.seatVIP),
                SizedBox(width: 16),
                _buildLegendItem(theme, theme.seatSelected, l10n.seatSelected),
                SizedBox(width: 16),
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
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildCustomerSearch(CineplexColors theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectCustomer, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
        SizedBox(height: theme.spacingSm),
        AppTextField(
          hintText: l10n.searchCustomer,
          prefixIcon: LucideIcons.search,
          onChanged: (val) => _customerSearch = val,
        ),
      ],
    );
  }

  Widget _buildConcessions(CineplexColors theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.concessions, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
        SizedBox(height: theme.spacingSm),
        // Dummy concession item
        _buildConcessionItem(theme, 'Bắp rang bơ', 55000),
        _buildConcessionItem(theme, 'Nước ngọt lớn', 45000),
        _buildConcessionItem(theme, 'Combo 1 bắp 2 nước', 115000),
      ],
    );
  }

  Widget _buildConcessionItem(CineplexColors theme, String name, int price) {
    final qty = _concessions[name] ?? 0;
    return Container(
      margin: EdgeInsets.only(bottom: theme.spacingSm),
      padding: EdgeInsets.all(theme.spacingSm),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w500)),
                Text(FormatUtils.formatCurrency(price), style: TextStyle(color: theme.accent, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(LucideIcons.minusCircle, color: theme.textSecondary),
                onPressed: qty > 0 ? () => setState(() => _concessions[name] = qty - 1) : null,
              ),
              Text('$qty', style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(LucideIcons.plusCircle, color: theme.primary),
                onPressed: () => setState(() => _concessions[name] = qty + 1),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CineplexColors theme, AppLocalizations l10n) {
    int ticketPrice = 75000;
    int totalTickets = _selectedSeats.length * ticketPrice;
    
    int totalConcessions = 0;
    _concessions.forEach((name, qty) {
      if (name.contains('Bắp rang')) totalConcessions += qty * 55000;
      else if (name.contains('Nước')) totalConcessions += qty * 45000;
      else totalConcessions += qty * 115000;
    });

    int grandTotal = totalTickets + totalConcessions;

    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: theme.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.orderSummary, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
          Divider(color: theme.textSecondary.withValues(alpha: 0.2)),
          _buildSummaryRow(theme, '${l10n.seatCount(_selectedSeats.length)}', totalTickets),
          if (_selectedSeats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _selectedSeats.join(', '),
                style: TextStyle(color: theme.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          _buildSummaryRow(theme, l10n.concessions, totalConcessions),
          Divider(color: theme.textSecondary.withValues(alpha: 0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalAmount, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(FormatUtils.formatCurrency(grandTotal), style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold, fontSize: 20)),
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
          Text(title, style: TextStyle(color: theme.textSecondary)),
          Text(FormatUtils.formatCurrency(amount), style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(CineplexColors theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
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
              onPressed: _selectedSeats.isEmpty ? null : () {
                context.push('/ticket-sale/checkout');
              },
            ),
          ),
        ],
      ),
    );
  }
}
