import 'package:flutter/material.dart';
import '../components/video_with_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  // 다양한 사용자 데이터
  final List<Map<String, String>> users = [
    {
      'name': 'Mike',
      'age': '24',
      'description': 'Mike는 재치있는 말로 분위기를 사로잡는\n시카고의 예술가입니다.',
      'videoPath': 'assets/movie/Mike.mp4',
    },
    {
      'name': 'Sophia',
      'age': '28',
      'description': 'Sophia는 사회문제에 관심이 많은\nCNN의 기자입니다.',
      'videoPath': 'assets/movie/Sophia.mp4',
    },
    {
      'name': 'Jason',
      'age': '14',
      'description': 'James는 League of Legends와 FPS를\n즐기는 활발한 게이머입니다.',
      'videoPath': 'assets/movie/Jason.mp4',
    },
  ];

  void _nextUser() {
    setState(() {
      currentIndex = (currentIndex + 1) % users.length;
    });
  }

  void _previousUser() {
    setState(() {
      currentIndex = (currentIndex - 1 + users.length) % users.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = users[currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  child: const Text(
                    "Hello, Lee\nCan I talk to you for a second?",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xFFB36843),
                      fontSize: 20,
                      fontFamily: 'Zodiak',
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 스와이프 감지가 가능한 Container
                GestureDetector(
                  onPanUpdate: (details) {
                    // 오른쪽으로 스와이프 (dx > 0)
                    if (details.delta.dx > 10) {
                      _previousUser();
                    }
                    // 왼쪽으로 스와이프 (dx < 0)
                    else if (details.delta.dx < -10) {
                      _nextUser();
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 321 / 440,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.black,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: VideoWithOverlay(
                        key: ValueKey(currentIndex), // 리빌드를 위한 키
                        name: currentUser['name']!,
                        age: currentUser['age']!,
                        description: currentUser['description']!,
                        videoAssetPath: currentUser['videoPath']!,
                        fallbackVideoUrl:
                            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 화살표 버튼
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/talk');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB36843),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // 현재 사용자 인덱스 표시 (디버깅용)
                const SizedBox(height: 10),
                Text(
                  '${currentIndex + 1} / ${users.length}',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
