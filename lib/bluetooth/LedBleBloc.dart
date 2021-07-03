import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

class LedBleBloc {
  BluetoothDevice? device;
  BluetoothCharacteristic? custom_characteristic;
  LedBleBloc({
    required this.device,
    required this.custom_characteristic
  });

  List<int> sendLedColor(HSVColor hsvColor) {
    List<int> msg = utf8.encode(toText(_to255Scale(hsvColor.hue), _to255Scale(hsvColor.saturation), int, _to255Scale(hsvColor.value)));
    custom_characteristic!.write(msg);
    return msg;
    //custom_characteristic!.write([_to255Scale(hsvColor.hue), _to255Scale(hsvColor.saturation), _to255Scale(hsvColor.value), -1]);
  } //sendLedColor

 int _to255Scale(double f) {
    return (f * 255).round();
 }

 String toText(int h, int s, int, v) {
    return h.toString() + " " + s.toString() + " " + v.toString() + "\n";
 }

} // LedBleBloc