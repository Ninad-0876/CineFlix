import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cineflix_logo.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AuthGate extends StatelessWidget {
  final AuthService? authService;

  const AuthGate({
    super.key,
    this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService auth = authService ?? AuthService();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase initializing or checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        // User logged in -> temporary HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(
            user: snapshot.data!,
            authService: auth,
          );
        }

        // User logged out -> LoginScreen
        return LoginScreen(authService: auth);
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CineflixLogo(fontSize: 48),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
            ),
          ],
        ),
      ),
    );
  }
}
