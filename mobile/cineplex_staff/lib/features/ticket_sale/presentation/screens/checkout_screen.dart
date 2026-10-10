import 'dart:math' as math;
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
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();

  UserModel? _customer;
  bool _isSearchingCustomer = false;
  int _usedPoints = 0;
  String? _appliedPromoCode;
  int _discountAmount = 0;
  bool _isCheckingPromo = false;

  @override
  void initState() {
    super.initState();
    _customer = widget.args?.customer;
    _appliedPromoCode = widget.args?.promotionCode;
    _discountAmount = widget.args?.discountAmount ?? 0;
    if (_appliedPromoCode != null) {
      _promoCodeController.text = _appliedPromoCode!;
    }
    final total = widget.args?.grandTotal ?? 0;
    _receivedAmount = total;
    _cashReceivedController.text = total > 0 ? '$total' : '';
    _usedPoints = widget.args?.pointsToUse ?? 0;
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _customerSearchController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  int get _ticketTotal => widget.args?.ticketTotal ?? 0;
  int get _concessionTotal => widget.args?.concessionTotal ?? 0;
  int get _grandTotal {
    final base = _ticketTotal + _concessionTotal - _usedPoints - _discountAmount;
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
        'id': 'VNPAY',
        'label': l10n.vnpay,
        'desc': l10n.vnpayPaymentDesc,
        'logoAsset': 'assets/images/vnpay_icon.png',
        'icon': LucideIcons.creditCard,
        'color': theme.primary,
      },
      {
        'id': 'MOMO',
        'label': l10n.momo,
        'desc': l10n.momoPaymentDesc,
        'logoAsset': 'assets/images/momo_icon.png',
        'icon': LucideIcons.wallet,
        'color': const Color(0xFFA50064),
      },
    ];

    return AppScaffold(
      title: l10n.checkout,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Single Unified Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(theme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Order Summary Section
                  Text(
                    l10n.orderSummary,
                    style: AppTextStyles.title.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: theme.spacingSm),

                  // Movie Info
                  if (args != null)
                    _buildMovieSummary(theme, l10n, args)
                  else
                    Text(
                      l10n.noData,
                      style: TextStyle(color: theme.textSecondary),
                    ),

                  SizedBox(height: theme.spacingSm),
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
                  if (_discountAmount > 0)
                    _buildBreakdownRow(
                      theme,
                      l10n.discountAmount,
                      -_discountAmount,
                      isDiscount: true,
                    ),
                  if (_usedPoints > 0)
                    _buildBreakdownRow(
                      theme,
                      l10n.discountPointsTitle,
                      -_usedPoints,
                      isDiscount: true,
                    ),

                  SizedBox(height: theme.spacingMd),

                  // 2. Voucher / Promo Card
                  _buildVoucherCard(theme, l10n),
                  const SizedBox(height: 10),

                  // 3. Loyalty Points Card
                  _buildLoyaltyCard(theme, l10n),
                  SizedBox(height: theme.spacingMd),

                  // 3. Payment Methods
                  Text(
                    l10n.paymentMethod,
                    style: AppTextStyles.title.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: theme.spacingSm),
                  ...methods.map((m) => _buildMethodCard(theme, m)),
                  SizedBox(height: theme.spacingSm),

                  // Cash Received Calculator (Visible when CASH is selected)
                  if (_selectedMethod == 'CASH') ...[
                    _buildCashCalculator(theme, l10n),
                    SizedBox(height: theme.spacingMd),
                  ],
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar: Total & Pay Now Button
          Container(
            padding: EdgeInsets.all(theme.spacingLg),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(top: BorderSide(color: theme.borderSubtle)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  if (_customer != null && _grandTotal > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.sparkles, color: theme.warning, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.paymentEarnedPointsNotice((_grandTotal * 0.1).floor()),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: theme.spacingMd),
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
    final logoAsset = method['logoAsset'] as String?;

    return AppCard(
      onTap: () => setState(() => _selectedMethod = method['id'] as String),
      backgroundColor: isSelected
          ? color.withValues(alpha: 0.1)
          : theme.surface,
      margin: EdgeInsets.only(bottom: theme.spacingSm),
      child: Row(
        children: [
          if (logoAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: method['id'] == 'MOMO'
                      ? const Color(0xFFA50064)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.borderSubtle,
                    width: 0.5,
                  ),
                ),
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      method['icon'] as IconData,
                      color: method['id'] == 'MOMO' ? Colors.white : theme.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(method['icon'] as IconData, color: color, size: 24),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  width: 80,
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

            // 1-Tap Switch Toggle for Loyalty Points (Auto-calculated up to max 20%)
            if (customer.loyaltyPoints > 0 && maxAllowedDiscount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: theme.warning, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paymentUseLoyaltyPoints(math.min(customer.loyaltyPoints, maxAllowedDiscount)),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _usedPoints > 0
                                ? '${l10n.posDiscountValue}: -${FormatUtils.formatCurrency(_usedPoints)}'
                                : l10n.maxPointsDiscount,
                            style: TextStyle(
                              fontSize: 11,
                              color: _usedPoints > 0 ? theme.success : theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _usedPoints > 0,
                      activeThumbColor: theme.primary,
                      activeTrackColor: theme.primary.withValues(alpha: 0.5),
                      onChanged: (val) {
                        setState(() {
                          _usedPoints = val ? math.min(customer.loyaltyPoints, maxAllowedDiscount) : 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

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
                          '-${FormatUtils.formatCurrency(_usedPoints)}',
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
          final maxAllowed = ((_ticketTotal + _concessionTotal) * 0.2).floor();
          _usedPoints = math.min(results.first.loyaltyPoints, maxAllowed);
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

  Widget _buildVoucherCard(CineplexColors theme, AppLocalizations l10n) {
    final isApplied = _appliedPromoCode != null;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: isApplied
          ? theme.primary.withValues(alpha: 0.08)
          : theme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isApplied ? LucideIcons.checkCircle2 : LucideIcons.ticket,
                color: theme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.promotionCode,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isApplied)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _appliedPromoCode = null;
                      _discountAmount = 0;
                      _promoCodeController.clear();
                      _cashReceivedController.text = '$_grandTotal';
                      _receivedAmount = _grandTotal;
                    });
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    l10n.removePromotion,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          if (isApplied) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _appliedPromoCode!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.textPrimary,
                        ),
                      ),
                      Text(
                        l10n.promotionApplied,
                        style: TextStyle(fontSize: 11, color: theme.success),
                      ),
                    ],
                  ),
                  Text(
                    '-${FormatUtils.formatCurrency(_discountAmount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.success,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _promoCodeController,
                    hintText: l10n.promotionCode,
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: l10n.applyPromotion,
                  isLoading: _isCheckingPromo,
                  backgroundColor: theme.primary,
                  textColor: Colors.white,
                  width: 90,
                  onPressed: _isCheckingPromo
                      ? null
                      : () => _applyPromotionCode(
                            _promoCodeController.text.trim(),
                            theme,
                            l10n,
                          ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showVoucherPicker(context, theme, l10n),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(LucideIcons.tags, color: theme.primary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.paymentSelectVoucher,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.primary,
                        ),
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: theme.primary, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showVoucherPicker(
    BuildContext context,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return FutureBuilder<List<PromotionModel>>(
          future: PromotionManagementRepository(context.read<DioClient>())
              .getActivePromotions(),
          builder: (context, snapshot) {
            final promos = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.paymentAvailableVouchers,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.x, color: theme.textSecondary),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: AppLoading(),
                        ),
                      )
                    else if (promos.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            l10n.paymentNoVouchers,
                            style: TextStyle(color: theme.textSecondary),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.45,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: promos.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final promo = promos[index];
                            final discountText = promo.discountType.toUpperCase() == 'PERCENT'
                                ? '${promo.discountValue}%'
                                : FormatUtils.formatCurrency(promo.discountValue.toInt());

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      LucideIcons.tag,
                                      color: theme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          promo.code,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: theme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          promo.description ?? l10n.posDiscountValue,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          discountText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppButton(
                                    text: l10n.applyPromotion,
                                    width: 80,
                                    onPressed: () {
                                      Navigator.pop(bottomSheetContext);
                                      _promoCodeController.text = promo.code;
                                      _applyPromotionCode(
                                        promo.code,
                                        theme,
                                        l10n,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _applyPromotionCode(
    String code,
    CineplexColors theme,
    AppLocalizations l10n,
  ) async {
    if (code.isEmpty) return;
    setState(() => _isCheckingPromo = true);

    try {
      final dio = context.read<DioClient>();
      final promoRepo = PromotionManagementRepository(dio);
      final subtotal = _ticketTotal + _concessionTotal;
      final movieId = widget.args?.showtime.movieId;

      final res = await promoRepo.checkPromotion(
        code,
        movieId: movieId,
        orderTotal: subtotal,
      );

      final data = (res is Map && res.containsKey('data')) ? res['data'] : res;
      if (data is Map<String, dynamic>) {
        final calcDiscount = (data['discountAmount'] as num?)?.toInt() ??
            _calculateLocalDiscount(data, subtotal);
        setState(() {
          _appliedPromoCode = code;
          _discountAmount = calcDiscount;
          _cashReceivedController.text = '$_grandTotal';
          _receivedAmount = _grandTotal;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.promotionApplied),
              backgroundColor: theme.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.promotionInvalid),
            backgroundColor: theme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingPromo = false);
    }
  }

  int _calculateLocalDiscount(Map<String, dynamic> promo, int subtotal) {
    final type = promo['discountType']?.toString().toUpperCase();
    final value = (promo['discountValue'] as num?)?.toDouble() ?? 0.0;
    if (type == 'PERCENT') {
      return ((subtotal * value) / 100).floor();
    } else {
      return value.toInt();
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
      // Step 1: Refresh seat hold for this staff member, then create offline booking
      final seatIds = args.selectedSeats.map((s) => s.seatId).toList();
      try {
        await bookingRepo.holdSeats(args.showtime.id, seatIds);
      } catch (_) {
        // If seat is already held by this staff member, proceed to createStaffBooking
      }

      final concessionsPayload = args.concessions
          .map((c) => {'productId': c.productId, 'quantity': c.quantity})
          .toList();

      final booking = await bookingRepo.createStaffBooking(
        args.showtime.id,
        seatIds,
        customerId: _customer?.id,
        concessions: concessionsPayload.isNotEmpty ? concessionsPayload : null,
        pointsToUse: _usedPoints > 0 ? _usedPoints : null,
        promotionCode: _appliedPromoCode,
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
        context.go(
          '/ticket-sale/payment-result/${booking.id}',
          extra: {
            'bookingId': '${booking.id}',
            'bookingCode': bookingCode,
            'status': 'PAID',
            'totalAmount': _grandTotal,
            'method': 'CASH',
            'cashReceived': _receivedAmount,
            'cashChange': _cashChange,
            'customer': _customer,
            'pointsUsed': _usedPoints,
            'pointsEarned': (_grandTotal * 0.1).floor(),
            'showtime': args.showtime,
            'selectedSeats': args.selectedSeats,
            'concessions': args.concessions,
          },
        );
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
                context.go(
                  '/ticket-sale/payment-result/$bookingId',
                  extra: {
                    'bookingId': '$bookingId',
                    'bookingCode': bookingCode,
                    'status': 'PAID',
                    'totalAmount': _grandTotal,
                    'method': _selectedMethod,
                    'customer': _customer,
                    'pointsUsed': _usedPoints,
                    'pointsEarned': (_grandTotal * 0.1).floor(),
                    'showtime': widget.args?.showtime,
                    'selectedSeats': widget.args?.selectedSeats,
                    'concessions': widget.args?.concessions,
                  },
                );
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
}
