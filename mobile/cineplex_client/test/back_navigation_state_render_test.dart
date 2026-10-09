import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/booking/presentation/bloc/seat_booking_bloc.dart';
import 'package:cineplex_client/features/booking/presentation/widgets/seat_layout_widget.dart';
import 'package:cineplex_client/features/booking/presentation/screens/seat_selection_screen.dart';
import 'package:cineplex_client/features/concession/presentation/cubit/concession_cubit.dart';
import 'package:cineplex_client/features/concession/presentation/screens/concession_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockSeatBookingBloc extends Mock implements SeatBookingBloc {}
class MockConcessionCubit extends Mock implements ConcessionCubit {}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('vi'),
    home: child,
  );
}

void main() {
  group('Back navigation state render test', () {
    test('SeatsHeld is a subclass of SeatMapLoaded and holds full seat data', () {
      final sampleSeats = <SeatModel>[
        const SeatModel(seatId: 1, row: 'A', column: 1, label: 'A1', status: SeatStatus.selected, isCouple: false),
        const SeatModel(seatId: 2, row: 'A', column: 2, label: 'A2', status: SeatStatus.available, isCouple: false),
      ];
      final heldState = SeatsHeld(
        123,
        DateTime.now().add(const Duration(minutes: 5)),
        showtimeId: 101,
        seatIds: const [1],
        seatPrice: 75000,
        seats: sampleSeats,
        selectedSeatIds: const [1],
        pricePerSeat: 75000,
        secondsRemaining: 299,
      );

      expect(heldState, isA<SeatMapLoaded>());
      expect(heldState.seats.length, 2);
      expect(heldState.selectedSeatIds, [1]);
      expect(heldState.bookingId, 123);
      expect(heldState.secondsRemaining, 299);
    });

    test('ConcessionSubmitSuccess is a subclass of ConcessionLoaded and holds products', () {
      final sampleProducts = <ConcessionProductModel>[
        const ConcessionProductModel(id: 1, name: 'Bắp rang bơ', price: 60000, stockQuantity: 10),
      ];
      final successState = ConcessionSubmitSuccess(
        123,
        products: sampleProducts,
        selectedItems: const {1: 2},
        totalPrice: 120000,
      );

      expect(successState, isA<ConcessionLoaded>());
      expect(successState.products.length, 1);
      expect(successState.selectedItems[1], 2);
      expect(successState.totalPrice, 120000);
    });

    testWidgets('SeatSelectionScreen renders seat map when state is SeatsHeld (no black screen)', (tester) async {
      final bloc = MockSeatBookingBloc();
      final sampleSeats = <SeatModel>[
        const SeatModel(seatId: 1, row: 'A', column: 1, label: 'A1', status: SeatStatus.selected, isCouple: false),
        const SeatModel(seatId: 2, row: 'A', column: 2, label: 'A2', status: SeatStatus.available, isCouple: false),
      ];
      final heldState = SeatsHeld(
        123,
        DateTime.now().add(const Duration(minutes: 5)),
        showtimeId: 101,
        seatIds: const [1],
        seatPrice: 75000,
        seats: sampleSeats,
        selectedSeatIds: const [1],
        pricePerSeat: 75000,
        secondsRemaining: 295,
      );

      when(() => bloc.state).thenReturn(heldState);
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        BlocProvider<SeatBookingBloc>.value(
          value: bloc,
          child: _wrapWithApp(const SeatSelectionScreen(showtimeId: 101)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that seats and layout are rendered, NOT SizedBox.shrink()
      expect(find.byType(SeatSelectionScreen), findsOneWidget);
      expect(find.byType(SeatLayoutWidget), findsOneWidget);
      expect(find.byType(SeatLegend), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('ConcessionScreen renders products when state is ConcessionSubmitSuccess (no black screen)', (tester) async {
      final cubit = MockConcessionCubit();
      final sampleProducts = <ConcessionProductModel>[
        const ConcessionProductModel(id: 1, name: 'Bắp Caramel Lớn', price: 79000, stockQuantity: 10),
      ];
      final successState = ConcessionSubmitSuccess(
        123,
        products: sampleProducts,
        selectedItems: const {1: 1},
        totalPrice: 79000,
      );

      when(() => cubit.state).thenReturn(successState);
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => cubit.loadConcessions()).thenAnswer((_) async {});

      await tester.pumpWidget(
        BlocProvider<ConcessionCubit>.value(
          value: cubit,
          child: _wrapWithApp(const ConcessionScreen(bookingId: 123)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify products are rendered, NOT SizedBox.shrink()
      expect(find.byType(ConcessionScreen), findsOneWidget);
      expect(find.text('Bắp Caramel Lớn'), findsOneWidget);
    });
  });
}
