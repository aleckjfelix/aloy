/*
* author: Alec KJ Felix
* Date Created: 12/30/2020
* Draws the Circular Ring for the Color Wheel which does NOT
* need to be updated due to user interaction
* - large Circular Slider ring:
*   -> active: has a color gradient
*   -> de-active: black/grayscale
* Easier to represent colors graphically using HSV
* Ring will only represnt the Hue values
* S and V values can be changed by clicking inside the wheel which will bring up a 2D
* landscape where y-axis is v (value) and x-axis is s (saturation)
 */
import 'dart:math';

import 'package:flutter/material.dart';

class ColorWheelBase extends CustomPainter {

  //  -- ColorWheelBase Config Variables --
  final HSVColor hsvColor; // the hsvColor value to create obj
  final Color deactiveColor;
  final double padding;
  final double innerStrokeWidth;
  final double outerCircleStroke;
  final bool isActive; // whether the ColorWheelSlider is in it's active state
  final Color innerColor;
  final bool showInnerColor; // whether to use innerColor

  // -- internal variables --
  Offset _center = Offset(187.5,187.5); // center of this Painter's drawable space
  Rect _boundingRect = Rect.fromCenter(center: Offset(187.5,187.5), width: 375, height: 375); // rect representing CustomPainters drawable area
  double? _radius; // radius for the Circular base ring
  double? _innerRadius;

  static final List<Color> _wheelDistinctColors = [
  const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor()
  ];//list of the distinct colors made from Hue values

  static final Gradient _colorGradient = SweepGradient(startAngle: 0.0,
      endAngle: pi * 2,
      colors: _wheelDistinctColors); // create Circular Gradient between the distinct colors

  static Paint _gradientPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..strokeWidth = 18.0
    ..shader = _colorGradient.createShader(Rect.fromCenter(center: Offset(187.5,187.5), width: 375, height: 375));

  static Paint _borderColor =  Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..strokeWidth = 21.0
    ..color = Colors.black
    ..isAntiAlias = true;

  static Paint _innerColor = Paint()
    ..style = PaintingStyle.fill;
  //canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

  ColorWheelBase({
    @required this.deactiveColor= Colors.grey,
    @required this.hsvColor= const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0),
    @required this.isActive=true,
    @required this.padding=8.0,
    @required this.innerStrokeWidth=18.0,
    @required this.outerCircleStroke=21.0,
    innerColor,
    @required this.showInnerColor = false
  }) : this.innerColor = innerColor ?? Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    _center = Offset(size.width / 2, size.height / 2);
    _radius = (min(size.width, size.height) - outerCircleStroke) / 2 - padding;
    _boundingRect = Rect.fromCenter(center: _center, width: size.width, height: size.height);
    _innerRadius = _radius! - innerStrokeWidth/2;

    // draw shadow
    Path shadowPath = Path();
    shadowPath.addOval(Rect.fromCircle(center: _center, radius: _radius! + padding));
    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(1.0)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(shadowPath, shadowPaint);
    if(isActive) {
      _gradientPaint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStrokeWidth
        ..shader = _colorGradient.createShader(_boundingRect);

      _borderColor = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerCircleStroke
        ..color = Colors.black
        ..isAntiAlias = true;

        _innerColor = Paint()
          ..style = PaintingStyle.fill;

         if(showInnerColor)
          _innerColor.color = innerColor;
         else
           _innerColor.color = hsvColor.toColor();
        canvas.drawCircle(_center, _innerRadius!, _innerColor);

      canvas.drawCircle(_center, _radius!, _borderColor);
      canvas.drawCircle(_center, _radius!, _gradientPaint); // gradien
      //draw inner
    } else{
      canvas.drawCircle(_center, _radius!, _borderColor);
      canvas.drawCircle(_center, _radius!,
          Paint()
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke
            ..strokeWidth = innerStrokeWidth
            ..color = deactiveColor
            ..isAntiAlias = true);
      }
  } // paint

  @override
  bool shouldRepaint(ColorWheelBase oldDelegate) {
    // repaint ONLY when switching from Active->deactive or vice versa
    if (oldDelegate.isActive != isActive || oldDelegate.hsvColor.toColor() != hsvColor.toColor())
      return true;
    return false;
  } // shouldRepaint


} // ColorWheelBase