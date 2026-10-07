import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/movie/presentation/widgets/movie_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('vi')],
    locale: const Locale('vi'),
    home: Scaffold(body: SizedBox(width: 200, height: 300, child: child)),
  );
}

void main() {
  testWidgets('MovieCard: Does not render 0+ or negative age rating badge', (tester) async {
    const movie0 = MovieModel(
      id: 1,
      title: 'Kung Fu Panda 4',
      durationMinutes: 94,
      genre: 'Animation',
      status: 'NOW_SHOWING',
      ageLimit: 0,
    );

    await tester.pumpWidget(_wrap(const MovieCard(movie: movie0)));
    await tester.pumpAndSettle();

    expect(find.text('0+'), findsNothing);
    expect(find.text('Kung Fu Panda 4'), findsOneWidget);
    expect(find.text('94 phút'), findsOneWidget);
  });

  testWidgets('MovieCard: Renders badge when ageLimit > 0', (tester) async {
    const movie13 = MovieModel(
      id: 2,
      title: 'Dune: Part Two',
      durationMinutes: 166,
      genre: 'Sci-Fi',
      status: 'NOW_SHOWING',
      ageLimit: 13,
    );

    await tester.pumpWidget(_wrap(const MovieCard(movie: movie13)));
    await tester.pumpAndSettle();

    expect(find.text('13+'), findsOneWidget);
  });
}
