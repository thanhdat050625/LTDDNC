import 'package:mobile_shared/mobile_shared.dart';

class SelectedConcession {
  final String name;
  final int productId;
  final int price;
  final int quantity;

  const SelectedConcession({
    required this.name,
    required this.productId,
    required this.price,
    required this.quantity,
  });

  int get subtotal => price * quantity;
}

class CheckoutArgs {
  final ShowtimeModel showtime;
  final List<SeatModel> selectedSeats;
  final List<SelectedConcession> concessions;
  final UserModel? customer;
  final int pointsToUse;

  const CheckoutArgs({
    required this.showtime,
    required this.selectedSeats,
    this.concessions = const [],
    this.customer,
    this.pointsToUse = 0,
  });

  int get ticketTotal {
    final pricePerSeat = showtime.pricePerSeat?.toInt() ?? 75000;
    return selectedSeats.length * pricePerSeat;
  }

  int get concessionTotal => concessions.fold(0, (sum, c) => sum + c.subtotal);
  int get discountTotal => pointsToUse;
  int get grandTotal => (ticketTotal + concessionTotal - discountTotal).clamp(0, 999999999);
}
