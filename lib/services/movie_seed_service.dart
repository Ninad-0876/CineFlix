import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/demo_media.dart';
import '../models/movie.dart';

class MovieSeedService {
  final FirebaseFirestore? firestore;

  MovieSeedService({this.firestore});

  FirebaseFirestore get _firestoreInstance => firestore ?? FirebaseFirestore.instance;

  /// List of initial fictional demo movies
  static List<Movie> get initialDemoMovies => [
        Movie(
          id: 'neon-city',
          title: 'Neon City',
          description:
              'In a city ruled by algorithms, a young hacker discovers a hidden signal that could change everything.',
          posterUrl: DemoMedia.posterNeonCity,
          backdropUrl: DemoMedia.backdropNeonCity,
          videoUrl: DemoMedia.defaultVideoUrl,
          genre: 'Sci-Fi / Thriller',
          year: 2026,
          duration: 118,
          category: 'Trending',
          isFeatured: true,
        ),
        Movie(
          id: 'the-last-signal',
          title: 'The Last Signal',
          description:
              "After the world's communication network goes silent, an engineer races to discover who sent the final transmission.",
          posterUrl: DemoMedia.posterLastSignal,
          backdropUrl: DemoMedia.backdropLastSignal,
          videoUrl: DemoMedia.sciFiVideoUrl,
          genre: 'Mystery / Sci-Fi',
          year: 2025,
          duration: 124,
          category: 'Popular',
          isFeatured: true,
        ),
        Movie(
          id: 'beyond-earth',
          title: 'Beyond Earth',
          description:
              "A deep-space expedition discovers something that challenges humanity's understanding of life.",
          posterUrl: DemoMedia.posterBeyondEarth,
          backdropUrl: DemoMedia.backdropBeyondEarth,
          videoUrl: DemoMedia.sciFiVideoUrl,
          genre: 'Sci-Fi / Adventure',
          year: 2026,
          duration: 132,
          category: 'New Releases',
          isFeatured: false,
        ),
        Movie(
          id: 'midnight-run',
          title: 'Midnight Run',
          description:
              'One night. One package. One city hunting the courier who knows too much.',
          posterUrl: DemoMedia.posterMidnightRun,
          backdropUrl: DemoMedia.backdropMidnightRun,
          videoUrl: DemoMedia.actionVideoUrl,
          genre: 'Action / Thriller',
          year: 2025,
          duration: 109,
          category: 'Trending',
          isFeatured: false,
        ),
        Movie(
          id: 'code-zero',
          title: 'Code Zero',
          description:
              'A cybersecurity analyst discovers a program capable of predicting crimes before they happen.',
          posterUrl: DemoMedia.posterCodeZero,
          backdropUrl: DemoMedia.backdropCodeZero,
          videoUrl: DemoMedia.defaultVideoUrl,
          genre: 'Techno-Thriller',
          year: 2026,
          duration: 116,
          category: 'Popular',
          isFeatured: false,
        ),
        Movie(
          id: 'echoes',
          title: 'Echoes',
          description:
              'A filmmaker returns to his hometown and uncovers recordings connected to a decades-old mystery.',
          posterUrl: DemoMedia.posterEchoes,
          backdropUrl: DemoMedia.backdropEchoes,
          videoUrl: DemoMedia.sciFiVideoUrl,
          genre: 'Drama / Mystery',
          year: 2024,
          duration: 105,
          category: 'Popular',
          isFeatured: false,
        ),
        Movie(
          id: 'forgotten-planet',
          title: 'The Forgotten Planet',
          description:
              'An abandoned colony sends a distress signal years after it was declared lost.',
          posterUrl: DemoMedia.posterForgottenPlanet,
          backdropUrl: DemoMedia.backdropForgottenPlanet,
          videoUrl: DemoMedia.sciFiVideoUrl,
          genre: 'Sci-Fi / Adventure',
          year: 2025,
          duration: 127,
          category: 'New Releases',
          isFeatured: false,
        ),
        Movie(
          id: 'dark-horizon',
          title: 'Dark Horizon',
          description:
              'When an unexplained object appears beyond the moon, humanity faces an impossible decision.',
          posterUrl: DemoMedia.posterDarkHorizon,
          backdropUrl: DemoMedia.backdropDarkHorizon,
          videoUrl: DemoMedia.defaultVideoUrl,
          genre: 'Sci-Fi / Thriller',
          year: 2026,
          duration: 121,
          category: 'Trending',
          isFeatured: false,
        ),
        Movie(
          id: 'parallel',
          title: 'Parallel',
          description:
              'A student discovers a version of himself living a completely different life in a parallel world.',
          posterUrl: DemoMedia.posterParallel,
          backdropUrl: DemoMedia.backdropParallel,
          videoUrl: DemoMedia.sciFiVideoUrl,
          genre: 'Sci-Fi / Drama',
          year: 2025,
          duration: 112,
          category: 'New Releases',
          isFeatured: false,
        ),
        Movie(
          id: 'final-protocol',
          title: 'Final Protocol',
          description:
              'An AI security system activates a protocol that its creators never intended to use.',
          posterUrl: DemoMedia.posterFinalProtocol,
          backdropUrl: DemoMedia.backdropFinalProtocol,
          videoUrl: DemoMedia.actionVideoUrl,
          genre: 'Action / Sci-Fi',
          year: 2026,
          duration: 119,
          category: 'Popular',
          isFeatured: false,
        ),
      ];

  /// Idempotent seed function. Creates initial movies if they do not exist.
  Future<void> seedMovies() async {
    final CollectionReference<Map<String, dynamic>> moviesRef =
        _firestoreInstance.collection('movies');

    for (final Movie movie in initialDemoMovies) {
      try {
        final DocumentReference<Map<String, dynamic>> docRef =
            moviesRef.doc(movie.id);
        final DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

        if (!doc.exists) {
          await docRef.set(movie.toFirestore());
          debugPrint('Successfully seeded movie: ${movie.id}');
        } else {
          debugPrint('Movie already exists, skipping: ${movie.id}');
        }
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          debugPrint(
            'Client seeding blocked by Firestore security rules. Use admin seeding script scripts/seed_movies.js.',
          );
        } else {
          debugPrint('Firebase error seeding movie ${movie.id}: ${e.message}');
        }
      } catch (e) {
        debugPrint('Unexpected error seeding movie ${movie.id}: $e');
      }
    }
  }
}
