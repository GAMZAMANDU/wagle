import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  _initVideo() async {
    try {
      // 로컬 파일 먼저 시도
      _controller = VideoPlayerController.asset('assets/moive/Mike.mp4');
      await _controller!.initialize();
    } catch (e) {
      // 실패하면 네트워크 URL 시도
      try {
        _controller?.dispose();
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
          ),
        );
        await _controller!.initialize();
      } catch (e2) {
        setState(() {
          _error = '영상을 불러올 수 없습니다';
          _isLoading = false;
        });
        return;
      }
    }

    if (mounted) {
      _controller!.setLooping(true);
      _controller!.play();
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello, Lee\nCan I talk to you for a second?",
                style: TextStyle(
                  color: Color(0xFFB36843),
                  fontSize: 20,
                  fontFamily: 'Zodiak',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 321 / 440,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.black,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _buildVideo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_error != null) {
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
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _initVideo();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 10),
            Text('로딩 중...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    // 비디오를 컨테이너에 꽉 채우기
    return FittedBox(
      fit: BoxFit.cover, // 컨테이너를 완전히 채우되 비율 유지
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
