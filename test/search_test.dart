import 'package:cineflix/models/movie.dart';
import 'package:cineflix/screens/movie/movie_details_screen.dart';
import 'package:cineflix/screens/search/search_screen.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/services/movie_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:cineflix/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockMovieService extends MovieService {
  final List<Movie> catalog;

  MockMovieService(this.catalog);

  @override
  Future<List<Movie>> getMovies() async {
    return List<Movie>.from(catalog);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    return MovieService.filterMoviesLocal(catalog, query);
  }
}

void main() {
  final List<Movie> demoMovies = MovieSeedService.initialDemoMovies;

  group('MovieService.filterMoviesLocal Logic Tests', () {
    test('Empty or whitespace query returns empty list', () {
      expect(MovieService.filterMoviesLocal(demoMovies, ''), isEmpty);
      expect(MovieService.filterMoviesLocal(demoMovies, '   '), isEmpty);
    });

    test('Exact title search', () {
      final results = MovieService.filterMoviesLocal(demoMovies, 'Neon City');
      expect(results.length, equals(1));
      expect(results.first.title, equals('Neon City'));
    });

    test('Partial title search (case-insensitive & trimmed)', () {
      final results = MovieService.filterMoviesLocal(demoMovies, '  neon  ');
      expect(results.length, equals(1));
      expect(results.first.title, equals('Neon City'));
    });

    test('Genre search', () {
      final sciFiResults = MovieService.filterMoviesLocal(demoMovies, 'sci-fi');
      expect(sciFiResults.isNotEmpty, isTrue);
      expect(sciFiResults.every((m) => m.genre.toLowerCase().contains('sci-fi')), isTrue);

      final thrillerResults = MovieService.filterMoviesLocal(demoMovies, 'thriller');
      expect(thrillerResults.isNotEmpty, isTrue);
    });

    test('Year search', () {
      final y2026 = MovieService.filterMoviesLocal(demoMovies, '2026');
      expect(y2026.isNotEmpty, isTrue);
      expect(y2026.every((m) => m.year == 2026), isTrue);
    });

    test('Description search', () {
      final results = MovieService.filterMoviesLocal(demoMovies, 'algorithms');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((m) => m.description.toLowerCase().contains('algorithms')), isTrue);
    });

    test('No-results query', () {
      final results = MovieService.filterMoviesLocal(demoMovies, 'xyzabc12345');
      expect(results, isEmpty);
    });

    test('Multiple matching movies returned', () {
      final results = MovieService.filterMoviesLocal(demoMovies, 'Action');
      expect(results.length, greaterThan(1));
    });
  });

  group('SearchScreen UI Tests', () {
    testWidgets('Renders empty search prompt initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SearchScreen(
            initialCatalog: demoMovies,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Search CineFlix'), findsOneWidget);
      expect(
        find.text('Find movies, genres and stories you want to watch.'),
        findsOneWidget,
      );
      expect(find.byType(MovieCard), findsNothing);
    });

    testWidgets('Displays search results when typing query', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SearchScreen(
            initialCatalog: demoMovies,
          ),
        ),
      );

      await tester.pump();

      // Enter search query "Neon"
      await tester.enterText(find.byType(TextField), 'Neon');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Search Results (1)'), findsOneWidget);
      expect(find.text('Neon City'), findsAtLeastNWidgets(1));
      expect(find.byType(MovieCard), findsOneWidget);
    });

    testWidgets('Renders no-results state for non-matching query', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SearchScreen(
            initialCatalog: demoMovies,
          ),
        ),
      );

      await tester.pump();

      await tester.enterText(find.byType(TextField), 'nonexistentmovie999');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No results found'), findsOneWidget);
      expect(
        find.text('Try searching for another movie, genre, or year.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'Browse Movies'), findsOneWidget);
    });

    testWidgets('Clear button resets search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SearchScreen(
            initialCatalog: demoMovies,
          ),
        ),
      );

      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Neon');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MovieCard), findsOneWidget);

      final clearButton = find.byTooltip('Clear Search');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Search CineFlix'), findsOneWidget);
      expect(find.byType(MovieCard), findsNothing);
    });

    testWidgets('Tapping search result opens MovieDetailsScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SearchScreen(
            initialCatalog: demoMovies,
            initialQuery: 'Neon',
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MovieCard), findsOneWidget);
      await tester.tap(find.byType(MovieCard));
      await tester.pumpAndSettle();

      expect(find.byType(MovieDetailsScreen), findsOneWidget);
      expect(find.text('Neon City'), findsAtLeastNWidgets(1));
    });
  });
}
