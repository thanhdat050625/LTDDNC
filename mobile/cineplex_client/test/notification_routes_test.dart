import 'package:flutter_test/flutter_test.dart';
import 'package:cineplex_client/core/router/app_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(
      const AuthAuthenticated(
        UserModel(
          id: 1,
          email: 'test@example.com',
          fullName: 'Tester',
          role: 'CUSTOMER',
          status: 'ACTIVE',
        ),
      ),
    );
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  test('GoRouter configuration matches /booking-history, /history, /tickets and /', () {
    final router = createRouter(authBloc);

    final matchBookingHistory = router.configuration.findMatch(Uri.parse('/booking-history'));
    expect(matchBookingHistory.isEmpty, isFalse);

    final matchHistory = router.configuration.findMatch(Uri.parse('/history'));
    expect(matchHistory.isEmpty, isFalse);

    final matchTickets = router.configuration.findMatch(Uri.parse('/tickets'));
    expect(matchTickets.isEmpty, isFalse);

    final matchRoot = router.configuration.findMatch(Uri.parse('/'));
    expect(matchRoot.isEmpty, isFalse);
  });
}
