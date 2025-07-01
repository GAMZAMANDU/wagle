import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_flutter_app/pages/home.dart';
import 'package:my_flutter_app/pages/initial.dart';
import 'package:my_flutter_app/pages/talk.dart';

Future<void> main() async {
  try {
    print('🚀 Starting app initialization...');
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded successfully');
    print('📋 Available environment variables:');
    dotenv.env.forEach((key, value) {
      print(
        '   - $key: ${value.length > 10 ? "${value.substring(0, 10)}..." : value}',
      );
    });
  } catch (e) {
    print('❌ Failed to load .env file: $e');
  }
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
