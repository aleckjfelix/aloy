/*
* author: Alec KJ Felix
* ArcedSliderBasePainter.dart
* Draw the base Arc of the Arced Slider
* Date Created: 12/24/2020
 */
import 'dart:math';

import 'package:flutter/material.dart';

class ArcedSliderBasePainter extends CustomPainter {
  Color baseColor; // base color of slider
  Offset center; // center of widget space
  double startAngle; // starting angle of arc
  double sweepAngle; // Angle to sweep Arc


  ArcedSliderBasePainter({@required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
        paint.color = baseColor;
        paint.strokeCap = StrokeCap.round;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 12.0;

    center = Offset(size.width / 2, size.height /2 );
    Rect widgetRect = Rect.fromCenter(center: center, width: size.width , height: size.height);

    //canvas.drawArc(widgetRect, startAngle, sweepAngle, false, paint);
    canvas.drawRect(widgetRect, paint);

  }//paint

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }// shouldRepaint


}//SliderBasePainter

