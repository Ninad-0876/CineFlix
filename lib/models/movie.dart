import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String backdropUrl;
  final String videoUrl;
  final String genre;
  final int year;
  final int duration;
  final String category;
  final bool isFeatured;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.backdropUrl,
    required this.videoUrl,
    required this.genre,
    required this.year,
    required this.duration,
    required this.category,
    required this.isFeatured,
  });

  /// Factory constructor to safely construct a Movie from a Firestore DocumentSnapshot
  factory Movie.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return Movie.fromMap(data, doc.id);
  }

  /// Helper factory to parse Map data with default fallbacks for missing or null fields
  factory Movie.fromMap(Map<String, dynamic> data, String id) {
    return Movie(
      id: id,
      title: (data['title'] as String?)?.trim() ?? 'Untitled Movie',
      description: (data['description'] as String?)?.trim() ?? '',
      posterUrl: (data['posterUrl'] as String?)?.trim() ?? '',
      backdropUrl: (data['backdropUrl'] as String?)?.trim() ?? '',
      videoUrl: (data['videoUrl'] as String?)?.trim() ?? '',
      genre: (data['genre'] as String?)?.trim() ?? 'General',
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      category: (data['category'] as String?)?.trim() ?? 'Trending',
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }

  /// Converts Movie instance into a Firestore-compatible Map format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'videoUrl': videoUrl,
      'genre': genre,
      'year': year,
      'duration': duration,
      'category': category,
      'isFeatured': isFeatured,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          posterUrl == other.posterUrl &&
          backdropUrl == other.backdropUrl &&
          videoUrl == other.videoUrl &&
          genre == other.genre &&
          year == other.year &&
          duration == other.duration &&
          category == other.category &&
          isFeatured == other.isFeatured;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      posterUrl.hashCode ^
      backdropUrl.hashCode ^
      videoUrl.hashCode ^
      genre.hashCode ^
      year.hashCode ^
      duration.hashCode ^
      category.hashCode ^
      isFeatured.hashCode;
}
