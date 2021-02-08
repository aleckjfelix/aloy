

import 'dart:math';
import 'dart:ui';

class MathUtils {
  static final double twoPI = 2 * pi;
  /*
   * angle is in radians
   * Returns the Coordinates along circle given radius and center with given angle
   * Uses _center and _radius to calculate the Offset(x,y) to draw
   * the handle at.
   * Given that the circle is of thickness 20.0
   */
  static Offset angleToCoordinates(double radius, Offset center, double angle){
    return Offset(center.dx + radius * cos(angle), center.dy - radius * sin(angle));
  } // angleToCoordinates

  /*
   * Return angle with the +x-axis in radians
   */
  static double coordinatesToAngle(Offset coords, Offset origin){
    double a = atan2(origin.dy - coords.dy,coords.dx - origin.dx);

    if(a < 0.0){
      return twoPI + a;
    }

    return a;
  } // coordinatesToAngle

  /*
   * Converts coords in Canvas space to any other coordinate space
   * Given the coords of the origin within Canvas space
   */
  static Offset otherCoordsToCanvasCoords(Offset otherCoords, Offset otherOrigin){
    return Offset(otherCoords.dx + otherOrigin.dx, otherOrigin.dy - otherCoords.dy );
  } // CanvasCoordinatesToOtherCoordinates

  static Offset canvasCoordsToOtherCoords(Offset canvasCoords, Offset otherOrigin){
    return Offset(canvasCoords.dx - otherOrigin.dx, -(canvasCoords.dy - otherOrigin.dy));
  } // canvasCoordsToOtherCoords

  static bool isPointerWithinCircle(Offset pointer, Offset circleCenter, double circleRadius){
    //print("pointer: " + pointer.toString() + " | circleCenter: " + circleCenter.toString() + " | circleRadius: " + circleRadius.toString());
    return sqrt(pow(pointer.dx - circleCenter.dx,2) + pow(pointer.dy-circleCenter.dy,2)) <= circleRadius;
  } // isPointerWithinCircle

  static bool isPointerWithinSquare(Offset pointer, Offset squareCenter, double width){
    width /= 2;
    return !(pointer.dx > (squareCenter.dx + width)
        || pointer.dx < (squareCenter.dx - width)
        || pointer.dy > (squareCenter.dy + width)
        || pointer.dy < (squareCenter.dy - width));
  } // isPointerWithinSquare

  static bool isXCoordWithinSquare(Offset pointer, Offset squareCenter, double width){
    width /= 2;
    return !(pointer.dx > (squareCenter.dx + width)
        || pointer.dx < (squareCenter.dx - width));
  } // isXCoorWithinSquare

  static bool isYCoordWithinSquare(Offset pointer, Offset squareCenter, double width){
    width /= 2;
    return !(pointer.dy > (squareCenter.dy + width)
        || pointer.dy < (squareCenter.dy - width));
  } // isYCoordWithinSquare

} // MathUtils