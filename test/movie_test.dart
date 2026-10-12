import 'package:cineflix/models/movie.dart';
import 'package:cineflix/services/movie_seed_service.dart';
import 'package:cineflix/services/movie_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movie Model Serialization Tests', () {
    test('Movie.fromMap handles complete data correctly', () {
      final data = {
        'title': 'Neon City',
        'description': 'A cyberpunk adventure.',
        'posterUrl': 'https://example.com/poster.jpg',
        'backdropUrl': 'https://example.com/backdrop.jpg',
        'videoUrl': 'https://example.com/video.mp4',
        'genre': 'Sci-Fi / Thriller',
        'year': 2026,
        'duration': 118,
        'category': 'Trending',
        'isFeatured': true,
      };

      final movie = Movie.fromMap(data, 'neon-city');

      expect(movie.id, 'neon-city');
      expect(movie.title, 'Neon City');
      expect(movie.description, 'A cyberpunk adventure.');
      expect(movie.posterUrl, 'https://example.com/poster.jpg');
      expect(movie.backdropUrl, 'https://example.com/backdrop.jpg');
      expect(movie.videoUrl, 'https://example.com/video.mp4');
      expect(movie.genre, 'Sci-Fi / Thriller');
      expect(movie.year, 2026);
      expect(movie.duration, 118);
      expect(movie.category, 'Trending');
      expect(movie.isFeatured, true);
    });

    test('Movie.fromMap handles missing/null fields safely', () {
      final Map<String, dynamic> data = {
        'title': null,
        'description': null,
        'year': null,
        'duration': null,
        'isFeatured': null,
      };

      final movie = Movie.fromMap(data, 'missing-fields-id');

      expect(movie.id, 'missing-fields-id');
      expect(movie.title, 'Untitled Movie');
      expect(movie.description, '');
      expect(movie.posterUrl, '');
      expect(movie.backdropUrl, '');
      expect(movie.videoUrl, '');
      expect(movie.genre, 'General');
      expect(movie.duration, 0);
      expect(movie.category, 'Trending');
      expect(movie.isFeatured, false);
    });

    test('Movie.toFirestore converts properties into map format', () {
      const movie = Movie(
        id: 'code-zero',
        title: 'Code Zero',
        description: 'Techno thriller',
        posterUrl: 'https://example.com/p.jpg',
        backdropUrl: 'https://example.com/b.jpg',
        videoUrl: 'https://example.com/v.mp4',
        genre: 'Techno-Thriller',
        year: 2026,
        duration: 116,
        category: 'Popular',
        isFeatured: false,
      );

      final map = movie.toFirestore();

      expect(map['title'], 'Code Zero');
      expect(map['description'], 'Techno thriller');
      expect(map['posterUrl'], 'https://example.com/p.jpg');
      expect(map['backdropUrl'], 'https://example.com/b.jpg');
      expect(map['videoUrl'], 'https://example.com/v.mp4');
      expect(map['genre'], 'Techno-Thriller');
      expect(map['year'], 2026);
      expect(map['duration'], 116);
      expect(map['category'], 'Popular');
      expect(map['isFeatured'], false);
    });
  });

  group('Movie Local Search & Filter Logic Tests', () {
    final sampleMovies = MovieSeedService.initialDemoMovies;

    test('Search matches title case-insensitively', () {
      final resultsUpper = MovieService.filterMoviesLocal(sampleMovies, 'NEON CITY');
      expect(resultsUpper.length, 1);
      expect(resultsUpper.first.id, 'neon-city');

      final resultsLower = MovieService.filterMoviesLocal(sampleMovies, 'signal');
      expect(resultsLower.isNotEmpty, isTrue);
      expect(resultsLower.any((m) => m.id == 'the-last-signal'), isTrue);
    });

    test('Search matches genre case-insensitively', () {
      final actionMovies = MovieService.filterMoviesLocal(sampleMovies, 'action');
      expect(actionMovies.length, 2);
      expect(actionMovies.any((m) => m.id == 'midnight-run'), isTrue);
      expect(actionMovies.any((m) => m.id == 'final-protocol'), isTrue);
    });

    test('Search returns empty list for non-matching query', () {
      final results = MovieService.filterMoviesLocal(sampleMovies, 'nonexistentquery123');
      expect(results, isEmpty);
    });
  });

  group('Movie Seed Service Data Tests', () {
    test('Contains exactly 10 initial demo movies', () {
      final movies = MovieSeedService.initialDemoMovies;
      expect(movies.length, 10);
      expect(movies.any((m) => m.id == 'neon-city'), isTrue);
      expect(movies.any((m) => m.id == 'the-last-signal'), isTrue);
      expect(movies.any((m) => m.id == 'beyond-earth'), isTrue);
      expect(movies.any((m) => m.id == 'midnight-run'), isTrue);
      expect(movies.any((m) => m.id == 'code-zero'), isTrue);
      expect(movies.any((m) => m.id == 'echoes'), isTrue);
      expect(movies.any((m) => m.id == 'forgotten-planet'), isTrue);
      expect(movies.any((m) => m.id == 'dark-horizon'), isTrue);
      expect(movies.any((m) => m.id == 'parallel'), isTrue);
      expect(movies.any((m) => m.id == 'final-protocol'), isTrue);
    });
  });
}
