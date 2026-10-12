import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/auth_service.dart';
import '../../services/movie_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cineflix_logo.dart';
import '../../widgets/movie_card.dart';
import '../movie/movie_details_screen.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final User? user;
  final MovieService? movieService;
  final AuthService? authService;
  final List<Movie>? initialCatalog;
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.user,
    this.movieService,
    this.authService,
    this.initialCatalog,
    this.initialQuery,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final MovieService _movieService;
  late final AuthService _authService;
  late final User? _user;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Movie> _catalog = [];
  List<Movie> _searchResults = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _debounceTimer;
  User? _safeCurrentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _movieService = widget.movieService ?? MovieService();
    _authService = widget.authService ?? AuthService();
    _user = widget.user ?? _safeCurrentUser();

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }

    if (widget.initialCatalog != null && widget.initialCatalog!.isNotEmpty) {
      _catalog = List<Movie>.from(widget.initialCatalog!);
      _isLoading = false;
      _searchResults = MovieService.filterMoviesLocal(_catalog, _searchController.text);
    } else {
      _fetchCatalog();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCatalog() async {
    try {
      final catalog = await _movieService.getMovies();
      if (mounted) {
        setState(() {
          _catalog = catalog;
          _isLoading = false;
          _searchResults = MovieService.filterMoviesLocal(_catalog, _searchController.text);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load movie catalog.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    final results = MovieService.filterMoviesLocal(_catalog, query);
    setState(() {
      _searchResults = results;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
    _searchFocusNode.requestFocus();
  }

  void _navigateToDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
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
            // Top Bar & Search Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor.withValues(alpha: 0.95),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        tooltip: 'Back',
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(width: 4),

                      // CineFlix Logo
                      const CineflixLogo(fontSize: 20),
                      const Spacer(),

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
                  const SizedBox(height: 12),

                  // Search Text Field Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus
                            ? AppTheme.primaryRed
                            : Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      autofocus: true,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search CineFlix...',
                        hintStyle: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: AppTheme.textMuted,
                                  size: 18,
                                ),
                                tooltip: 'Clear Search',
                                onPressed: _clearSearch,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Body Area
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchCatalog,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final String query = _searchController.text.trim();

    // 1. Initial Empty Search State (User has not typed anything)
    if (query.isEmpty) {
      return _buildEmptySearchPrompt();
    }

    // 2. No Results State (Query typed, but zero matching movies found)
    if (_searchResults.isEmpty) {
      return _buildNoResultsState(query);
    }

    // 3. Results Grid State
    return _buildResultsGrid(_searchResults);
  }

  Widget _buildEmptySearchPrompt() {
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
                Icons.search,
                color: AppTheme.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Search CineFlix',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find movies, genres and stories you want to watch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
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
                Icons.sentiment_dissatisfied,
                color: AppTheme.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No results found',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for another movie, genre, or year.',
              textAlign: TextAlign.center,
              style: const TextStyle(
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

  Widget _buildResultsGrid(List<Movie> movies) {
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
                'Search Results (${movies.length})',
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
