import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/movie.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cineflix_logo.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Movie movie;
  final VideoPlayerController? mockController; // For testing injection

  const VideoPlayerScreen({
    super.key,
    required this.movie,
    this.mockController,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitializing = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isPlaying = false;
  bool _isMuted = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    // Safely dispose any previous controller before re-initializing
    if (_controller != null) {
      _controller!.removeListener(_videoPlayerListener);
      await _controller!.dispose();
      _controller = null;
    }

    if (!mounted) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      if (widget.mockController != null) {
        _controller = widget.mockController;
      } else {
        final Uri videoUri = Uri.parse(widget.movie.videoUrl);
        debugPrint('[VideoPlayer] Initializing playback:');
        debugPrint('  ID: ${widget.movie.id}');
        debugPrint('  Title: ${widget.movie.title}');
        debugPrint('  URL: ${widget.movie.videoUrl}');
        _controller = VideoPlayerController.networkUrl(videoUri);
      }

      _controller!.addListener(_videoPlayerListener);
      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _duration = _controller!.value.duration;
      });

      await _controller!.play();
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[VideoPlayerError] Failed to initialize video player.');
      debugPrint('  Movie ID: ${widget.movie.id}');
      debugPrint('  Title: ${widget.movie.title}');
      debugPrint('  URL: ${widget.movie.videoUrl}');
      debugPrint('  Exception Type: ${e.runtimeType}');
      debugPrint('  Error Description: $e');
      debugPrint('  StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorMessage = 'Unable to play this video.';
      });
    }
  }

  void _videoPlayerListener() {
    if (_controller == null || !mounted) return;

    final value = _controller!.value;
    if (value.hasError) {
      debugPrint('[VideoPlayerError] Controller runtime playback error detected.');
      debugPrint('  Error Description: ${value.errorDescription}');
      debugPrint('  Video URL: ${widget.movie.videoUrl}');

      setState(() {
        _hasError = true;
        _errorMessage = 'Unable to play this video.';
      });
      return;
    }

    setState(() {
      _position = value.position;
      _duration = value.duration;
      _isPlaying = value.isPlaying;
    });
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
  }

  Future<void> _toggleMute() async {
    if (_controller == null) return;
    final newMuteState = !_isMuted;
    await _controller!.setVolume(newMuteState ? 0.0 : 1.0);
    if (mounted) {
      setState(() {
        _isMuted = newMuteState;
      });
    }
  }

  Future<void> _retryInitialization() async {
    if (_controller != null) {
      _controller!.removeListener(_videoPlayerListener);
      await _controller!.dispose();
      _controller = null;
    }
    if (!mounted) return;
    await _initializeVideoPlayer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_videoPlayerListener);
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Player / Loading / Error
            Center(
              child: _buildPlayerContent(),
            ),

            // Top Header Overlay (Back Button + Title)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.movie.genre} • ${widget.movie.year}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Player Control Bar (when initialized & active)
            if (_controller != null && _controller!.value.isInitialized && !_hasError)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bar Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: AppTheme.primaryRed,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: AppTheme.primaryRed,
                        ),
                        child: Slider(
                          value: _position.inMilliseconds.toDouble().clamp(
                                0.0,
                                _duration.inMilliseconds.toDouble() > 0
                                    ? _duration.inMilliseconds.toDouble()
                                    : 1.0,
                              ),
                          max: _duration.inMilliseconds.toDouble() > 0
                              ? _duration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (value) {
                            _controller?.seekTo(Duration(milliseconds: value.toInt()));
                          },
                        ),
                      ),
                      Row(
                        children: [
                          // Play/Pause Button
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          const SizedBox(width: 8),

                          // Volume Mute Button
                          IconButton(
                            icon: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _toggleMute,
                          ),
                          const SizedBox(width: 12),

                          // Duration Display
                          Text(
                            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_isInitializing) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CineflixLogo(fontSize: 36),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
          SizedBox(height: 16),
          Text(
            'Loading video stream...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      );
    }

    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 56),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Unable to play this video.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            children: [
              ElevatedButton.icon(
                onPressed: _retryInitialization,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          ),
        ],
      );
    }

    if (_controller != null && _controller!.value.isInitialized) {
      return GestureDetector(
        onTap: _togglePlayPause,
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
