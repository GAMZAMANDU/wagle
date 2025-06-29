import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

class VideoWithOverlay extends StatefulWidget {
  final String name;
  final String age;
  final String description;
  final String? videoAssetPath;
  final String? fallbackVideoUrl;

  const VideoWithOverlay({
    Key? key,
    required this.name,
    required this.age,
    required this.description,
    this.videoAssetPath = 'assets/movie/Mike.mp4',
    this.fallbackVideoUrl =
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  }) : super(key: key);

  @override
  VideoWithOverlayState createState() => VideoWithOverlayState();
}

class VideoWithOverlayState extends State<VideoWithOverlay> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.videoAssetPath != null) {
        await _loadVideo(widget.videoAssetPath!, isAsset: true);
      } else {
        throw Exception('No video asset path provided');
      }
    } catch (e) {
      print('Failed to load local video: $e');
      if (widget.fallbackVideoUrl != null) {
        try {
          await _loadVideo(widget.fallbackVideoUrl!, isAsset: false);
        } catch (e2) {
          print('Failed to load network video: $e2');
          _setError('Failed to load video');
        }
      } else {
        _setError('No video source available');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVideo(String videoSource, {required bool isAsset}) async {
    _controller?.dispose();
    _controller =
        isAsset
            ? VideoPlayerController.asset(videoSource)
            : VideoPlayerController.networkUrl(Uri.parse(videoSource));

    _controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    await _controller!.initialize();
    await _controller!.setLooping(true);

    if (!kIsWeb) {
      try {
        await _controller!.play();
      } catch (e) {
        print('Failed to autoplay: $e');
      }
    }
  }

  void _setError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    return _buildVideoWithOverlay();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.white, size: 50),
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _initVideo();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 10),
          Text('Loading...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildVideoWithOverlay() {
    return GestureDetector(
      onTap: () {
        if (_controller != null && _controller!.value.isInitialized) {
          _controller!.value.isPlaying
              ? _controller!.pause()
              : _controller!.play();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child:
                _controller != null && _controller!.value.isInitialized
                    ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                    : Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Text(
                          'Video is preparing...',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
          ),
          if (_controller != null &&
              _controller!.value.isInitialized &&
              !_controller!.value.isPlaying)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.name}. Age ${widget.age}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Zodiak',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
