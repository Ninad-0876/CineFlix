import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore? firestore;

  MovieService({this.firestore});

  FirebaseFirestore get _firestoreInstance => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _moviesRef =>
      _firestoreInstance.collection('movies');

  /// Fetches all movies from Firestore `movies` collection
  Future<List<Movie>> getMovies() async {
    try {
      final querySnapshot = await _moviesRef.get();
      return querySnapshot.docs
          .map((doc) => Movie.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching movies: $e');
      return [];
    }
  }

  /// Real-time stream of all movies from Firestore
  Stream<List<Movie>> watchMovies() {
    try {
      return _moviesRef.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Movie.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        debugPrint('Error in watchMovies stream: $error');
        return <Movie>[];
      });
    } catch (e) {
      debugPrint('Error subscribing to watchMovies: $e');
      return Stream.value([]);
    }
  }

  /// Fetches a single movie by its document ID
  Future<Movie?> getMovieById(String movieId) async {
    if (movieId.trim().isEmpty) return null;
    try {
      final doc = await _moviesRef.doc(movieId).get();
      if (doc.exists && doc.data() != null) {
        return Movie.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching movie by ID ($movieId): $e');
      return null;
    }
  }

  /// Fetches movies filtered by category (Trending, Popular, New Releases, Featured)
  Future<List<Movie>> getMoviesByCategory(String category) async {
    final String cleanCategory = category.trim();
    if (cleanCategory.isEmpty) return [];

    try {
      if (cleanCategory.toLowerCase() == 'featured') {
        final querySnapshot = await _moviesRef
            .where('isFeatured', isEqualTo: true)
            .get();
        
        final List<Movie> featuredList = querySnapshot.docs
            .map((doc) => Movie.fromFirestore(doc))
            .toList();

        if (featuredList.isNotEmpty) return featuredList;
      }

      final querySnapshot = await _moviesRef
          .where('category', isEqualTo: cleanCategory)
          .get();

      return querySnapshot.docs
          .map((doc) => Movie.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching movies by category ($category): $e');
      return [];
    }
  }

  /// Performs local case-insensitive search matching title or genre against query
  Future<List<Movie>> searchMovies(String query) async {
    final String cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    try {
      final List<Movie> allMovies = await getMovies();
      return filterMoviesLocal(allMovies, cleanQuery);
    } catch (e) {
      debugPrint('Error searching movies ($query): $e');
      return [];
    }
  }

  /// Helper utility for local filtering of movies matching title, genre, year, or description case-insensitively
  static List<Movie> filterMoviesLocal(List<Movie> movies, String query) {
    final String cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    return movies.where((movie) {
      final String title = movie.title.toLowerCase();
      final String genre = movie.genre.toLowerCase();
      final String year = movie.year.toString();
      final String description = movie.description.toLowerCase();

      return title.contains(cleanQuery) ||
          genre.contains(cleanQuery) ||
          year.contains(cleanQuery) ||
          description.contains(cleanQuery);
    }).toList();
  }
}
