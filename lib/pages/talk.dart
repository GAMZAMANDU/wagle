import 'package:flutter/material.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({Key? super.key});

  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/place/cafe2.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 텍스트 위치 설정
          const Positioned(
            top: 44,
            left: 32,
            right: 32,
            child: Text(
              "Hello, How are you?",
              style: TextStyle(
                color: Colors.white,
                height: 1.8,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
