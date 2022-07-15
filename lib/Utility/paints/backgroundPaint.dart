import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();
    var paintColor = Colors.blue.shade50;
    paint.color = paintColor;

    Path ovalPath = Path();
    ovalPath.moveTo(0, height * 0.3);
    ovalPath.lineTo(width * 0.3, height * 0.44);
    ovalPath.lineTo(width * 0.2, height * 0.63);
    ovalPath.lineTo(0, height * 0.65);
    ovalPath.close();
    canvas.drawPath(ovalPath, paint);

    Path path2 = Path();
    path2.moveTo(0, height * 0.75);
    path2.lineTo(width * 0.7, height);
    path2.lineTo(0, height);
    path2.close();
    canvas.drawPath(path2, paint);

    Path path3 = Path();
    path3.moveTo(width, height * 0.4);
    path3.lineTo(width * 0.55, height * 0.72);
    path3.lineTo(width * 0.7, height);
    path3.lineTo(width, height);
    path3.close();
    canvas.drawPath(path3, paint);

    // Path path4 = Path();
    // path4.moveTo(0, 0);
    // path4.lineTo(width, 0);
    // path4.lineTo(width, height * 0.15);
    // path4.lineTo(width * 0.2, height * 0.15);
    // path4.lineTo(0, height * 0.25);
    // path4.close();
    // canvas.drawPath(path4, paint);

    // Path path5 = Path();
    // path5.moveTo(width, 0);
    // path5.lineTo(0, height * 0.2);
    // path5.lineTo(0, 0);
    // path5.close();
    // canvas.drawPath(path5, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}