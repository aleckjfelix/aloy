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

  void sendLedColor(HSVColor hsvColor) {
    custom_characteristic!.write([_to255Scale(hsvColor.hue), _to255Scale(hsvColor.saturation), _to255Scale(hsvColor.value)]);
  } //sendLedColor

 int _to255Scale(double f) {
    return (f * 255).round();
 }

} // LedBleBloc