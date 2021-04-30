/*
* author: Alec KJ Felix
* Date Created: 1/31/2021
* ColorWheelSelector.dart
* Draws the slider which the user can drag around the circle
* to manipulate the Hue value
* When the slider is moved it should change the color within the center of
* the Color wheel to the currently selected color
* - Handle
* -> When Active: Draw circular or other shaped handle
* -> When deactive: Don't draw the handle
*
* TODO Move ColorWheelSlider into ColorWheelBase and make into a single
* CustomPainter. Since ColorWheelBase needs to redraw when the slider is moved
* anyway
* TODO get a general equation to shift the error so the knob can look good at
*  any size
 */
import 'dart:math';
import 'package:aloy/widgets/utility/MathUtils.dart';
import 'package:flutter/material.dart';

class ColorWheelSelector extends CustomPainter {
  // config variables
  final Color handleColor;
  final double handleAngle; // starting angle of handle (radians)
  final double handleStokeWidth;
  final double outerStrokeWidth;
  final double padding;
  final double innerStrokeWidth; // for the ColorWheelBase
  final bool isActive;
  final bool showSVSelector;
  final HSVColor hsvColor;
  final Offset svHandlePos;
  // -- internal
  // variables --
  Offset _center = Offset(187.5,187.5); // center of this Painter's drawable space
  Rect _boundingRect = Rect.fromCenter(center: Offset(187.5,187.5), width: 375, height: 375); // rect representing CustomPainters drawable area
  double? _radius; // radius of the ColorWheelBase (to center of ring)
  Offset? handleCenter; // Offset to the center of where handle should be drawn
  double? _svSelectorWidth;
  Offset? svOrigin;
  ColorWheelSelector({
      @required this.handleColor = Colors.white,
      @required this.handleAngle = 0.0,
      @required this.isActive = true,
      @required this.handleStokeWidth = 2.0,
      @required this.outerStrokeWidth = 21.0,
      @required this.padding = 8.0,
      @required this.innerStrokeWidth = 18.0,
      @required this.showSVSelector = false,
      @required this.hsvColor = const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0),
      @required this.svHandlePos = const Offset(0.0,0.0)
      }); // radius for the Circular base ring

  @override
  void paint(Canvas canvas, Size size) {
    if(!isActive)
      return;

    _center = Offset(size.width / 2, size.height / 2);
    _radius = (min(size.width, size.height) - outerStrokeWidth) / 2 - padding; // radius to center of Circular Ring

    final Paint handleOuter = Paint()
      ..color = handleColor
      .. strokeCap = StrokeCap.round
      .. style = PaintingStyle.stroke
      ..strokeWidth = handleStokeWidth; // outer ringed circle

    final Paint handleInner = Paint()
      ..color = handleColor
      .. strokeCap = StrokeCap.round
      .. style = PaintingStyle.fill;
      //..strokeWidth = 12.0; // outer ringed circle

    // get the coordinates of handle
    handleCenter = MathUtils.angleToCoordinates(_radius!, _center, handleAngle);
    // calc radius of the handle's outer circle
    double outerRadius = outerStrokeWidth/2 + 2;

    if(showSVSelector){
      // Calc width of maximum square within circle
      _svSelectorWidth = 2 * (_radius! - outerStrokeWidth/2) / sqrt2;

      // calculate rounded rectangle for SV Selector
      Rect svRect = Rect.fromCenter(center: _center, width: _svSelectorWidth!, height: _svSelectorWidth!);
      RRect svRRect = RRect.fromRectAndRadius(
          svRect,
          Radius.circular(15.0));

      // draw shadow around RRect
      Path svPath = Path();
      svPath.addRRect(svRRect);

      canvas.drawShadow(svPath, Colors.grey[900]!, 2.0, true);

      final Gradient gradientV = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.black],
      );
      final Gradient gradientS = LinearGradient(
        colors: [
          Colors.white,
          HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
        ],
      );

      canvas.drawRRect(
          svRRect,
          Paint()..shader = gradientV.createShader(svRect)
      ); // draw RRect
      canvas.drawRRect(
          svRRect,
          Paint()
            ..blendMode = BlendMode.multiply
            ..shader = gradientS.createShader(svRect)
      ); // draw overtop to create 2D gradient

      // draw SVHandle
      svOrigin = Offset(_center.dx - _svSelectorWidth! /2, _center.dy + _svSelectorWidth! /2);
     // print("svOrigin(CWS) :" + svOrigin.toString() + " svHandle: " + svHandlePos.toString());
      canvas.drawCircle(MathUtils.otherCoordsToCanvasCoords(svHandlePos, svOrigin!), outerRadius * 0.68, handleOuter);

    } // draw SV Selector is showSv
    canvas.drawCircle(handleCenter!, outerRadius * 0.68, handleInner);
    canvas.drawCircle(handleCenter!, outerRadius, handleOuter);
  } // paint

  @override
  bool shouldRepaint(ColorWheelSelector oldDelegate) {
    //if(oldDelegate.handleAngle != this.handleAngle || oldDelegate.svHandlePos != this.svHandlePos ||oldDelegate.showSVSelector != this.showSVSelector || oldDelegate.isActive != this.isActive)
      return true;
    //return false;
  } // shouldRepaint



  
} // ColorWheelSlider