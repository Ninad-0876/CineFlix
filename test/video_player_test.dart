import 'package:cineflix/screens/movie/video_player_screen.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleMovie = MovieSeedService.initialDemoMovies.first;

  group('VideoPlayerScreen UI Tests', () {
    testWidgets('Renders header with movie title and back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoPlayerScreen(movie: sampleMovie),
        ),
      );

      expect(find.text(sampleMovie.title), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });
  });
}
