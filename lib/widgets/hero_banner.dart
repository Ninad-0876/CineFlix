import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie/movie_details_screen.dart';
import '../screens/movie/video_player_screen.dart';
import '../theme/app_theme.dart';
import 'cineflix_logo.dart';

class HeroBanner extends StatelessWidget {
  final Movie? movie;

  const HeroBanner({
    super.key,
    this.movie,
  });

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '';
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }

  void _navigateToDetails(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  void _navigateToPlayer(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final double bannerHeight = isMobile ? 360 : 480;

    if (movie == null) {
      return _buildFallbackHero(bannerHeight);
    }

    final Movie activeMovie = movie!;
    final String formattedDuration = _formatDuration(activeMovie.duration);

    return Container(
      width: double.infinity,
      height: bannerHeight,
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop Image
          Image.network(
            activeMovie.backdropUrl.isNotEmpty
                ? activeMovie.backdropUrl
                : activeMovie.posterUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.surfaceColor,
                child: const Center(
                  child: CineflixLogo(fontSize: 32),
                ),
              );
            },
          ),

          // Dark Radial & Linear Gradients for Readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.1),
                  AppTheme.backgroundColor.withValues(alpha: 0.8),
                  AppTheme.backgroundColor,
                ],
                stops: const [0.0, 0.3, 0.75, 1.0],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.backgroundColor.withValues(alpha: 0.9),
                  AppTheme.backgroundColor.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.8],
              ),
            ),
          ),

          // Content Box
          Positioned(
            left: isMobile ? 20 : 40,
            right: isMobile ? 20 : 120,
            bottom: isMobile ? 24 : 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tag / Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Movie Title
                Text(
                  activeMovie.title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: isMobile ? 28 : 42,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),

                // Meta Info: Year, Genre, Duration
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${activeMovie.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.textMuted),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        activeMovie.genre,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (formattedDuration.isNotEmpty)
                      Text(
                        formattedDuration,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  activeMovie.description,
                  maxLines: isMobile ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: isMobile ? 13 : 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Actions: Play Button & + My List Button
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    // Play Button (Primary) - Navigates to VideoPlayerScreen
                    ElevatedButton.icon(
                      onPressed: () => _navigateToPlayer(context, activeMovie),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(isMobile ? 120 : 140, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                      label: const Text(
                        'Play',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // More Info Button - Navigates to MovieDetailsScreen
                    OutlinedButton.icon(
                      onPressed: () => _navigateToDetails(context, activeMovie),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        minimumSize: Size(isMobile ? 120 : 140, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 22),
                      label: const Text(
                        'More Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // + My List Button (Secondary / Disabled visual)
                    OutlinedButton.icon(
                      onPressed: null, // Visually present but disabled for now
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        minimumSize: Size(isMobile ? 130 : 150, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white, size: 22),
                      label: const Text(
                        'My List',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHero(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppTheme.surfaceColor,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CineflixLogo(fontSize: 40),
            SizedBox(height: 12),
            Text(
              'Unlimited Movies & TV Shows',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
