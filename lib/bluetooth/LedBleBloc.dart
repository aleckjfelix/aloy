import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

class LedBleBloc {
  BluetoothDevice? device;
  BluetoothCharacteristic? customCharacteristic;
  String _status = "";

  LedBleBloc({
    required this.device,
    required this.customCharacteristic,
  }){
    if(this.device == null)
      _status = " Not Connected.";
    else if(this.customCharacteristic == null)
      if(this.device!.name.length <= 11)
        _status = this.device!.name + " Connected (no comms).";
      else
        _status = this.device!.name.substring(0,9) + ".. Connected.";
    else {
      if(this.device!.name.length <= 11)
        _status = this.device!.name + " Connected.";
      else
        _status = this.device!.name.substring(0,9) + ".. Connected.";
    }
  }

  void sendLedColor(HSVColor hsvColor) {
    if(device == null)
      return; //"No Device Connected";

    String text = toText(_three60To255Scale(hsvColor.hue), _oneTo255Scale(hsvColor.saturation), int, _oneTo255Scale(hsvColor.value));
    List<int> msg = utf8.encode(text);
    if(customCharacteristic != null){
     // List<int> msg = utf8.encode(toText(_to255Scale(hsvColor.hue), _to255Scale(hsvColor.saturation), int, _to255Scale(hsvColor.value)));
      customCharacteristic!.write(msg);
      //return "Color: [" + hsvColor.hue.toString() + ", " + hsvColor.saturation.toString() + ", " + hsvColor.value.toString() +"]\n" + "Color Scaled: [" + text + "]" + "\n" + "sent: [" + msg.toString() + "]";
    }

    return; //"Not an Hm-10 device";
  } //sendLedColor

 int _oneTo255Scale(double f) {
    return (f * 255).round();
 }
int _three60To255Scale(double f) {
    return (f * 0.70833333333).round();
}
 String toText(int h, int s, int, v) {
    return h.toString() + " " + s.toString() + " " + v.toString() + "\n";
 }

  Future<String> pollForCustomCharacteristic(List<int> msg) async {
    String reply = "";
    List<BluetoothService> services = await device!.discoverServices();
    services.forEach((service) {
      // do something with service
      // Reads all characteristics
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
       // if(c.uuid.toString().contains("FFE1") || c.uuid.toString().contains("FFE0")) {
        //  c.write(msg);
          reply += "poll success;";
       // }
      }
    });

    reply += "end func";

    return reply;
  } // pollForCustomCharacteristic

  static LedBleBloc emptyCharacteristic(BluetoothDevice d) {
    return LedBleBloc(device: d, customCharacteristic: null);
  }

  static LedBleBloc empty() {
    return LedBleBloc(device: null, customCharacteristic: null);
  }

  getStatus() {
    return _status;
  }
} // LedBleBloc