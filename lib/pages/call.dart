import 'package:flutter/material.dart';
import 'package:my_flutter_app/components/custom_form.dart';
import 'package:my_flutter_app/components/logo.dart';
import 'package:my_flutter_app/size.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/place/cafe.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SizedBox(height: xlargeGap),
              Logo("Login"),
              SizedBox(height: largeGap),
              CustomForm(),
              SizedBox(height: largeGap),
              SizedBox(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/signup");
                  },
                  child: Text("Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
