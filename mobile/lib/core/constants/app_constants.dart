class AppConstants {
  static const String baseUrl =
      'http://localhost:3000'; // Android emulator localhost
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const int seatHoldDurationSeconds = 300; // 5 minutes
  static const int maxSeatsPerBooking = 8;
  static const double loyaltyEarnRate = 0.10;
  static const double loyaltyMaxDiscountRate = 0.20;
  static const int loyaltyPointValue = 1; // 1 point = 1 VND
}
