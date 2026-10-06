import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/booking/presentation/bloc/seat_booking_bloc.dart';
import 'package:cineplex_client/features/booking/presentation/widgets/seat_layout_widget.dart';
import 'package:cineplex_client/features/booking/presentation/widgets/booking_timer_widget.dart';

class SeatSelectionScreen extends StatefulWidget {
  final int showtimeId;

  const SeatSelectionScreen({super.key, required this.showtimeId});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SeatBookingBloc>().add(LoadSeatMap(widget.showtimeId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.seatSelection),
      ),
      body: BlocConsumer<SeatBookingBloc, SeatBookingState>(
        listener: (context, state) {
          if (state is SeatsHeld && state.bookingId > 0) {
            context.push('/concessions/${state.bookingId}');
          } else if (state is SeatBookingError) {
            String errorMsg = state.message;
            if (state.message == 'MAX_SEATS_EXCEEDED') {
              errorMsg = l10n.seatMaxSelection;
            } else if (state.message == 'SEAT_ALREADY_HELD') {
              errorMsg = l10n.seatHeldByOther;
            } else if (state.message == 'SHOWTIME_EXPIRED') {
              errorMsg = l10n.bookingShowtimeExpired;
            } else if (state.message == 'SEAT_ROOM_MISMATCH') {
              errorMsg = l10n.bookingSeatRoomMismatch;
            } else if (state.message == 'BOOKING_HOLD_EXPIRED') {
              errorMsg = l10n.bookingHoldExpired;
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
          }
        },
        builder: (context, state) {
          if (state is SeatMapLoading) {
            return const Center(child: AppLoading());
          }

          if (state is SeatBookingError) {
            return AppErrorView(
              message: state.message == 'MAX_SEATS_EXCEEDED'
                  ? l10n.seatMaxSelection
                  : (state.message == 'SEAT_ALREADY_HELD'
                      ? l10n.seatHeldByOther
                      : (state.message == 'BOOKING_HOLD_EXPIRED'
                          ? l10n.bookingHoldExpired
                          : state.message)),
              onRetry: () => context.read<SeatBookingBloc>().add(LoadSeatMap(widget.showtimeId)),
            );
          }

          if (state is SeatMapLoaded) {
            if (state.seats.isEmpty) {
              return Center(
                child: AppEmptyView(
                  icon: Icons.event_seat_outlined,
                  title: l10n.seatEmpty,
                ),
              );
            }
            final totalPrice = state.totalPrice;
            return Column(
              children: [
                if (state.secondsRemaining != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: BookingTimerWidget(secondsRemaining: state.secondsRemaining!),
                  ),
                
                // Screen curved indicator (Màn hình chiếu cong kèm vệt sáng)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 10.0, 28.0, 6.0),
                  child: Column(
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 24),
                        painter: ScreenPainter(color: colors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.seatLayoutTitle,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SeatLayoutWidget(
                    seats: state.seats,
                    selectedSeatIds: state.selectedSeatIds,
                    rows: state.roomInfo?.rows ?? 10,
                    columns: state.roomInfo?.columns ?? 10,
                    onSeatTap: (seatId) {
                      if (state.selectedSeatIds.contains(seatId)) {
                        context.read<SeatBookingBloc>().add(DeselectSeat(seatId));
                      } else {
                        context.read<SeatBookingBloc>().add(SelectSeat(seatId));
                      }
                    },
                  ),
                ),
                
                // Bottom Order Sheet (Bảng giá và nút tiếp tục)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
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
                      children: [
                        const SeatLegend(),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.totalAmount,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  FormatUtils.formatCurrency(totalPrice),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                            AppButton(
                              text: l10n.continueBtn,
                              width: 155,
                              onPressed: state.selectedSeatIds.isEmpty
                                  ? null
                                  : () => context.read<SeatBookingBloc>().add(HoldSelectedSeats()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ScreenPainter extends CustomPainter {
  final Color color;
  const ScreenPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Vệt sáng chiếu từ màn hình (Projector light beam effect)
    final lightPath = Path();
    lightPath.moveTo(0, size.height);
    lightPath.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    lightPath.lineTo(size.width * 0.85, size.height + 16);
    lightPath.lineTo(size.width * 0.15, size.height + 16);
    lightPath.close();

    final lightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.16),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height + 16));
    canvas.drawPath(lightPath, lightPaint);

    // 2. Viền tỏa sáng (Outer glow)
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, glowPaint);

    // 3. Đường cong màn hình sắc nét (Crisp screen arc)
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

