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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.seatSelection),
      ),
      body: BlocConsumer<SeatBookingBloc, SeatBookingState>(
        listener: (context, state) {
          if (state is SeatsHeld && state.bookingId > 0) {
            context.push('/concessions/${state.bookingId}');
          } else if (state is SeatBookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SeatMapLoading) {
            return const Center(child: AppLoading());
          }

          if (state is SeatBookingError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<SeatBookingBloc>().add(LoadSeatMap(widget.showtimeId)),
            );
          }

          if (state is SeatMapLoaded) {
            final totalPrice = state.selectedSeatIds.length * state.pricePerSeat;
            return Column(
              children: [
                if (state.secondsRemaining != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: BookingTimerWidget(secondsRemaining: state.secondsRemaining!),
                  ),
                
                // Screen curved indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                  child: Column(
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 24),
                        painter: ScreenPainter(color: colors.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.seatLayoutTitle,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary.withValues(alpha: 0.7),
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
                
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: colors.textSecondary.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SeatLegend(),
                        const SizedBox(height: 12),
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
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  FormatUtils.formatCurrency(totalPrice),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                            AppButton(
                              text: l10n.continueBtn,
                              width: 150,
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
    
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

