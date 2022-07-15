import 'package:flutter/material.dart';

import '../colors.dart';
import '../environment.dart';


class TextFormFieldGen extends StatelessWidget {
  final String labelText;
  final String prefixText;
  final TextEditingController? controller;
  final Icon icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final onTap;
  final validator;
  final onChanged;

  TextFormFieldGen(
      {
        Key? key,
        required this.labelText,
        this.prefixText = '',
        this.controller,
        required this.icon,
        this.keyboardType = TextInputType.text,
        this.obscureText = false,
        this.onTap,
        this.validator,
        this.onChanged,
      }
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onTap: onTap,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          enabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: genUnselectedColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: genPrimaryColor, width: 4.0),
          ),
          prefixIcon: icon,
          prefixText: prefixText,
          labelText: labelText,
          labelStyle: TextStyle(color: genUnselectedColor),
        ),
      ),
    );
  }
}
