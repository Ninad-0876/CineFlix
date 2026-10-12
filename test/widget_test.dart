import 'dart:async';
import 'package:cineflix/screens/auth/login_screen.dart';
import 'package:cineflix/screens/auth/register_screen.dart';
import 'package:cineflix/services/auth_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthService extends AuthService {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    throw FirebaseAuthException(code: 'user-not-found');
  }

  @override
  Future<UserCredential> registerWithEmail(String email, String password, {String? name}) async {
    throw FirebaseAuthException(code: 'email-already-in-use');
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    throw FirebaseAuthException(code: 'popup-closed-by-user');
  }

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }
}

void main() {
  group('AuthService friendly error messages', () {
    test('formats FirebaseAuthException codes correctly', () {
      final excNotFound = FirebaseAuthException(code: 'user-not-found');
      expect(
        AuthService.getFriendlyErrorMessage(excNotFound),
        'No user found with this email address.',
      );

      final excWrongPassword = FirebaseAuthException(code: 'wrong-password');
      expect(
        AuthService.getFriendlyErrorMessage(excWrongPassword),
        'Incorrect password. Please try again.',
      );

      final excEmailInUse = FirebaseAuthException(code: 'email-already-in-use');
      expect(
        AuthService.getFriendlyErrorMessage(excEmailInUse),
        'An account already exists with this email address.',
      );

      final excPopupCanceled = FirebaseAuthException(code: 'popup-closed-by-user');
      expect(
        AuthService.getFriendlyErrorMessage(excPopupCanceled),
        'Google sign-in was canceled.',
      );
    });
  });

  group('LoginScreen UI Tests', () {
    testWidgets('Renders LoginScreen fields and buttons', (WidgetTester tester) async {
      final fakeAuth = FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: LoginScreen(authService: fakeAuth),
        ),
      );

      expect(find.text('CINEFLIX'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Sign up now.'), findsOneWidget);
    });

    testWidgets('Validates email and password inputs', (WidgetTester tester) async {
      final fakeAuth = FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: LoginScreen(authService: fakeAuth),
        ),
      );

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });

  group('RegisterScreen UI Tests', () {
    testWidgets('Renders RegisterScreen fields and title', (WidgetTester tester) async {
      final fakeAuth = FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: RegisterScreen(authService: fakeAuth),
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('Validates password confirmation mismatch', (WidgetTester tester) async {
      final fakeAuth = FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: RegisterScreen(authService: fakeAuth),
        ),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'different123');

      final createAccountButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createAccountButton);
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
