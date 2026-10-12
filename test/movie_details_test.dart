import 'package:cineflix/screens/movie/movie_details_screen.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleMovie = MovieSeedService.initialDemoMovies.first;

  group('MovieDetailsScreen UI Tests', () {
    testWidgets('Renders MovieDetailsScreen metadata and actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MovieDetailsScreen(movie: sampleMovie),
        ),
      );

      expect(find.text(sampleMovie.title), findsAtLeastNWidgets(1));
      expect(find.text('${sampleMovie.year}'), findsOneWidget);
      expect(find.text(sampleMovie.genre), findsOneWidget);
      expect(find.text(sampleMovie.description), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Play Movie'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '+ Add to My List'), findsOneWidget);
    });

    testWidgets('Back button pops navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(movie: sampleMovie),
                  ),
                );
              },
              child: const Text('Open Details'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      expect(find.text(sampleMovie.title), findsAtLeastNWidgets(1));

      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Open Details'), findsOneWidget);
    });
  });
}
