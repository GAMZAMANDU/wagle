import 'package:flutter/material.dart';
import 'package:my_flutter_app/pages/home.dart';
import 'package:my_flutter_app/pages/initial.dart';
import 'package:my_flutter_app/pages/call.dart';
import 'package:my_flutter_app/pages/sign_up_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 1. 테마 설정
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Color(0xFFC3913A),
            foregroundColor: Colors.white, // 텍스트 색상을 지정하는 속성
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize: Size(400, 60),
          ),
        ),
      ),
      initialRoute: "/initial",
      routes: {
        "/initial": (context) => Initial(), // 초기 화면 설정
        "/login": (context) => LoginPage(),
        "/home": (context) => HomePage(),
        "/signup": (context) => SignUpPage(),
      },
    );
  }
}