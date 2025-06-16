import 'package:flutter/material.dart';
import 'package:my_flutter_app/components/custom_text_form_field.dart';
import 'package:my_flutter_app/size.dart';

class CustomForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // 1. 글로벌 key
  final String buttonText; // 추가: 버튼 텍스트

  CustomForm({Key? key, this.buttonText = "Login"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      // 2. 글로벌 key를 Form 태그에 연결하여 해당 key로 Form의 상태를 관리할 수 있다.
      key: _formKey,
      child: Column(
        children: [
          if (buttonText != "Login") ...[
            CustomTextFormField("Name"),
            SizedBox(height: mediumGap),
          ],
          CustomTextFormField("Email"),
          SizedBox(height: mediumGap),
          CustomTextFormField("Password"),
          SizedBox(height: largeGap),
          // 3. TextButton 추가
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // 4. 유효성 검사
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(context, "/home");
                }
              },
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
