import 'package:flutter/material.dart';
import 'dart:math';

/*
* author: Alec KJ Felix
* ArcedSliderBasePainter.dart
* Draw the base Arc of the Arced Slider
* Date Created: 12/27/2020
 */
class ArcedSliderSliderPainter extends CustomPainter {
  Color selectionColor; //color of the slider
  Offset center; // center of widget
  Offset handle; // position of the slider handle
  Offset startPos; // the starting position of handle on the arc
  double startAngle; // starting angle of arc
  double sweepAngle; // Angle to sweep Arc

  /*
   * Constructor
   */
  ArcedSliderSliderPainter(
    {@required this.startPos,
    @required this.selectionColor,
    @required this.startPos,
    @required this.startAngle,
    @required this.sweepAngle});


  @override
  void paint(Canvas canvas, Size size) {

    Paint sliderBar = _getPaint(color: selectionColor);
    Paint handle = _getPaint(color: selectionColor, style: PaintingStyle.fill);

    center = Offset(size.width / 2, size.height / 2);

    Rect widgetRect = Rect.fromCenter(center: center, width: size.width / 2, height: size.height / 2);

    // draw sliderBar
    canvas.drawArc(widgetRect, startAngle, sweepAngle, false, sliderBar);

    //draw Handle
    double radius = 10;
    //handle = _radiansToCoordinates(center, startAngle, radius);


  }// paint

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }// shouldRepaint

  /*
  * _getPaint
  * Creates a paint obj with default vals
   */
  Paint _getPaint({@required Color color, double width, PaintingStyle style}) {
    return Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = style ?? PaintingStyle.stroke
      ..strokeWidth = width ?? 12.0;
  }// getPaint

  double coordinatesToRadians(Offset center, Offset coords) {
    var a = coords.dx - center.dx;
    var b = center.dy - coords.dy;
    return atan2(b, a);
  }

  Offset radiansToCoordinates(Offset center, double radians, double radius) {
    var dx = center.dx + radius * cos(radians);
    var dy = center.dy + radius * sin(radians);
    return Offset(dx, dy);
  }


}// ArcedSliderSliderPainter