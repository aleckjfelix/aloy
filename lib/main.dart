import 'package:aloy/Data/LedAnimation.dart';
import 'package:aloy/screens/AnimatorScreen.dart';
import 'package:aloy/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'bluetooth/LedBleBloc2.dart';

/*
 * main method
 */
void main() {
  runApp(MyApp());
}//main method

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Aloy",
        theme: ThemeData(
          primaryColor: Colors.pink[100],
          accentColor: Colors.black
        ),
        home: HomeScreen(ledBleBloc: LedBleBloc2.empty(), currentAnimation: LedAnimation.empty(),),
//        routes: {
 //         "/AnimatorScreen": (_) => AnimatorScreen(ledBleBloc: ,)
 //       },
    );
  }//build

}//MyApp