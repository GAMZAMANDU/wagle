import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  final String title;

  const Logo(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset("assets/Wagle.svg", height: 70, width: 70),
        Text(
          title,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
