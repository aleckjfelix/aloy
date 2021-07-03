import 'dart:ui';

import 'package:flutter_blue/flutter_blue.dart';

class LedBleBloc {
  BluetoothDevice? device;
  BluetoothCharacteristic? custom_characteristic;
  LedBleBloc({
    required this.device,
    required this.custom_characteristic
  });

  void sendLedColor(Color rgbColor) {
    custom_characteristic!.write([rgbColor.red, rgbColor.blue, rgbColor.green]);
  } //sendLedColor

} // LedBleBloc