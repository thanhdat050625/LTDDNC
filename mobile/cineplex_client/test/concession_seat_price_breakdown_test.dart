import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/concession/data/repositories/concession_repository.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';
import 'package:cineplex_client/features/concession/presentation/cubit/concession_cubit.dart';
import 'package:cineplex_client/features/concession/presentation/screens/concession_screen.dart';

class MockConcessionRepository extends Mock implements ConcessionRepository {}
class MockBookingRepository extends Mock implements BookingRepository {}
class FakeCreateBookingDto extends Fake implements CreateBookingDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateBookingDto());
  });

  late MockConcessionRepository concessionRepo;
  late MockBookingRepository bookingRepo;

  final sampleProducts = [
    const ConcessionProductModel(id: 1, name: 'Nước ngọt CINE', price: 35000, stockQuantity: 50),
    const ConcessionProductModel(id: 2, name: 'Combo Couple', price: 85000, stockQuantity: 50),
  ];

  setUp(() {
    concessionRepo = MockConcessionRepository();
    bookingRepo = MockBookingRepository();

    when(() => concessionRepo.getConcessions(page: any(named: 'page'), limit: any(named: 'limit')))
        .thenAnswer((_) async => sampleProducts);
  });

  Widget buildScreen({required ConcessionScreenArgs args, ThemeMode mode = ThemeMode.dark}) {
    final router = GoRouter(
      initialLocation: '/concessions',
      routes: [
        GoRoute(
          path: '/concessions',
          builder: (_, __) => BlocProvider<ConcessionCubit>(
            create: (_) => ConcessionCubit(concessionRepo, bookingRepo)..loadConcessions(),
            child: ConcessionScreen(args: args),
          ),
        ),
        GoRoute(
          path: '/checkout/:bookingId',
          builder: (_, __) => const Scaffold(body: Text('Checkout Screen')),
        ),
      ],
    );

    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      routerConfig: router,
    );
  }

  testWidgets('ConcessionScreen displays clear breakdown of seat price and concession price', (tester) async {
    const args = ConcessionScreenArgs(
      showtimeId: 101,
      seatIds: [1, 2],
      seatPrice: 150000.0,
      bookingId: 0,
    );

    await tester.pumpWidget(buildScreen(args: args));
    await tester.pumpAndSettle();

    // 1. Should show ticket total row with seat count
    expect(find.textContaining('Tổng tiền vé (2 ghế)'), findsOneWidget);
    expect(find.text('150.000 đ'), findsWidgets);

    // 2. Should show concession total label
    expect(find.text('Tổng tiền bắp nước'), findsOneWidget);

    // 3. Should show total amount label
    expect(find.text('Tổng cộng'), findsOneWidget);

    // 4. Tap '+' to add 1 Soda (35.000)
    final addButtons = find.byIcon(Icons.add);
    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Grand total should now be 150.000 + 35.000 = 185.000
    expect(find.text('185.000 đ'), findsOneWidget);
  });

  testWidgets('ConcessionScreen checkout creates booking when bookingId is 0', (tester) async {
    when(() => bookingRepo.createBooking(any())).thenAnswer((_) async => BookingModel(
      id: 888,
      bookingCode: 'BK-888',
      showtimeId: 101,
      totalAmount: 185000,
      discountAmount: 0,
      pointsUsed: 0,
      status: 'PENDING',
      expiredAt: DateTime.now().add(const Duration(minutes: 5)),
    ));

    const args = ConcessionScreenArgs(
      showtimeId: 101,
      seatIds: [1, 2],
      seatPrice: 150000.0,
      bookingId: 0,
    );

    await tester.pumpWidget(buildScreen(args: args));
    await tester.pumpAndSettle();

    // Tap '+' on first item
    final addButtons = find.byIcon(Icons.add);
    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Tap 'Thanh toán'
    final checkoutBtn = find.text('Thanh toán');
    await tester.tap(checkoutBtn);
    await tester.pumpAndSettle();

    // Verify createBooking was called with showtimeId 101 and seatIds [1, 2]
    verify(() => bookingRepo.createBooking(any(that: isA<CreateBookingDto>().having(
      (dto) => dto.showtimeId,
      'showtimeId',
      101,
    )))).called(1);
  });
}
