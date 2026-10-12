import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/auth_service.dart';
import '../../services/movie_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cineflix_logo.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/movie_row.dart';
import '../movie/movie_details_screen.dart';
import '../my_list/my_list_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final AuthService? authService;
  final MovieService? movieService;

  const HomeScreen({
    super.key,
    required this.user,
    this.authService,
    this.movieService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final MovieService _movieService;

  bool _isLoading = true;
  String? _errorMessage;
  List<Movie> _allMovies = [];

  Movie? _featuredMovie;
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _newReleaseMovies = [];

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _movieService = widget.movieService ?? MovieService();
    _fetchMovieCatalog();
  }

  Future<void> _fetchMovieCatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movies = await _movieService.getMovies();

      if (!mounted) return;

      if (movies.isEmpty) {
        setState(() {
          _allMovies = [];
          _featuredMovie = null;
          _trendingMovies = [];
          _popularMovies = [];
          _newReleaseMovies = [];
          _isLoading = false;
        });
        return;
      }

      // Pick featured movie (or fallback to first movie)
      final featured = movies.firstWhere(
        (m) => m.isFeatured,
        orElse: () => movies.first,
      );

      // Filter category lists
      final trending = movies.where((m) => m.category == 'Trending').toList();
      final popular = movies.where((m) => m.category == 'Popular').toList();
      final newReleases = movies.where((m) => m.category == 'New Releases').toList();

      setState(() {
        _allMovies = movies;
        _featuredMovie = featured;
        _trendingMovies = trending.isNotEmpty ? trending : movies;
        _popularMovies = popular.isNotEmpty ? popular : movies;
        _newReleaseMovies = newReleases.isNotEmpty ? newReleases : movies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load CineFlix. Please check your network connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
  }

  void _navigateToMyList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyListScreen(user: widget.user),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          user: widget.user,
          initialCatalog: _allMovies,
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildNavigationBar(context),

            // Main Body Content
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 850;
    final bool isVerySmall = screenWidth < 450;

    final String displayName = widget.user.displayName?.isNotEmpty == true
        ? widget.user.displayName!
        : (widget.user.email?.contains('@') == true
            ? widget.user.email!.split('@')[0]
            : 'User');

    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
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
          // CineFlix Branding Logo
          CineflixLogo(fontSize: isVerySmall ? 18 : 22),

          // Desktop Nav Items (Home, Movies, My List)
          if (!isCompact) ...[
            const SizedBox(width: 28),
            _buildNavItem('Home', isActive: true),
            const SizedBox(width: 20),
            _buildNavItem('Movies', isActive: false),
            const SizedBox(width: 20),
            _buildNavItem('My List', isActive: false, onTap: _navigateToMyList),
          ],

          const Spacer(),

          // Right Controls: Search Icon
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _navigateToSearch,
            icon: const Icon(Icons.search, color: AppTheme.textPrimary, size: 20),
            tooltip: 'Search',
          ),
          const SizedBox(width: 12),

          // User Avatar & Display Name (Clickable to Profile)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _navigateToProfile,
              child: Row(
                children: [
                  CircleAvatar(
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
                  if (!isCompact) ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
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
    );
  }

  Widget _buildNavItem(String label, {required bool isActive, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _navigateToMovieDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_allMovies.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchMovieCatalog,
      color: AppTheme.primaryRed,
      backgroundColor: AppTheme.surfaceColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Section
            HeroBanner(movie: _featuredMovie),

            // Trending Row
            MovieRow(
              title: 'Trending Now',
              movies: _trendingMovies,
              onMovieTap: _navigateToMovieDetails,
            ),

            // Popular Row
            MovieRow(
              title: 'Popular on CineFlix',
              movies: _popularMovies,
              onMovieTap: _navigateToMovieDetails,
            ),

            // New Releases Row
            MovieRow(
              title: 'New Releases',
              movies: _newReleaseMovies,
              onMovieTap: _navigateToMovieDetails,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CineflixLogo(fontSize: 36),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
          SizedBox(height: 16),
          Text(
            'Loading catalog...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unable to load CineFlix',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchMovieCatalog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 44),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_filter_outlined,
              color: AppTheme.textMuted,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'No movies available yet.',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check back later or refresh the catalog.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchMovieCatalog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 44),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
