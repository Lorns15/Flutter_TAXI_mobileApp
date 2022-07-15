import 'package:flutter/material.dart';

import '../colors.dart';

class ButtonSolid extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bgcolor;

  ButtonSolid({Key? key, required this.onPressed, required this.text, this.bgcolor=genPrimaryColor,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle( fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        primary: bgcolor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
      ),
    );
  }
}

class ButtonOutline extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bgcolor;

  ButtonOutline({Key? key, required this.onPressed, required this.text, this.bgcolor=genBackgroundColor, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle( fontWeight: FontWeight.bold),),
      style: OutlinedButton.styleFrom(
        primary: genPrimaryColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
        side: BorderSide(width: 3.0, color: genPrimaryColor),
        backgroundColor: bgcolor,
      ),
    );
  }
}