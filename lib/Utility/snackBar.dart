import 'package:flutter/material.dart';


void notify(context, msg){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,),
  );
}
