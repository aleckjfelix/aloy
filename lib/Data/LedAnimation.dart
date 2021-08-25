
import 'package:aloy/bluetooth/LedBleBloc2.dart';

class LedAnimation {
  var hue_coords = <Coord>[];
  var sat_coords = <Coord>[];
  var val_coords = <Coord>[];

  String animationName = "";

  LedAnimation(String name){
    animationName = name;
  }

  static LedAnimation empty() {
    return LedAnimation("No Animation");
  }

  void run(LedBleBloc2 bleBloc) async{
    DateTime time1 = DateTime.now();
    DateTime time2;

  }

} // Animation

class Coord {
  final double x;
  final int y;
  Coord(this.x, this.y);
} // SalesData