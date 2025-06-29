import 'package:flutter/material.dart';
import '../components/video_with_overlay.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    ),
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
                    child: VideoWithOverlay(
                      name: "Mike",
                      age: "24",
                      description: "Mike는 재치있는 말로 분위기를 사로잡는\n시카고의 예술가입니다.",
                      videoAssetPath: 'assets/movie/Mike.mp4',
                      fallbackVideoUrl:
                          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 화살표 버튼
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // 버튼 클릭 액션
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB36843),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
