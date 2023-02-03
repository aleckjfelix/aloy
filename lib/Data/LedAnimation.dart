
import 'dart:async';

import 'package:aloy/bluetooth/LedBleBloc2.dart';
import 'package:flutter/cupertino.dart';

class LedAnimation {
  var hue_coords;
  var sat_coords;
  var val_coords;
  var deltaTime = 20;
  String animationName = "";

  LedAnimation(String name){
    animationName = name;
    hue_coords = <Coord>[];
    sat_coords = <Coord>[];
    val_coords = <Coord>[];
  }

  LedAnimation.fillHoles(int numPoints, LedAnimation oldAnimation) {
    animationName = oldAnimation.animationName;
    hue_coords = oldAnimation.hue_coords;
    sat_coords = oldAnimation.sat_coords;
    val_coords = oldAnimation.val_coords;
    fillHolesInList(numPoints, oldAnimation);
  }

  static LedAnimation empty() {
    return LedAnimation("No Animation");
  }



  void run(LedBleBloc2 bleBloc) async{
    print(hue_coords.toString());
    return;
    Duration delta = Duration(milliseconds: deltaTime);
    int index = 0;

    Timer.periodic(delta, (Timer t){
      bleBloc.sendLedColor(HSVColor.fromAHSV(1.0, hue_coords[index].y, sat_coords[index].y, val_coords[index].y));
    });

  } // run

  /*
   * interpolate between points so there is a coordinate every 20ms
   */
  void fillHolesInList(int numPoints, LedAnimation oldAnimation) {
   // fillBetweenTwoPoints(null, Coord hue_coords)
    print(hue_coords);
  } // fillHolesInList
} // Animation

class Coord {
  final double x;
  final double y;
  Coord(this.x, this.y);

  @override
  String toString() {
    return "(" + x.toString() + "," + y.toString() + ")";
  }
} // SalesData