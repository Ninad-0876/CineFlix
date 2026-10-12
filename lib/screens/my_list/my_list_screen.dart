import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/auth_service.dart';
import '../../services/my_list_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cineflix_logo.dart';
import '../../widgets/movie_card.dart';
import '../movie/movie_details_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

class MyListScreen extends StatefulWidget {
  final User? user;
  final MyListService? myListService;
  final AuthService? authService;

  const MyListScreen({
    super.key,
    this.user,
    this.myListService,
    this.authService,
  });

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  late final MyListService _myListService;
  late final AuthService _authService;
  late final User? _user;

  @override
  void initState() {
    super.initState();
    _myListService = widget.myListService ?? MyListService();
    _authService = widget.authService ?? AuthService();
    _user = widget.user ?? FirebaseAuth.instance.currentUser;
  }

  void _navigateToDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(user: _user),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(user: _user),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isVerySmall = screenWidth < 450;
    final bool isCompact = screenWidth < 850;

    final String displayName = _user?.displayName?.isNotEmpty == true
        ? _user!.displayName!
        : (_user?.email?.contains('@') == true
            ? _user!.email!.split('@')[0]
            : 'User');

    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmall ? 12 : 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor.withValues(alpha: 0.95),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Back Button to Home
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    tooltip: 'Back to Home',
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 4),

                  // CineFlix Logo
                  const CineflixLogo(fontSize: 20),

                  if (!isCompact) ...[
                    const SizedBox(width: 28),
                    GestureDetector(
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        'Home',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'My List',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Search Icon
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _navigateToSearch,
                    icon: const Icon(Icons.search, color: AppTheme.textPrimary, size: 20),
                    tooltip: 'Search',
                  ),
                  const SizedBox(width: 12),

                  // User Avatar (Clickable to Profile)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _navigateToProfile,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.primaryRed,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Logout Button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _handleSignOut,
                    icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            // Content Area Stream
            Expanded(
              child: StreamBuilder<List<Movie>>(
                stream: _myListService.watchMyList(userId: _user?.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load My List.',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final movies = snapshot.data ?? [];

                  if (movies.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildMovieGrid(context, movies);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.bookmark_border,
                color: AppTheme.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your List is Empty',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Movies you add to My List will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.explore),
              label: const Text(
                'Browse Movies',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieGrid(BuildContext context, List<Movie> movies) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth < 500
        ? 2
        : screenWidth < 800
            ? 3
            : screenWidth < 1100
                ? 4
                : 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'My List (${movies.length})',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movies.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.56,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                width: double.infinity,
                onTap: () => _navigateToDetails(movie),
              );
            },
          ),
        ],
      ),
    );
  }
}
