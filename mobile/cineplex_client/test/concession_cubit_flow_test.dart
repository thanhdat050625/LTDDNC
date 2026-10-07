import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/concession/data/repositories/concession_repository.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';
import 'package:cineplex_client/features/concession/presentation/cubit/concession_cubit.dart';

class MockConcessionRepository extends Mock implements ConcessionRepository {}
class MockBookingRepository extends Mock implements BookingRepository {}
class FakeUpdateBookingConcessionsDto extends Fake implements UpdateBookingConcessionsDto {}
class FakeCreateBookingDto extends Fake implements CreateBookingDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateBookingConcessionsDto());
    registerFallbackValue(FakeCreateBookingDto());
  });

  late MockConcessionRepository concessionRepo;
  late MockBookingRepository bookingRepo;

  final sampleProducts = [
    const ConcessionProductModel(id: 1, name: 'Bắp rang bơ', price: 60000, stockQuantity: 100),
    const ConcessionProductModel(id: 2, name: 'Nước ngọt', price: 30000, stockQuantity: 100),
  ];

  setUp(() {
    concessionRepo = MockConcessionRepository();
    bookingRepo = MockBookingRepository();
  });

  group('ConcessionCubit Flow Tests', () {
    test('initial state is ConcessionInitial', () {
      final cubit = ConcessionCubit(concessionRepo, bookingRepo);
      expect(cubit.state, equals(ConcessionInitial()));
      cubit.close();
    });

    blocTest<ConcessionCubit, ConcessionState>(
      '1. Quantity updates: increases, decreases, never drops below 0',
      build: () => ConcessionCubit(concessionRepo, bookingRepo),
      seed: () => ConcessionLoaded(products: sampleProducts),
      act: (cubit) {
        cubit.updateQuantity(1, 2); // Increase to 2
        cubit.updateQuantity(1, 1); // Decrease to 1
        cubit.updateQuantity(1, -5); // Negative attempt clamps to 0 and removes item
      },
      expect: () => [
        isA<ConcessionLoaded>()
            .having((s) => s.selectedItems[1], 'quantity', 2)
            .having((s) => s.totalPrice, 'totalPrice', 120000.0),
        isA<ConcessionLoaded>()
            .having((s) => s.selectedItems[1], 'quantity', 1)
            .having((s) => s.totalPrice, 'totalPrice', 60000.0),
        isA<ConcessionLoaded>()
            .having((s) => s.selectedItems.containsKey(1), 'contains item 1', false)
            .having((s) => s.totalPrice, 'totalPrice', 0.0),
      ],
    );

    blocTest<ConcessionCubit, ConcessionState>(
      '2. Total price accumulates correctly across multiple products',
      build: () => ConcessionCubit(concessionRepo, bookingRepo),
      seed: () => ConcessionLoaded(products: sampleProducts),
      act: (cubit) {
        cubit.updateQuantity(1, 2); // 2 * 60,000 = 120,000
        cubit.updateQuantity(2, 3); // 3 * 30,000 = 90,000 -> total 210,000
      },
      expect: () => [
        isA<ConcessionLoaded>().having((s) => s.totalPrice, 'totalPrice', 120000.0),
        isA<ConcessionLoaded>().having((s) => s.totalPrice, 'totalPrice', 210000.0),
      ],
    );

    blocTest<ConcessionCubit, ConcessionState>(
      '3. "Tiếp tục" (submitConcessions) calls PUT endpoint, excludes 0-quantity items, and emits success',
      build: () {
        when(() => bookingRepo.updateBookingConcessions(123, any()))
            .thenAnswer((_) async => {'success': true});
        return ConcessionCubit(concessionRepo, bookingRepo);
      },
      seed: () => ConcessionLoaded(
        products: sampleProducts,
        selectedItems: const {1: 2}, // Product 1: quantity 2
        totalPrice: 120000.0,
      ),
      act: (cubit) async => cubit.submitConcessions(123),
      expect: () => [
        isA<ConcessionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ConcessionSubmitSuccess>().having((s) => s.bookingId, 'bookingId', 123),
      ],
      verify: (_) {
        verify(() => bookingRepo.updateBookingConcessions(
              123,
              any(that: isA<UpdateBookingConcessionsDto>().having(
                (dto) => dto.concessions?.map((c) => c.quantity).toList(),
                'quantities',
                [2],
              )),
            )).called(1);
      },
    );

    blocTest<ConcessionCubit, ConcessionState>(
      '4. "Tiếp tục" when nothing selected sends empty list [] and succeeds',
      build: () {
        when(() => bookingRepo.updateBookingConcessions(123, any()))
            .thenAnswer((_) async => {'success': true});
        return ConcessionCubit(concessionRepo, bookingRepo);
      },
      seed: () => ConcessionLoaded(
        products: sampleProducts,
        selectedItems: const {},
        totalPrice: 0.0,
      ),
      act: (cubit) async => cubit.submitConcessions(123),
      expect: () => [
        isA<ConcessionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ConcessionSubmitSuccess>().having((s) => s.bookingId, 'bookingId', 123),
      ],
      verify: (_) {
        verify(() => bookingRepo.updateBookingConcessions(
              123,
              any(that: isA<UpdateBookingConcessionsDto>().having(
                (dto) => dto.concessions?.isEmpty ?? false,
                'empty concessions',
                true,
              )),
            )).called(1);
      },
    );

    blocTest<ConcessionCubit, ConcessionState>(
      '5. "Tiếp tục" failure emits ConcessionError and resets isSubmitting to false',
      build: () {
        when(() => bookingRepo.updateBookingConcessions(123, any()))
            .thenThrow(Exception('Cập nhật bắp nước thất bại'));
        return ConcessionCubit(concessionRepo, bookingRepo);
      },
      seed: () => ConcessionLoaded(
        products: sampleProducts,
        selectedItems: const {1: 1},
        totalPrice: 60000.0,
      ),
      act: (cubit) async => cubit.submitConcessions(123),
      expect: () => [
        isA<ConcessionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ConcessionError>().having((e) => e.message, 'message', contains('Cập nhật bắp nước thất bại')),
        isA<ConcessionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', false),
      ],
    );

    blocTest<ConcessionCubit, ConcessionState>(
      '6. Submit concessions when bookingId is 0 creates booking via createBooking and emits success',
      build: () {
        when(() => bookingRepo.createBooking(any())).thenAnswer((_) async => BookingModel(
          id: 555,
          bookingCode: 'BK-555',
          showtimeId: 101,
          totalAmount: 220000,
          discountAmount: 0,
          pointsUsed: 0,
          status: 'PENDING',
          expiredAt: DateTime.now().add(const Duration(minutes: 5)),
        ));
        return ConcessionCubit(concessionRepo, bookingRepo);
      },
      seed: () => ConcessionLoaded(
        products: sampleProducts,
        selectedItems: const {1: 1},
        totalPrice: 60000.0,
      ),
      act: (cubit) async => cubit.submitConcessions(0, 101, [1, 2]),
      expect: () => [
        isA<ConcessionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ConcessionSubmitSuccess>().having((s) => s.bookingId, 'bookingId', 555),
      ],
      verify: (_) {
        verify(() => bookingRepo.createBooking(any(that: isA<CreateBookingDto>().having(
          (dto) => dto.showtimeId,
          'showtimeId',
          101,
        )))).called(1);
      },
    );
  });
}
