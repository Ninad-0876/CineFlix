import 'package:cineflix/models/movie.dart';
import 'package:cineflix/screens/home/home_screen.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/services/movie_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:cineflix/widgets/hero_banner.dart';
import 'package:cineflix/widgets/movie_card.dart';
import 'package:cineflix/widgets/movie_row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMovieService extends MovieService {
  final List<Movie> mockMovies;

  FakeMovieService(this.mockMovies);

  @override
  Future<List<Movie>> getMovies() async {
    return mockMovies;
  }
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-user-123';

  @override
  String get email => 'user@example.com';

  @override
  String get displayName => 'Demo User';
}

void main() {
  final sampleMovies = MovieSeedService.initialDemoMovies;

  group('MovieCard UI Tests', () {
    testWidgets('Renders MovieCard title, year, and genre', (WidgetTester tester) async {
      final movie = sampleMovies.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: MovieCard(movie: movie),
          ),
        ),
      );

      expect(find.text(movie.title), findsOneWidget);
      expect(find.text('${movie.year}'), findsOneWidget);
      expect(find.text(movie.genre), findsOneWidget);
    });
  });

  group('HeroBanner UI Tests', () {
    testWidgets('Renders HeroBanner featured movie info and buttons', (WidgetTester tester) async {
      final movie = sampleMovies.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: HeroBanner(movie: movie),
          ),
        ),
      );

      expect(find.text('FEATURED'), findsOneWidget);
      expect(find.text(movie.title), findsOneWidget);
      expect(find.text(movie.description), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Play'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'My List'), findsOneWidget);
    });

    testWidgets('Renders fallback hero when movie is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: HeroBanner(movie: null),
          ),
        ),
      );

      expect(find.text('CINEFLIX'), findsOneWidget);
      expect(find.text('Unlimited Movies & TV Shows'), findsOneWidget);
    });
  });

  group('MovieRow UI Tests', () {
    testWidgets('Renders MovieRow title and cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: MovieRow(
              title: 'Trending Now',
              movies: sampleMovies.take(3).toList(),
            ),
          ),
        ),
      );

      expect(find.text('Trending Now'), findsOneWidget);
      expect(find.text(sampleMovies[0].title), findsOneWidget);
      expect(find.text(sampleMovies[1].title), findsOneWidget);
      expect(find.text(sampleMovies[2].title), findsOneWidget);
    });
  });

  group('HomeScreen UI Tests', () {
    testWidgets('Renders HomeScreen with top navigation and movie rows', (WidgetTester tester) async {
      final fakeUser = FakeUser();
      final fakeMovieService = FakeMovieService(sampleMovies);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: HomeScreen(
            user: fakeUser,
            movieService: fakeMovieService,
          ),
        ),
      );

      // Initial loading pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CINEFLIX'), findsWidgets);
      expect(find.text('Trending Now'), findsOneWidget);
      expect(find.text('Popular on CineFlix'), findsOneWidget);
      expect(find.text('New Releases'), findsOneWidget);
    });
  });
}
