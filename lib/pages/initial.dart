import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  _InitialState createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  @override
  void initState() {
    super.initState();
    // 2초 후에 home으로 이동
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB36843), // Scaffold 배경색 설정
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 86),
        child: Center(
          child: SvgPicture.asset(
            'lib/assets/Wagle.svg',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
