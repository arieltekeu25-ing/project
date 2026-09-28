import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget réutilisable pour lire une vidéo Cloudinary en streaming via secure_url
class CloudinaryVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final double aspectRatio;

  const CloudinaryVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<CloudinaryVideoPlayerWidget> createState() => _CloudinaryVideoPlayerWidgetState();
}

class _CloudinaryVideoPlayerWidgetState extends State<CloudinaryVideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });

    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller.initialize();

      if (widget.autoPlay) {
        await _controller.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Impossible de charger la vidéo';
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Erreur vidéo',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _initializePlayer,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1E88E5)),
              SizedBox(height: 12),
              Text(
                'Chargement de la vidéo Cloudinary...',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio > 0
            ? _controller.value.aspectRatio
            : widget.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            GestureDetector(
              onTap: _togglePlayPause,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: _controller.value.isPlaying
                    ? Colors.transparent
                    : Colors.black38,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, VideoPlayerValue value, child) {
                    return Text(
                      '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
