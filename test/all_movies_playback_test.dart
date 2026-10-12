import 'package:cineflix/models/movie.dart';
import 'package:cineflix/screens/movie/movie_details_screen.dart';
import 'package:cineflix/screens/movie/video_player_screen.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:cineflix/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<Movie> catalog = MovieSeedService.initialDemoMovies;

  group('Catalog & Playback Pipeline Verification for All 10 Movies', () {
    test('Verify all 10 catalog movies have valid HTTPS video URLs', () {
      expect(catalog.length, equals(10));
      for (final movie in catalog) {
        expect(movie.id.isNotEmpty, true, reason: 'Movie ID must not be empty');
        expect(movie.title.isNotEmpty, true, reason: 'Movie title must not be empty');
        expect(movie.videoUrl.startsWith('https://'), true,
            reason: 'Movie ${movie.id} videoUrl must be an HTTPS URL');
        expect(movie.videoUrl.endsWith('.mp4'), true,
            reason: 'Movie ${movie.id} videoUrl must point directly to an MP4 resource');
      }
    });

    for (final movie in catalog) {
      testWidgets('Movie "${movie.title}" (${movie.id}) - Navigation and Details render',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: MovieDetailsScreen(movie: movie),
          ),
        );

        // Verify correct movie title appears
        expect(find.text(movie.title), findsAtLeastNWidgets(1));
        expect(find.text('${movie.year}'), findsOneWidget);
        expect(find.text(movie.genre), findsOneWidget);
        final playButton = find.widgetWithText(ElevatedButton, 'Play Movie');
        expect(playButton, findsOneWidget);

        await tester.ensureVisible(playButton);
        await tester.tap(playButton);
        await tester.pumpAndSettle();

        expect(find.byType(VideoPlayerScreen), findsOneWidget);
        final VideoPlayerScreen playerWidget =
            tester.widget<VideoPlayerScreen>(find.byType(VideoPlayerScreen));
        expect(playerWidget.movie.id, equals(movie.id));
        expect(playerWidget.movie.title, equals(movie.title));
        expect(playerWidget.movie.videoUrl, equals(movie.videoUrl));
      });

      testWidgets('MovieCard for "${movie.title}" (${movie.id}) opens Details correctly',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: MovieCard(movie: movie),
            ),
          ),
        );

        await tester.tap(find.byType(MovieCard));
        await tester.pumpAndSettle();

        expect(find.byType(MovieDetailsScreen), findsOneWidget);
        final MovieDetailsScreen detailsWidget =
            tester.widget<MovieDetailsScreen>(find.byType(MovieDetailsScreen));
        expect(detailsWidget.movie.id, equals(movie.id));
        expect(detailsWidget.movie.title, equals(movie.title));
      });
    }
  });
}
