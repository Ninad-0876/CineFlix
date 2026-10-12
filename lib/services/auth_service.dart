import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  AuthService({
    this.auth,
    this.firestore,
  });

  FirebaseAuth get _authInstance => auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestoreInstance => firestore ?? FirebaseFirestore.instance;

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() => _authInstance.authStateChanges();

  /// Gets the currently authenticated user
  User? get currentUser => _authInstance.currentUser;

  /// Sign in using email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _authInstance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register a new user using email and password
  /// Accepts optional [name] to create the Firestore user profile.
  Future<UserCredential> registerWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    final UserCredential credential = await _authInstance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      final User user = credential.user!;
      if (name != null && name.trim().isNotEmpty) {
        try {
          await user.updateDisplayName(name.trim());
        } catch (e) {
          debugPrint('Failed to update display name: $e');
        }
      }

      // Create user document in Firestore (never store password)
      await _syncUserProfile(
        user: user,
        providedName: name,
      );
    }

    return credential;
  }

  /// Sign in with Google (Web flow)
  Future<UserCredential> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    googleProvider.addScope('email');
    googleProvider.addScope('profile');

    UserCredential userCredential;
    if (kIsWeb) {
      userCredential = await _authInstance.signInWithPopup(googleProvider);
    } else {
      userCredential = await _authInstance.signInWithProvider(googleProvider);
    }

    if (userCredential.user != null) {
      await _syncUserProfile(user: userCredential.user!);
    }

    return userCredential;
  }

  /// Helper to create or maintain user profile in Firestore
  /// Document path: users/{uid}
  /// Data: { name, email, createdAt }
  /// Will NOT overwrite existing profile if document already exists.
  Future<void> _syncUserProfile({
    required User user,
    String? providedName,
  }) async {
    try {
      final DocumentReference userDocRef = _firestoreInstance.collection('users').doc(user.uid);
      final DocumentSnapshot docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        final String email = user.email ?? '';
        final String name = (providedName != null && providedName.trim().isNotEmpty)
            ? providedName.trim()
            : (user.displayName != null && user.displayName!.trim().isNotEmpty)
                ? user.displayName!.trim()
                : (email.contains('@') ? email.split('@')[0] : 'User');

        await userDocRef.set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error writing user profile to Firestore: $e');
    }
  }

  /// Updates the user's display name in Firebase Auth and Firestore user doc
  Future<void> updateUserDisplayName(String newName) async {
    final String cleanName = newName.trim();
    if (cleanName.isEmpty) {
      throw Exception('Display name cannot be empty.');
    }
    if (cleanName.length > 50) {
      throw Exception('Display name must be 50 characters or less.');
    }

    final User? user = currentUser;
    if (user != null) {
      await user.updateDisplayName(cleanName);
      try {
        await _firestoreInstance.collection('users').doc(user.uid).update({
          'name': cleanName,
        });
      } catch (e) {
        debugPrint('Error updating Firestore user name: $e');
      }
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _authInstance.signOut();
  }

  /// Utility to get friendly error messages from Firebase exceptions
  static String getFriendlyErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 6 characters.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials.';
        case 'popup-closed-by-user':
        case 'canceled':
          return 'Google sign-in was canceled.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return error.message ?? 'An authentication error occurred (${error.code}).';
      }
    }
    return error.toString();
  }
}
