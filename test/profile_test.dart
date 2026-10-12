import 'package:cineflix/screens/profile/profile_screen.dart';
import 'package:cineflix/services/auth_service.dart';
import 'package:cineflix/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUserWithProfile extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;
  final List<UserInfo> _providerDataList;

  FakeUserWithProfile({
    this.uid = 'test-uid-123',
    this.email = 'alex@example.com',
    this.displayName = 'Alex Miller',
    this.photoURL,
    List<UserInfo>? providerData,
  }) : _providerDataList = providerData ?? [];

  @override
  List<UserInfo> get providerData => _providerDataList;

  @override
  Future<void> updateDisplayName(String? name) async {}
}

class FakeUserInfo extends Fake implements UserInfo {
  final String _providerId;

  FakeUserInfo(this._providerId);

  @override
  String get providerId => _providerId;
}

class MockAuthServiceWithProfile extends AuthService {
  bool signOutCalled = false;
  String? updatedName;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<void> updateUserDisplayName(String newName) async {
    updatedName = newName;
  }
}

void main() {
  group('ProfileScreen UI & Information Tests', () {
    testWidgets('Renders authenticated user info (email, name, provider)', (WidgetTester tester) async {
      final user = FakeUserWithProfile(
        displayName: 'Sarah Connor',
        email: 'sarah@example.com',
        providerData: [FakeUserInfo('google.com')],
      );
      final mockAuth = MockAuthServiceWithProfile();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProfileScreen(
            user: user,
            authService: mockAuth,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sarah Connor'), findsOneWidget);
      expect(find.text('sarah@example.com'), findsAtLeastNWidgets(1));
      expect(find.text('Signed in with Google'), findsAtLeastNWidgets(1));
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('Renders fallback display name when displayName is null', (WidgetTester tester) async {
      final user = FakeUserWithProfile(
        displayName: null,
        email: 'john.doe@example.com',
        providerData: [FakeUserInfo('password')],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProfileScreen(
            user: user,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('john.doe'), findsOneWidget);
      expect(find.text('Signed in with Email'), findsAtLeastNWidgets(1));
    });

    testWidgets('Renders generic fallback when both name and email are empty', (WidgetTester tester) async {
      final user = FakeUserWithProfile(
        displayName: '',
        email: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProfileScreen(
            user: user,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CineFlix User'), findsOneWidget);
    });

    testWidgets('Edit Profile dialog validates and updates display name', (WidgetTester tester) async {
      final user = FakeUserWithProfile(
        displayName: 'Old Name',
        email: 'user@example.com',
      );
      final mockAuth = MockAuthServiceWithProfile();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProfileScreen(
            user: user,
            authService: mockAuth,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Old Name'), findsOneWidget);

      // Tap Edit Profile button
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Display Name'), findsOneWidget);

      // Enter empty name and attempt save
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Display name cannot be empty.'), findsOneWidget);

      // Enter valid new name and save
      await tester.enterText(find.byType(TextField), 'New Awesome Name');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(mockAuth.updatedName, equals('New Awesome Name'));
      expect(find.text('New Awesome Name'), findsOneWidget);
    });

    testWidgets('Log Out button invokes AuthService.signOut', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final user = FakeUserWithProfile();
      final mockAuth = MockAuthServiceWithProfile();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProfileScreen(
            user: user,
            authService: mockAuth,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final logoutButton = find.widgetWithText(ElevatedButton, 'Log Out');
      expect(logoutButton, findsOneWidget);

      await tester.ensureVisible(logoutButton);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(mockAuth.signOutCalled, isTrue);
    });
  });
}
