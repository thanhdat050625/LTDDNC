import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/payment_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  final String bookingId;
  const CheckoutScreen({super.key, required this.bookingId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'MOMO';
  bool _usePoints = false;
  final TextEditingController _promoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().prepareCheckout(widget.bookingId);
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    final paymentMethods = [
      {'id': 'MOMO', 'name': l10n.paymentMethodMomo, 'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFFA50064)},
      {'id': 'VNPAY', 'name': l10n.paymentMethodVnpay, 'icon': Icons.qr_code_2_outlined, 'color': const Color(0xFF005BAA)},
      {'id': 'ZALOPAY', 'name': l10n.paymentMethodZaloPay, 'icon': Icons.flash_on_outlined, 'color': const Color(0xFF008FE5)},
      {'id': 'CARD', 'name': l10n.paymentMethodCard, 'icon': Icons.credit_card_outlined, 'color': const Color(0xFF1E293B)},
    ];

    return AppScaffold(
      title: l10n.checkout,
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentUrlReady) {
            context.push('/payment-webview?url=${Uri.encodeComponent(state.payUrl)}&bookingId=${widget.bookingId}');
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
              onRetry: () => context.read<PaymentCubit>().prepareCheckout(widget.bookingId),
            );
          }

          if (state is CheckoutPrepared) {
            final data = state.data;
            final isPromoApplied = (state.appliedPromoCode != null && state.appliedPromoCode!.isNotEmpty) || data.discountAmount > 0;
            final originalAmount = data.totalAmount + data.discountAmount;
            final finalAmount = (data.totalAmount - (_usePoints ? data.pointsUsed : 0)).clamp(0, double.infinity);

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
                        _buildRow(l10n.ticketTotal, FormatUtils.formatCurrency(originalAmount.toInt()), colors),
                        if (data.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          _buildRow(
                            l10n.discountAmount,
                            '-${FormatUtils.formatCurrency(data.discountAmount.toInt())}',
                            colors,
                            isNegative: true,
                          ),
                        ],
                        if (_usePoints && data.pointsUsed > 0) ...[
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
                              FormatUtils.formatCurrency(finalAmount.toInt()),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Voucher / Promo Code Box
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
                                      state.appliedPromoCode ?? l10n.promotionApplied,
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
                        : Row(
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
                  ),

                  if (data.pointsUsed > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, color: colors.warning, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.pointsDiscount,
                              style: TextStyle(fontWeight: FontWeight.w500, color: colors.textPrimary),
                            ),
                          ),
                          Switch(
                            value: _usePoints,
                            activeThumbColor: colors.primary,
                            activeTrackColor: colors.primary.withValues(alpha: 0.5),
                            onChanged: (val) => setState(() => _usePoints = val),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Payment Method Selector
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
                      context.read<PaymentCubit>().checkout(widget.bookingId, _selectedMethod);
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
}

