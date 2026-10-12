import 'package:cineflix/models/movie.dart';
import 'package:cineflix/screens/home/home_screen.dart';
import 'package:cineflix/screens/movie/movie_details_screen.dart';
import 'package:cineflix/screens/movie/video_player_screen.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/services/movie_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:cineflix/widgets/movie_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockMovieService extends MovieService {
  final List<Movie> mockMovies;
  MockMovieService(this.mockMovies);

  @override
  Future<List<Movie>> getMovies() async {
    return mockMovies;
  }
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-user-123';

  @override
  String get email => 'user@cineflix.com';

  @override
  String get displayName => 'Test User';
}

void main() {
  final fakeUser = FakeUser();
  final List<Movie> catalog = MovieSeedService.initialDemoMovies;

  group('HomeScreen Full Interactive Navigation Audit for All Movies', () {
    testWidgets('Tapping every movie card on Home opens its exact MovieDetailsScreen & Play opens VideoPlayerScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: HomeScreen(
            user: fakeUser,
            movieService: MockMovieService(catalog),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Home loaded and displayed movie cards
      expect(find.byType(MovieCard), findsAtLeastNWidgets(5));

      // Test specific movies across Trending, Popular, and New Releases rows
      final moviesToTest = [
        'dark-horizon',
        'midnight-run',
        'code-zero',
        'the-last-signal',
        'beyond-earth',
      ];

      for (final movieId in moviesToTest) {
        final movie = catalog.firstWhere((m) => m.id == movieId);

        // Find the specific card with title
        final cardFinder = find.widgetWithText(MovieCard, movie.title).first;
        expect(cardFinder, findsOneWidget);

        await tester.ensureVisible(cardFinder);
        await tester.tap(cardFinder);
        await tester.pumpAndSettle();

        // 1. Confirm MovieDetailsScreen opened for exact movie
        expect(find.byType(MovieDetailsScreen), findsOneWidget);
        final detailsScreen = tester.widget<MovieDetailsScreen>(find.byType(MovieDetailsScreen));
        expect(detailsScreen.movie.id, equals(movie.id));
        expect(detailsScreen.movie.title, equals(movie.title));

        // 2. Tap Play Movie button
        final playButton = find.widgetWithText(ElevatedButton, 'Play Movie');
        expect(playButton, findsOneWidget);
        await tester.ensureVisible(playButton);
        await tester.tap(playButton);
        await tester.pumpAndSettle();

        // 3. Confirm VideoPlayerScreen opened for exact movie
        expect(find.byType(VideoPlayerScreen), findsOneWidget);
        final playerScreen = tester.widget<VideoPlayerScreen>(find.byType(VideoPlayerScreen));
        expect(playerScreen.movie.id, equals(movie.id));
        expect(playerScreen.movie.title, equals(movie.title));
        expect(playerScreen.movie.videoUrl, equals(movie.videoUrl));

        // Pop player screen back to details
        final backFromPlayer = find.byTooltip('Back');
        expect(backFromPlayer, findsOneWidget);
        await tester.tap(backFromPlayer);
        await tester.pumpAndSettle();

        // Pop details screen back to Home
        final backFromDetails = find.byTooltip('Back');
        expect(backFromDetails, findsOneWidget);
        await tester.tap(backFromDetails);
        await tester.pumpAndSettle();

        // Verify returned to Home screen
        expect(find.byType(HomeScreen), findsOneWidget);
      }
    });
  });
}
