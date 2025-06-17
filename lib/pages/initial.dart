import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Initial extends StatelessWidget {
  const Initial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFC3913A), // 배경색 설정
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 86),
          child: Center(
            child: SvgPicture.asset(
              'lib/assets/Wagle.svg',
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
