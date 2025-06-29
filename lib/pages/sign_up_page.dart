import 'package:flutter/material.dart';
import 'package:my_flutter_app/components/custom_form.dart';
import 'package:my_flutter_app/components/logo.dart';
import 'package:my_flutter_app/size.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: xlargeGap),
            Logo("Sign Up"),
            SizedBox(height: largeGap), // 1. 추가
            CustomForm(buttonText: "Sign Up"), // 2. 추가
          ],
        ),
      ),
    );
  }
}
