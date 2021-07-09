

/*
 * main method
 */
import 'package:aloy/screens/HomeScreen.dart';
import 'package:flutter/material.dart';

import 'bluetooth/LedBleBloc.dart';

void main() {
  runApp(MyApp());
}//main method

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen(ledBleBloc: LedBleBloc.empty()));
  }//build

}//MyApp