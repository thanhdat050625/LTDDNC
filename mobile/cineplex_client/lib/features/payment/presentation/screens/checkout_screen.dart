import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/models/payment_model.dart';
import '../cubit/payment_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  final String bookingId;
  final CheckoutScreenArgs? args;
  const CheckoutScreen({super.key, required this.bookingId, this.args});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'VNPAY';
  final TextEditingController _promoCtrl = TextEditingController();
  CheckoutPrepared? _lastPrepared;

  @override
  void initState() {
    super.initState();
    if ((widget.bookingId == '0' || widget.bookingId.isEmpty) && widget.args != null) {
      context.read<PaymentCubit>().prepareCheckoutDraft(widget.args!);
    } else {
      context.read<PaymentCubit>().prepareCheckout(widget.bookingId);
    }
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  void _showVoucherPicker(
    BuildContext context,
    List<PromotionModel> promotions,
    CineplexColors colors,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        color: colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colors.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (promotions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        l10n.paymentNoVouchers,
                        style: TextStyle(color: colors.textSecondary, fontSize: 14),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: promotions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final promo = promotions[index];
                        final discountText = promo.discountType == 'PERCENTAGE'
                            ? '-${promo.discountValue}%'
                            : '-${FormatUtils.formatCurrency(promo.discountValue.toInt())}';

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  discountText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      promo.code,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    if (promo.description != null && promo.description!.isNotEmpty)
                                      Text(
                                        promo.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: () {
                                  Navigator.pop(bottomSheetContext);
                                  _promoCtrl.text = promo.code;
                                  context.read<PaymentCubit>().applyPromotion(widget.bookingId, promo.code);
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(l10n.applyPromotion),
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    final paymentMethods = [
      {'id': 'VNPAY', 'name': l10n.paymentMethodVnpay, 'icon': Icons.qr_code_2_outlined, 'color': const Color(0xFF005BAA)},
      {'id': 'MOMO', 'name': l10n.paymentMethodMomo, 'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFFA50064)},
    ];

    return AppScaffold(
      title: l10n.checkout,
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) async {
          if (state is PaymentUrlReady) {
            final effectiveBookingId = state.bookingId ?? widget.bookingId;
            final bookingCode = state.bookingCode ?? _lastPrepared?.data.bookingCode ?? '';
            final totalAmount = _lastPrepared?.data.totalAmount ?? 0;

            if (state.payUrl.isNotEmpty) {
              try {
                launchUrl(
                  Uri.parse(state.payUrl),
                  mode: LaunchMode.externalApplication,
                );
              } catch (_) {}
            }

            if (!context.mounted) return;
            _showWaitingPaymentDialog(
              context,
              bookingId: effectiveBookingId,
              bookingCode: bookingCode,
              payUrl: state.payUrl,
              totalAmount: totalAmount,
              colors: colors,
              l10n: l10n,
            );
          } else if (state is PaymentSuccess) {
            context.go('/payment-result/${widget.bookingId}');
          } else if (state is PaymentFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: AppLoading());
          }

          if (state is PaymentFailed) {
            return AppErrorView(
              message: state.message,
              onRetry: () {
                if ((widget.bookingId == '0' || widget.bookingId.isEmpty) && widget.args != null) {
                  context.read<PaymentCubit>().prepareCheckoutDraft(widget.args!);
                } else {
                  context.read<PaymentCubit>().prepareCheckout(widget.bookingId);
                }
              },
            );
          }

          if (state is CheckoutPrepared) {
            _lastPrepared = state;
          }
          final effectiveState = state is CheckoutPrepared ? state : _lastPrepared;

          if (effectiveState != null) {
            final data = effectiveState.data;
            final isPromoApplied = (effectiveState.appliedPromoCode != null && effectiveState.appliedPromoCode!.isNotEmpty) || data.discountAmount > 0;
            final seatNames = data.seats.map((s) => s.seatName).join(', ');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
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
                            Expanded(
                              child: Text(
                                l10n.orderSummary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                data.bookingCode,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        // 1. Seats row
                        _buildRow(
                          data.seats.isNotEmpty ? l10n.paymentSeatsLabel(seatNames) : l10n.ticketTotal,
                          FormatUtils.formatCurrency(data.ticketTotal.toInt()),
                          colors,
                        ),
                        // 2. Concessions items
                        for (final item in data.concessions) ...[
                          const SizedBox(height: 8),
                          _buildRow(
                            '${item.name} (x${item.quantity})',
                            FormatUtils.formatCurrency(item.subtotal.toInt()),
                            colors,
                          ),
                        ],
                        // 3. Discount rows
                        if (data.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          _buildRow(
                            l10n.discountAmount,
                            '-${FormatUtils.formatCurrency(data.discountAmount.toInt())}',
                            colors,
                            isNegative: true,
                          ),
                        ],
                        if (data.pointsUsed > 0) ...[
                          const SizedBox(height: 8),
                          _buildRow(
                            l10n.pointsDiscount,
                            '-${FormatUtils.formatCurrency(data.pointsUsed.toInt())}',
                            colors,
                            isNegative: true,
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        // 4. Final total amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.totalAmount,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              FormatUtils.formatCurrency(data.totalAmount.toInt()),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        // 5. Points earned notice
                        if (data.estimatedPointsEarned > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars_rounded, color: colors.warning, size: 18),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    l10n.paymentEarnedPointsNotice(data.estimatedPointsEarned.toInt()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Voucher / Promo Code Box (2 ways: Input manually & Select from available)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isPromoApplied ? colors.primary.withValues(alpha: 0.08) : colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPromoApplied
                            ? colors.primary.withValues(alpha: 0.3)
                            : colors.textSecondary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: isPromoApplied
                        ? Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: colors.primary, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      effectiveState.appliedPromoCode ?? l10n.promotionApplied,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (data.discountAmount > 0)
                                      Text(
                                        '-${FormatUtils.formatCurrency(data.discountAmount.toInt())}',
                                        style: TextStyle(
                                          color: colors.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _promoCtrl.clear();
                                  context.read<PaymentCubit>().removePromotion(widget.bookingId);
                                },
                                child: Text(
                                  l10n.removePromotion,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.error),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_offer_outlined, color: colors.primary, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _promoCtrl,
                                      decoration: InputDecoration(
                                        hintText: l10n.promotionCode,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final code = _promoCtrl.text.trim();
                                      if (code.isNotEmpty) {
                                        context.read<PaymentCubit>().applyPromotion(widget.bookingId, code);
                                      }
                                    },
                                    child: Text(
                                      l10n.applyPromotion,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Divider(height: 1),
                              const SizedBox(height: 6),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _showVoucherPicker(context, effectiveState.availablePromotions, colors, l10n),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.confirmation_number_outlined, color: colors.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          l10n.paymentSelectVoucher,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: colors.primary,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: colors.textSecondary, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),

                  // Loyalty Points Card
                  if (data.loyaltyPoints > 0 || data.pointsUsed > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, color: colors.warning, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.paymentUseLoyaltyPoints(data.loyaltyPoints.toInt()),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  data.pointsUsed > 0
                                      ? '${l10n.pointsDiscount}: -${FormatUtils.formatCurrency(data.pointsUsed.toInt())}'
                                      : l10n.maxPointsDiscount,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: data.pointsUsed > 0
                                        ? (colors.isDark ? colors.success : const Color(0xFF15803D))
                                        : colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: data.pointsUsed > 0,
                            activeThumbColor: colors.primary,
                            activeTrackColor: colors.primary.withValues(alpha: 0.5),
                            onChanged: (val) {
                              if (val) {
                                final subTotal = data.ticketTotal + data.concessionTotal;
                                final maxPointDiscount = (subTotal * 0.20).floor();
                                final pointsToUse = math.min(data.loyaltyPoints.toInt(), maxPointDiscount);
                                if (pointsToUse > 0) {
                                  context.read<PaymentCubit>().applyLoyaltyPoints(widget.bookingId, pointsToUse);
                                }
                              } else {
                                context.read<PaymentCubit>().removeLoyaltyPoints(widget.bookingId);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Payment Method Selector (Only MOMO & VNPAY)
                  Text(
                    l10n.paymentMethod,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...paymentMethods.map((pm) {
                    final isSelected = _selectedMethod == pm['id'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.textSecondary.withValues(alpha: 0.15),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        type: MaterialType.transparency,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (pm['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              pm['icon'] as IconData,
                              color: pm['color'] as Color,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            pm['name'] as String,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                          ),
                          trailing: Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? colors.primary : colors.textSecondary,
                          ),
                          onTap: () => setState(() => _selectedMethod = pm['id'] as String),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Pay Now Button
                  AppButton(
                    text: l10n.payNow,
                    onPressed: () {
                      context.read<PaymentCubit>().payNow(widget.bookingId, _selectedMethod);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, CineplexColors colors, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isNegative
                ? (colors.isDark ? colors.success : const Color(0xFF15803D))
                : colors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showWaitingPaymentDialog(
    BuildContext context, {
    required String bookingId,
    required String bookingCode,
    required String payUrl,
    required num totalAmount,
    required CineplexColors colors,
    required AppLocalizations l10n,
  }) {
    bool isChecking = false;
    String statusMessage = l10n.posPaymentPendingHint;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> checkStatus() async {
            if (isChecking) return;
            setDialogState(() => isChecking = true);
            try {
              final statusModel = await context.read<PaymentCubit>().repository.getPaymentStatus(bookingId);
              final status = statusModel.status;

              if (!dialogCtx.mounted) return;

              if (status == 'PAID' || status == 'SUCCESS') {
                Navigator.of(dialogCtx).pop();
                context.go('/payment-result/$bookingId');
              } else if (status == 'FAILED') {
                setDialogState(() {
                  statusMessage = l10n.posPaymentFailedPrompt;
                });
              } else if (status == 'EXPIRED' || statusModel.isExpired) {
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.paymentExpired),
                    backgroundColor: colors.error,
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
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(LucideIcons.loader2, color: colors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedMethod == 'MOMO'
                        ? l10n.posWaitingMomoPayment
                        : l10n.paymentPending,
                    style: TextStyle(
                      color: colors.textPrimary,
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
                  bookingCode.isNotEmpty
                      ? l10n.posOrderSuccessPrompt(bookingCode)
                      : l10n.posOrderSuccessPrompt(bookingId),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.totalAmount}: ${FormatUtils.formatCurrency(totalAmount.toInt())}',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  statusMessage,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
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
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.posPaymentCancelledPrompt),
                      backgroundColor: colors.warning,
                    ),
                  );
                },
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: isChecking ? null : checkStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
