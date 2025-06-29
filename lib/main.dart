import 'package:flutter/material.dart';
import 'package:my_flutter_app/pages/home.dart';
import 'package:my_flutter_app/pages/initial.dart';
import 'package:my_flutter_app/pages/talk.dart';

void main() {
  runApp(const MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        fontFamily: 'Pretendard Variable', // 기본 폰트
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Color(0xFFC3913A),
            foregroundColor: Colors.white,
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
        "/home": (context) => HomePage(),
        "/talk": (context) => TalkPage(),
      },
    );
  }
}
