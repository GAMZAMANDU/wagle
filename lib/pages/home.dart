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
    // 로컬 비디오 먼저 시도
    try {
      print('시도 중: assets/movie/Mike.mp4');
      _controller = VideoPlayerController.asset('assets/movie/Mike.mp4');

      // 상태 변화 리스너 추가
      _controller!.addListener(() {
        if (mounted) {
          print(
            '비디오 상태 변화: 재생중=${_controller!.value.isPlaying}, 위치=${_controller!.value.position}, 에러=${_controller!.value.hasError}',
          );
          setState(() {}); // UI 업데이트
        }
      });

      await _controller!.initialize();
      print('로컬 비디오 성공: assets/movie/Mike.mp4');
    } catch (e) {
      print('로컬 비디오 실패: $e');
      // 로컬 실패하면 네트워크 비디오로 fallback
      try {
        _controller?.dispose();
        print('네트워크 URL 시도 중...');
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          ),
        );

        // 상태 변화 리스너 추가
        _controller!.addListener(() {
          if (mounted) {
            print(
              '비디오 상태 변화: 재생중=${_controller!.value.isPlaying}, 위치=${_controller!.value.position}, 에러=${_controller!.value.hasError}',
            );
            setState(() {}); // UI 업데이트
          }
        });

        await _controller!.initialize();
        print('네트워크 URL 성공');
      } catch (e2) {
        setState(() {
          _error = '영상을 불러올 수 없습니다';
          _isLoading = false;
        });
        return;
      }
    }

    if (mounted) {
      print('비디오 정보: ${_controller!.value.size}');
      print('비디오 지속시간: ${_controller!.value.duration}');
      print('비디오 상태: ${_controller!.value.isInitialized}');

      await _controller!.setLooping(true);
      print('루핑 설정 완료');

      // 웹에서는 사용자 상호작용 없이 자동재생 불가능
      // 따라서 자동재생을 시도하지 않고 사용자가 클릭할 때까지 대기
      print('비디오 준비 완료 - 사용자 클릭을 기다립니다');

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

    // 비디오 상태 디버깅
    print('_buildVideo 호출됨');
    print('_controller null인가? ${_controller == null}');
    if (_controller != null) {
      print('초기화됨? ${_controller!.value.isInitialized}');
      print('재생 중? ${_controller!.value.isPlaying}');
      print('에러? ${_controller!.value.hasError}');
      if (_controller!.value.hasError) {
        print('비디오 에러: ${_controller!.value.errorDescription}');
      }
    }

    // 비디오 위에 텍스트 오버레이
    return GestureDetector(
      onTap: () {
        // 사용자가 탭하면 재생/일시정지 토글
        if (_controller != null && _controller!.value.isInitialized) {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        }
      },
      child: Stack(
        children: [
          // 비디오 배경
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
                      child: Center(
                        child: Text(
                          '비디오 준비 중...\n컨트롤러: ${_controller != null}\n초기화: ${_controller?.value.isInitialized ?? false}',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
          ),
          // 재생 버튼 오버레이 (사용자 상호작용이 필요할 때만 표시)
          if (_controller != null &&
              _controller!.value.isInitialized &&
              (_controller!.value.hasError || !_controller!.value.isPlaying))
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          // 텍스트 오버레이 - 비디오 위에 표시
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mike. Age 24',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Zodiak',
                    fontWeight: FontWeight.bold,
                    // shadows: [
                    //   Shadow(
                    //     offset: Offset(1, 1),
                    //     blurRadius: 3,
                    //     color: Colors.black54,
                    //   ),
                    // ],
                  ),
                ),
                const Text(
                  'Mike는 재치있는 말로 분위기를 사로잡는\n시카고의 예술가입니다.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    // shadows: [
                    //   Shadow(
                    //     offset: Offset(1, 1),
                    //     blurRadius: 3,
                    //     color: Colors.black54,
                    //   ),
                    // ],
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
