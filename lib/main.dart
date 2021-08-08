

/*
 * main method
 */
// @dart=2.9
import 'package:aloy/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'bluetooth/LedBleBloc2.dart';

void main() {
  runApp(MyApp());
}//main method

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen(ledBleBloc: LedBleBloc2.empty()));
  }//build

}//MyApp