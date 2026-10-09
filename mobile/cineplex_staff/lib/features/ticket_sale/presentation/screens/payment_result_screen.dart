import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffPaymentResultScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic>? initialData;

  const StaffPaymentResultScreen({
    super.key,
    required this.bookingId,
    this.initialData,
  });

  @override
  State<StaffPaymentResultScreen> createState() => _StaffPaymentResultScreenState();
}

class _StaffPaymentResultScreenState extends State<StaffPaymentResultScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    if (_data == null) {
      _loadStatus();
    }
  }

  Future<void> _loadStatus() async {
    final bId = int.tryParse(widget.bookingId);
    if (bId == null || bId <= 0) return;

    setState(() => _isLoading = true);
    try {
      final repo = BookingManagementRepository(context.read<DioClient>());
      final res = await repo.getPaymentStatus(bId);
      if (mounted) {
        setState(() {
          _data = res;
        });
      }
    } catch (_) {
      // Keep initial or fallback state
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return AppScaffold(
        title: l10n.paymentResult,
        body: const Center(child: AppLoading()),
      );
    }

    final data = _data ?? {};
    final status = (data['status']?.toString() ?? 'PAID').toUpperCase();
    final isSuccess = status == 'PAID' || status == 'SUCCESS';
    final bookingCode = data['bookingCode']?.toString() ?? 'BK-${widget.bookingId}';
    final totalAmount = (data['totalAmount'] as num?)?.toInt() ??
        (data['amount'] as num?)?.toInt() ??
        0;
    final method = data['method']?.toString() ?? data['paymentMethod']?.toString() ?? 'CASH';
    final cashReceived = (data['cashReceived'] as num?)?.toInt() ?? 0;
    final cashChange = (data['cashChange'] as num?)?.toInt() ?? 0;
    final customer = data['customer'] as UserModel?;
    final pointsEarned = (data['pointsEarned'] as num?)?.toInt() ?? (totalAmount * 0.1).floor();
    final showtime = data['showtime'] as ShowtimeModel?;
    final selectedSeats = data['selectedSeats'] as List<SeatModel>?;

    String methodLabel = l10n.cash;
    if (method == 'MOMO') {
      methodLabel = l10n.momo;
    } else if (method == 'VNPAY') {
      methodLabel = l10n.vnpay;
    }

    return AppScaffold(
      title: l10n.paymentResult,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? theme.success.withValues(alpha: 0.12)
                      : theme.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                  color: isSuccess ? theme.success : theme.error,
                  size: 52,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isSuccess ? l10n.paymentSuccessful : l10n.paymentFailed,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSuccess ? l10n.epassInstruction : l10n.posPaymentFailedPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Booking Code row
                    _buildRow(
                      theme,
                      l10n.bookingCode,
                      bookingCode,
                      isBold: true,
                      valueColor: theme.primary,
                    ),
                    const Divider(height: 20),

                    // Status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.orderStatus,
                          style: TextStyle(fontSize: 13, color: theme.textSecondary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSuccess
                                ? theme.success.withValues(alpha: 0.12)
                                : theme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSuccess ? l10n.bookingStatusPaid : l10n.paymentFailed,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? theme.success : theme.error,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (showtime != null) ...[
                      const Divider(height: 20),
                      _buildRow(
                        theme,
                        l10n.movieLabel,
                        showtime.movie?.title ?? l10n.defaultMovieTitle,
                        isBold: true,
                      ),
                      const SizedBox(height: 8),
                      _buildRow(
                        theme,
                        l10n.roomLabel,
                        '${showtime.room?.name ?? '1'} (${FormatUtils.formatTime(showtime.publicStartTime)})',
                      ),
                    ],

                    if (selectedSeats != null && selectedSeats.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildRow(
                        theme,
                        l10n.ticketSeatLabel,
                        selectedSeats.map((s) => s.label).join(', '),
                      ),
                    ],

                    const Divider(height: 20),

                    // Payment Method row
                    _buildRow(theme, l10n.paymentMethod, methodLabel),

                    // Cash received & change (if CASH)
                    if (method == 'CASH' && cashReceived > 0) ...[
                      const SizedBox(height: 8),
                      _buildRow(
                        theme,
                        l10n.cashReceived,
                        FormatUtils.formatCurrency(cashReceived),
                      ),
                      if (cashChange > 0) ...[
                        const SizedBox(height: 8),
                        _buildRow(
                          theme,
                          l10n.cashChange,
                          FormatUtils.formatCurrency(cashChange),
                          valueColor: theme.success,
                          isBold: true,
                        ),
                      ],
                    ],

                    const Divider(height: 20),

                    // Total Amount row
                    _buildRow(
                      theme,
                      l10n.totalAmount,
                      FormatUtils.formatCurrency(totalAmount),
                      isBold: true,
                      fontSize: 16,
                      valueColor: theme.accent,
                    ),

                    // Customer & Loyalty Points Reward Card
                    if (customer != null && isSuccess && pointsEarned > 0) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.sparkles, color: theme.warning, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.posEarnedPointsSuccess(pointsEarned),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    customer.fullName.isNotEmpty
                                        ? customer.fullName
                                        : customer.email,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: l10n.posContinueSale,
                  onPressed: () => context.go('/pos'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: isSuccess ? l10n.posViewTickets : l10n.retryPayment,
                  isOutlined: true,
                  onPressed: isSuccess
                      ? () => context.go('/ticket-management')
                      : () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    CineplexColors theme,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? theme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
