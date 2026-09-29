import 'package:flutter/material.dart';
import 'core/api/dio_client.dart';
import 'package:cineplex_client/core/services/storage_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/home/data/repositories/home_repository.dart';
import 'features/movie/data/repositories/movie_repository.dart';
import 'features/showtime/data/repositories/showtime_repository.dart';
import 'features/booking/data/repositories/booking_repository.dart';
import 'features/concession/data/repositories/concession_repository.dart';
import 'features/payment/data/repositories/payment_repository.dart';
import 'features/ticket/data/repositories/ticket_repository.dart';
import 'features/notification/data/repositories/notification_repository.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final dioClient = DioClient(storageService);

  runApp(App(
    storageService: storageService,
    dioClient: dioClient,
    authRepo: AuthRepository(dioClient, storageService),
    homeRepo: HomeRepository(dioClient),
    movieRepo: MovieRepository(dioClient),
    showtimeRepo: ShowtimeRepository(dioClient),
    bookingRepo: BookingRepository(dioClient),
    concessionRepo: ConcessionRepository(dioClient),
    paymentRepo: PaymentRepository(dioClient),
    ticketRepo: TicketRepository(dioClient),
    notificationRepo: NotificationRepository(dioClient),
    profileRepo: ProfileRepository(dioClient),
  ));
}
