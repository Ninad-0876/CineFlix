import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/my_list_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cineflix_logo.dart';
import 'video_player_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final MyListService? myListService;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    this.myListService,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late final MyListService _myListService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _myListService = widget.myListService ?? MyListService();
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '';
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }

  void _navigateToPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(movie: widget.movie),
      ),
    );
  }

  Future<void> _toggleMyList(bool isCurrentlySaved) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    bool success = false;
    if (isCurrentlySaved) {
      success = await _myListService.removeFromMyList(widget.movie.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from My List'),
            duration: Duration(seconds: 2),
            backgroundColor: AppTheme.surfaceColor,
          ),
        );
      }
    } else {
      success = await _myListService.addToMyList(widget.movie);
      if (mounted && success) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to My List'),
            duration: Duration(seconds: 2),
            backgroundColor: AppTheme.surfaceColor,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 750;
    final double backdropHeight = isMobile ? 300.0 : 420.0;
    final String formattedDuration = _formatDuration(widget.movie.duration);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Backdrop Header Section
              Stack(
                children: [
                  // Backdrop Image
                  SizedBox(
                    width: double.infinity,
                    height: backdropHeight,
                    child: Image.network(
                      widget.movie.backdropUrl.isNotEmpty
                          ? widget.movie.backdropUrl
                          : widget.movie.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.surfaceColor,
                          child: const Center(
                            child: CineflixLogo(fontSize: 32),
                          ),
                        );
                      },
                    ),
                  ),

                  // Dark Gradients
                  Container(
                    width: double.infinity,
                    height: backdropHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          AppTheme.backgroundColor.withValues(alpha: 0.8),
                          AppTheme.backgroundColor,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),

                  // Top Back Button & Logo Header
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          tooltip: 'Back',
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        const CineflixLogo(fontSize: 22),
                      ],
                    ),
                  ),
                ],
              ),

              // Content Details Body Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 48,
                  vertical: 16,
                ),
                child: isMobile
                    ? _buildMobileLayout(context, formattedDuration)
                    : _buildDesktopLayout(context, formattedDuration),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, String formattedDuration) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster Card on Left
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 220,
            height: 330,
            color: AppTheme.cardColor,
            child: Image.network(
              widget.movie.posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPosterPlaceholder(),
            ),
          ),
        ),
        const SizedBox(width: 36),

        // Metadata & Actions on Right
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.movie.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                widget.movie.title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),

              // Year, Genre, Duration Meta Row
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    '${widget.movie.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.textMuted),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.movie.genre,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (formattedDuration.isNotEmpty)
                    Text(
                      formattedDuration,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                widget.movie.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Buttons (Play & Add to My List)
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  // Play Button (Primary)
                  ElevatedButton.icon(
                    onPressed: () => _navigateToPlayer(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 24),
                    label: const Text(
                      'Play Movie',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Interactive My List Button
                  _buildMyListButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, String formattedDuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.movie.category.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          widget.movie.title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Meta Info
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(
              '${widget.movie.year}',
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
                widget.movie.genre,
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
        const SizedBox(height: 18),

        // Buttons Stacked/Wrapped
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToPlayer(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text(
              'Play Movie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildMyListButton(),
        ),
        const SizedBox(height: 24),

        // Description
        const Text(
          'Overview',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.movie.description,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMyListButton() {
    return StreamBuilder<bool>(
      stream: _myListService.watchIsInMyList(widget.movie.id),
      builder: (context, snapshot) {
        final bool isSaved = snapshot.data ?? false;

        if (_isProcessing) {
          return OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: () => _toggleMyList(isSaved),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSaved
                ? AppTheme.surfaceColor
                : Colors.white.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: BorderSide(
              color: isSaved ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.25),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: Icon(
            isSaved ? Icons.check : Icons.add,
            color: Colors.white,
            size: 22,
          ),
          label: Text(
            isSaved ? '✓ My List' : '+ Add to My List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: isSaved ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CineflixLogo(fontSize: 20),
          const SizedBox(height: 12),
          const Icon(Icons.movie, color: AppTheme.textMuted, size: 40),
          const SizedBox(height: 12),
          Text(
            widget.movie.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
