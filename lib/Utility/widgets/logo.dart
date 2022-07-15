import 'package:flutter/material.dart';

import '../environment.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding + 25,
          vertical: 30.0
      ),
      child: Image.asset(
        "images/original logo.png",
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
