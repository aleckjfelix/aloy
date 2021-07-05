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

  String sendLedColor(HSVColor hsvColor) {
    String text = toText(_three60To255Scale(hsvColor.hue), _oneTo255Scale(hsvColor.saturation), int, _oneTo255Scale(hsvColor.value));
    List<int> msg = utf8.encode(text);
    if(custom_characteristic != null){
     // List<int> msg = utf8.encode(toText(_to255Scale(hsvColor.hue), _to255Scale(hsvColor.saturation), int, _to255Scale(hsvColor.value)));
      custom_characteristic!.write(msg);
      return "Color: [" + hsvColor.hue.toString() + ", " + hsvColor.saturation.toString() + ", " + hsvColor.value.toString() +"]\n" + "Color Scaled: [" + text + "]" + "\n" + "sent: [" + msg.toString() + "]";
    }
    // poll for characteristic
    String pollReply = "";
    pollForCustomCharacteristic(msg).then((value) {
     pollReply = value;
     return "Color: [" + hsvColor.hue.toString() + ", " + hsvColor.saturation.toString() + ", " + hsvColor.value.toString() +"]\n" + "Color Scaled: [" + text + "]" + "\nsent Polled:"+ msg.toString() + "\n" + "Poll Reply: " + pollReply;
    }).catchError((e) {
      return "Color: [" + hsvColor.hue.toString() + ", " + hsvColor.saturation.toString() + ", " + hsvColor.value.toString() +"]\n" + "Color Scaled: [" + text + "]" + "\nsent Polled:"+ msg.toString() + "\n" + "Poll Reply: Error:" +  e.toString();
    });
    return "Can't get here";
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
        if(c.uuid.toString().contains("FFE1") || c.uuid.toString().contains("FFE0")) {
          c.write(msg);
          reply += "poll success;";
        }
      }
    });

    reply += "end func";

    return reply;
  } // pollForCustomCharacteristic
} // LedBleBloc