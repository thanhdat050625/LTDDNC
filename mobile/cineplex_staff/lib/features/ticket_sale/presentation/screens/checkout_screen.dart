import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/checkout_args.dart';

class CheckoutScreen extends StatefulWidget {
  final CheckoutArgs? args;

  const CheckoutScreen({super.key, this.args});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'CASH';
  bool _isSubmitting = false;
  int _receivedAmount = 0;
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _customerSearchController = TextEditingController();

  UserModel? _customer;
  bool _isSearchingCustomer = false;
  int _usedPoints = 0;

  @override
  void initState() {
    super.initState();
    _customer = widget.args?.customer;
    final total = widget.args?.grandTotal ?? 0;
    _receivedAmount = total;
    _cashReceivedController.text = total > 0 ? '$total' : '';
    _usedPoints = widget.args?.pointsToUse ?? 0;
    if (_usedPoints > 0) {
      _pointsController.text = '$_usedPoints';
    }
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _pointsController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  int get _ticketTotal => widget.args?.ticketTotal ?? 0;
  int get _concessionTotal => widget.args?.concessionTotal ?? 0;
  int get _grandTotal {
    final base = _ticketTotal + _concessionTotal - _usedPoints;
    return base > 0 ? base : 0;
  }

  int get _cashChange {
    final diff = _receivedAmount - _grandTotal;
    return diff > 0 ? diff : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final args = widget.args;

    final methods = [
      {
        'id': 'CASH',
        'label': l10n.cash,
        'desc': l10n.cashPaymentDesc,
        'icon': LucideIcons.banknote,
        'color': theme.success,
      },
      {
        'id': 'MOMO',
        'label': l10n.momo,
        'desc': l10n.momoPaymentDesc,
        'icon': LucideIcons.wallet,
        'color': theme.accent,
      },
      {
        'id': 'VNPAY',
        'label': l10n.vnpay,
        'desc': l10n.vnpayPaymentDesc,
        'icon': LucideIcons.creditCard,
        'color': theme.primary,
      },
    ];

    return AppScaffold(
      title: l10n.checkout,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top: Payment Methods & Cash options
          Expanded(
            flex: 50,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(theme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.paymentMethod,
                    style: AppTextStyles.title.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: theme.spacingMd),
                  ...methods.map((m) => _buildMethodCard(theme, m)),
                  SizedBox(height: theme.spacingMd),

                  // Cash Received Calculator (Visible when CASH is selected)
                  if (_selectedMethod == 'CASH') ...[
                    _buildCashCalculator(theme, l10n),
                    SizedBox(height: theme.spacingMd),
                  ],

                  // Loyalty Points Card
                  _buildLoyaltyCard(theme, l10n),
                ],
              ),
            ),
          ),

          // Bottom: Summary & Submit Payment
          Expanded(
            flex: 50,
            child: Container(
              color: theme.surface,
              padding: EdgeInsets.all(theme.spacingLg),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.orderSummary,
                            style: AppTextStyles.title.copyWith(
                              color: theme.textPrimary,
                            ),
                          ),
                          SizedBox(height: theme.spacingMd),

                          // Movie Info
                          if (args != null)
                            _buildMovieSummary(theme, l10n, args)
                          else
                            Text(
                              l10n.noData,
                              style: TextStyle(color: theme.textSecondary),
                            ),

                          SizedBox(height: theme.spacingMd),
                          Divider(color: theme.borderSubtle),
                          SizedBox(height: theme.spacingSm),

                          // Breakdown rows
                          _buildBreakdownRow(
                            theme,
                            l10n.movieTicket(args?.selectedSeats.length ?? 0),
                            _ticketTotal,
                          ),
                          if (_concessionTotal > 0)
                            _buildBreakdownRow(
                              theme,
                              l10n.concessions,
                              _concessionTotal,
                            ),
                          if (_usedPoints > 0)
                            _buildBreakdownRow(
                              theme,
                              l10n.discountPointsTitle,
                              -_usedPoints,
                              isDiscount: true,
                            ),

                          SizedBox(height: theme.spacingSm),
                          Divider(color: theme.borderSubtle),
                          SizedBox(height: theme.spacingSm),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.totalAmount.toUpperCase(),
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                FormatUtils.formatCurrency(_grandTotal),
                                style: TextStyle(
                                  color: theme.accent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: l10n.payNow,
                      isLoading: _isSubmitting,
                      onPressed: (_isSubmitting || args == null)
                          ? null
                          : () => _processCheckout(context, args, theme, l10n),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSummary(
    CineplexColors theme,
    AppLocalizations l10n,
    CheckoutArgs args,
  ) {
    final movie = args.showtime.movie;
    final movieTitle = movie?.title ?? l10n.defaultMovieTitle;
    final roomName = args.showtime.room?.name ?? '1';
    final startTimeStr = FormatUtils.formatTime(args.showtime.publicStartTime);

    return Row(
      children: [
        Container(
          width: 55,
          height: 75,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(theme.radiusSm),
            border: Border.all(color: theme.borderSubtle),
          ),
          child: Icon(LucideIcons.film, color: theme.primary, size: 28),
        ),
        SizedBox(width: theme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movieTitle,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${l10n.roomPrefix(roomName)} • $startTimeStr',
                style: TextStyle(color: theme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: args.selectedSeats.map((s) {
                  return _buildSeatChip(theme, '${s.row}${s.column}');
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(CineplexColors theme, Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    final color = method['color'] as Color;

    return AppCard(
      onTap: () => setState(() => _selectedMethod = method['id'] as String),
      backgroundColor: isSelected
          ? color.withValues(alpha: 0.1)
          : theme.surface,
      margin: EdgeInsets.only(bottom: theme.spacingSm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(method['icon'] as IconData, color: color, size: 24),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method['label'] as String,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  method['desc'] as String,
                  style: TextStyle(color: theme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(LucideIcons.checkCircle2, color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildCashCalculator(CineplexColors theme, AppLocalizations l10n) {
    return AppCard(
      backgroundColor: theme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.cashReceived,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${l10n.cashChange}: ${FormatUtils.formatCurrency(_cashChange)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.success,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _cashReceivedController,
            hintText: l10n.enterCashReceivedHint,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final parsed =
                  int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              setState(() => _receivedAmount = parsed);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickCashPill(theme, l10n.exactAmount, _grandTotal),
              const SizedBox(width: 6),
              _buildQuickCashPill(theme, '+50k', _grandTotal + 50000),
              const SizedBox(width: 6),
              _buildQuickCashPill(theme, '+100k', _grandTotal + 100000),
              const SizedBox(width: 6),
              _buildQuickCashPill(theme, '+500k', 500000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCashPill(CineplexColors theme, String label, int amount) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _receivedAmount = amount;
            _cashReceivedController.text = '$amount';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltyCard(CineplexColors theme, AppLocalizations l10n) {
    final customer = _customer;
    final orderSubtotal = _ticketTotal + _concessionTotal;
    final maxAllowedDiscount = (orderSubtotal * 0.2).floor();

    return AppCard(
      backgroundColor: theme.accent.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(LucideIcons.star, color: theme.accent, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.loyaltyPoints,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (customer != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _customer = null;
                      _usedPoints = 0;
                      _pointsController.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    l10n.posChangeCustomer,
                    style: TextStyle(fontSize: 12, color: theme.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // If no customer is identified yet: provide lookup input
          if (customer == null) ...[
            Text(
              l10n.searchCustomerHint,
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _customerSearchController,
                    hintText: l10n.posSearchCustomerHint,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: l10n.posSearchCustomer,
                  isLoading: _isSearchingCustomer,
                  backgroundColor: theme.primary,
                  textColor: Colors.white,
                  width: 90,
                  onPressed: _isSearchingCustomer
                      ? null
                      : () => _searchCustomer(theme, l10n),
                ),
              ],
            ),
          ] else ...[
            // Customer is identified: display real customer info and points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(8),
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
                          customer.fullName.isNotEmpty
                              ? customer.fullName
                              : customer.email,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${FormatUtils.formatNumber(customer.loyaltyPoints)} ${l10n.pointsSuffix}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (customer.email.isNotEmpty && customer.fullName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      customer.email,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // If points are currently applied: show active badge and Cancel button
            if (_usedPoints > 0) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: theme.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(LucideIcons.checkCircle2,
                                  size: 16, color: theme.success),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  l10n.posUsingPointsBadge(
                                      FormatUtils.formatNumber(_usedPoints)),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.success,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _usedPoints = 0;
                              _pointsController.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            l10n.posCancelPoints,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.posPointsAvailable,
                            style: TextStyle(
                                fontSize: 11, color: theme.textSecondary)),
                        Text(
                          '${FormatUtils.formatNumber(customer.loyaltyPoints)} ${l10n.pointsSuffix}',
                          style: TextStyle(
                              fontSize: 11, color: theme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.posPointsRemaining,
                            style: TextStyle(
                                fontSize: 11, color: theme.textSecondary)),
                        Text(
                          '${FormatUtils.formatNumber(customer.loyaltyPoints - _usedPoints)} ${l10n.pointsSuffix}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.posDiscountValue,
                            style:
                                TextStyle(fontSize: 11, color: theme.success)),
                        Text(
                          FormatUtils.formatCurrency(_usedPoints),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Prompt to enter points
              Text(
                l10n.posCustomerLoyaltyBalance(
                    FormatUtils.formatNumber(customer.loyaltyPoints)),
                style: TextStyle(color: theme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _pointsController,
                      hintText: l10n.enterPoints,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: l10n.usePoints,
                    backgroundColor: theme.primary,
                    textColor: Colors.white,
                    width: 100,
                    onPressed: () {
                      final input = _pointsController.text.trim();
                      final pts =
                          int.tryParse(input.replaceAll(RegExp(r'[^0-9]'), ''));
                      if (pts == null || pts <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.posPointsInvalid),
                            backgroundColor: theme.error,
                          ),
                        );
                        return;
                      }
                      if (pts > customer.loyaltyPoints) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.posPointsExceedBalance),
                            backgroundColor: theme.error,
                          ),
                        );
                        return;
                      }
                      if (maxAllowedDiscount > 0 && pts > maxAllowedDiscount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.posPointsExceedLimit),
                            backgroundColor: theme.error,
                          ),
                        );
                        return;
                      }
                      // Valid! Update state locally ONLY (No API call, no DB deduction yet)
                      setState(() {
                        _usedPoints = pts;
                      });
                    },
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _searchCustomer(
    CineplexColors theme,
    AppLocalizations l10n,
  ) async {
    final query = _customerSearchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearchingCustomer = true);
    final bookingRepo = BookingManagementRepository(context.read<DioClient>());
    try {
      final results = await bookingRepo.searchCustomers(query);
      if (!mounted) return;
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.posCustomerNotFound),
            backgroundColor: theme.error,
          ),
        );
      } else {
        setState(() {
          _customer = results.first;
          _usedPoints = 0;
          _pointsController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: theme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearchingCustomer = false);
    }
  }

  Widget _buildSeatChip(CineplexColors theme, String seat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        seat,
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    CineplexColors theme,
    String title,
    int amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDiscount ? theme.success : theme.textSecondary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            FormatUtils.formatCurrency(amount),
            style: TextStyle(
              color: isDiscount ? theme.success : theme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(
    BuildContext context,
    CheckoutArgs args,
    CineplexColors theme,
    AppLocalizations l10n,
  ) async {
    if (_selectedMethod == 'CASH' && _receivedAmount < _grandTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.insufficientCashReceived),
          backgroundColor: theme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final bookingRepo = BookingManagementRepository(context.read<DioClient>());

    try {
      // Step 1: Create staff offline booking
      final seatIds = args.selectedSeats.map((s) => s.seatId).toList();
      final concessionsPayload = args.concessions
          .map((c) => {'productId': c.productId, 'quantity': c.quantity})
          .toList();

      final booking = await bookingRepo.createStaffBooking(
        args.showtime.id,
        seatIds,
        customerId: _customer?.id,
        concessions: concessionsPayload.isNotEmpty ? concessionsPayload : null,
        pointsToUse: _usedPoints > 0 ? _usedPoints : null,
        source: 'OFFLINE',
      );

      final bookingCode = booking.bookingCode.isNotEmpty
          ? booking.bookingCode
          : 'BK-${booking.id}';

      // Step 2: Checkout payment
      final checkoutRes = await bookingRepo.checkoutPayment(
        bookingId: booking.id,
        method: _selectedMethod,
      );

      if (!context.mounted) return;

      final isOnline = _selectedMethod != 'CASH';
      final paymentRequired = checkoutRes is Map &&
          (checkoutRes['paymentRequired'] == true ||
              (checkoutRes['payUrl'] != null &&
                  checkoutRes['payUrl'].toString().isNotEmpty));

      if (isOnline && paymentRequired) {
        // Online Gateway (MoMo / VNPay)
        final payUrl = checkoutRes['payUrl']?.toString() ?? '';
        if (payUrl.isNotEmpty) {
          try {
            await launchUrl(Uri.parse(payUrl),
                mode: LaunchMode.externalApplication);
          } catch (_) {}
        }
        if (!context.mounted) return;
        _showWaitingPaymentDialog(
          context,
          bookingId: booking.id,
          bookingCode: bookingCode,
          payUrl: payUrl,
          theme: theme,
          l10n: l10n,
        );
      } else {
        // CASH payment - Completed immediately
        _showSuccessDialog(context, bookingCode, theme, l10n);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: theme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showWaitingPaymentDialog(
    BuildContext context, {
    required int bookingId,
    required String bookingCode,
    required String payUrl,
    required CineplexColors theme,
    required AppLocalizations l10n,
  }) {
    bool isChecking = false;
    String statusMessage = l10n.posPaymentPendingHint;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> checkStatus() async {
            if (isChecking) return;
            setDialogState(() => isChecking = true);
            try {
              final bookingRepo =
                  BookingManagementRepository(context.read<DioClient>());
              final res = await bookingRepo.getPaymentStatus(bookingId);
              final status = res['status']?.toString();

              if (!dialogCtx.mounted) return;

              if (status == 'PAID') {
                Navigator.pop(dialogCtx);
                _showSuccessDialog(context, bookingCode, theme, l10n);
              } else if (status == 'FAILED') {
                setDialogState(() {
                  statusMessage = l10n.posPaymentFailedPrompt;
                });
              } else if (status == 'EXPIRED') {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.paymentExpired),
                    backgroundColor: theme.error,
                  ),
                );
              } else {
                setDialogState(() {
                  statusMessage = l10n.posPaymentPendingHint;
                });
              }
            } catch (_) {
              // ignore network blips during status check
            } finally {
              if (dialogCtx.mounted) {
                setDialogState(() => isChecking = false);
              }
            }
          }

          return AlertDialog(
            backgroundColor: theme.surface,
            title: Row(
              children: [
                Icon(LucideIcons.loader2, color: theme.accent, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedMethod == 'MOMO'
                        ? l10n.posWaitingMomoPayment
                        : l10n.paymentPending,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.posOrderSuccessPrompt(bookingCode),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.totalAmount}: ${FormatUtils.formatCurrency(_grandTotal)}',
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  statusMessage,
                  style: TextStyle(color: theme.textSecondary, fontSize: 13),
                ),
                if (payUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(LucideIcons.externalLink, size: 16),
                      label: Text(
                        _selectedMethod == 'MOMO'
                            ? l10n.posOpenMomo
                            : l10n.paymentMethod,
                      ),
                      onPressed: () {
                        launchUrl(
                          Uri.parse(payUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.posPaymentCancelledPrompt),
                      backgroundColor: theme.warning,
                    ),
                  );
                },
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: theme.textMuted),
                ),
              ),
              ElevatedButton(
                onPressed: isChecking ? null : checkStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                ),
                child: isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.posCheckPaymentStatus),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    String bookingCode,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Row(
          children: [
            Icon(LucideIcons.checkCircle2, color: theme.success, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.paymentSuccess,
              style: TextStyle(
                color: theme.success,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.posOrderSuccessPrompt(bookingCode),
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.totalAmount}: ${FormatUtils.formatCurrency(_grandTotal)}',
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
            if (_selectedMethod == 'CASH' && _cashChange > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${l10n.cashChange}: ${FormatUtils.formatCurrency(_cashChange)}',
                  style: TextStyle(
                    color: theme.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.go('/pos');
            },
            child: Text(
              l10n.ok,
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
