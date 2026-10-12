import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class MyListService {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  MyListService({this.firestore, this.auth});

  FirebaseFirestore get _firestoreInstance => firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _authInstance => auth ?? FirebaseAuth.instance;

  String? get currentUserId {
    try {
      return _authInstance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userMyListRef([String? customUserId]) {
    final uid = customUserId ?? currentUserId;
    if (uid == null || uid.trim().isEmpty) return null;
    try {
      return _firestoreInstance
          .collection('users')
          .doc(uid.trim())
          .collection('myList');
    } catch (_) {
      return null;
    }
  }

  /// Saves a movie to the authenticated user's My List subcollection
  Future<bool> addToMyList(Movie movie, {String? userId}) async {
    final ref = _userMyListRef(userId);
    if (ref == null) {
      debugPrint('[MyListService] User is unauthenticated. Cannot add to My List.');
      return false;
    }
    if (movie.id.trim().isEmpty) return false;

    try {
      final docData = movie.toFirestore();
      docData['addedAt'] = FieldValue.serverTimestamp();
      await ref.doc(movie.id).set(docData, SetOptions(merge: true));
      debugPrint('[MyListService] Saved movie "${movie.title}" (${movie.id}) to My List.');
      return true;
    } catch (e) {
      debugPrint('[MyListService] Error adding movie ${movie.id} to My List: $e');
      return false;
    }
  }

  /// Removes a movie from the authenticated user's My List subcollection
  Future<bool> removeFromMyList(String movieId, {String? userId}) async {
    final ref = _userMyListRef(userId);
    if (ref == null) {
      debugPrint('[MyListService] User is unauthenticated. Cannot remove from My List.');
      return false;
    }
    final cleanId = movieId.trim();
    if (cleanId.isEmpty) return false;

    try {
      await ref.doc(cleanId).delete();
      debugPrint('[MyListService] Removed movie ($cleanId) from My List.');
      return true;
    } catch (e) {
      debugPrint('[MyListService] Error removing movie $cleanId from My List: $e');
      return false;
    }
  }

  /// Checks whether a movie is saved in the authenticated user's My List
  Future<bool> isInMyList(String movieId, {String? userId}) async {
    final ref = _userMyListRef(userId);
    if (ref == null) return false;
    final cleanId = movieId.trim();
    if (cleanId.isEmpty) return false;

    try {
      final doc = await ref.doc(cleanId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('[MyListService] Error checking status for movie $cleanId: $e');
      return false;
    }
  }

  /// Fetches a list of all movies saved in the authenticated user's My List once
  Future<List<Movie>> getMyList({String? userId}) async {
    final ref = _userMyListRef(userId);
    if (ref == null) return [];

    try {
      final snapshot = await ref.get();
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('[MyListService] Error fetching My List movies: $e');
      return [];
    }
  }

  /// Real-time stream of all movies saved in the authenticated user's My List
  Stream<List<Movie>> watchMyList({String? userId}) {
    final ref = _userMyListRef(userId);
    if (ref == null) return Stream.value(<Movie>[]);

    try {
      return ref.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      }).handleError((error) {
        debugPrint('[MyListService] Error streaming My List: $error');
        return <Movie>[];
      });
    } catch (e) {
      debugPrint('[MyListService] Exception subscribing to watchMyList: $e');
      return Stream.value(<Movie>[]);
    }
  }

  /// Real-time stream checking whether a specific movie is in current user's My List
  Stream<bool> watchIsInMyList(String movieId, {String? userId}) {
    final ref = _userMyListRef(userId);
    if (ref == null || movieId.trim().isEmpty) return Stream.value(false);

    try {
      return ref.doc(movieId.trim()).snapshots().map((doc) => doc.exists).handleError((error) {
        debugPrint('[MyListService] Error streaming movie status for $movieId: $error');
        return false;
      });
    } catch (e) {
      debugPrint('[MyListService] Exception subscribing to watchIsInMyList for $movieId: $e');
      return Stream.value(false);
    }
  }
}
