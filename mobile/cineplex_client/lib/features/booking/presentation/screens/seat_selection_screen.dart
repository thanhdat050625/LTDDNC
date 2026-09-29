import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/l10n/app_localizations.dart';
import 'package:cineplex_client/core/theme/app_colors.dart';
import 'package:cineplex_client/core/widgets/app_button.dart';
import 'package:cineplex_client/core/widgets/app_loading.dart';
import 'package:cineplex_client/features/booking/presentation/bloc/seat_booking_bloc.dart';
import 'package:cineplex_client/features/booking/presentation/widgets/seat_layout_widget.dart';
import 'package:cineplex_client/features/booking/presentation/widgets/seat_legend.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectSeats),
      ),
      body: BlocConsumer<SeatBookingBloc, SeatBookingState>(
        listener: (context, state) {
          if (state is SeatsHeld) {
            Navigator.pushNamed(context, '/concession', arguments: state.bookingId);
          } else if (state is SeatBookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SeatMapLoading) {
            return const Center(child: AppLoading());
          }

          if (state is SeatMapLoaded) {
            return Column(
              children: [
                if (state.secondsRemaining != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BookingTimerWidget(secondsRemaining: state.secondsRemaining!),
                  ),
                
                // Screen curved indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
                  child: CustomPaint(
                    size: const Size(double.infinity, 30),
                    painter: ScreenPainter(),
                  ),
                ),
                Text(l10n.seatInfo, style: const TextStyle(color: Colors.grey)),
                
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SeatLegend(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.totalPrice('${state.selectedSeatIds.length * state.pricePerSeat} \u20ab'), 
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            AppButton(
                              text: l10n.continueBtn,
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
    
    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
