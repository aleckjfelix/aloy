import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';


enum BLEState {disconnected, connected, connected_no_comms}

class LedBleBloc {
  BluetoothDevice? device;
  BluetoothCharacteristic? customCharacteristic;


  bool _prevMsgSent = true;
  DateTime _msgSentTime = DateTime.now();
  Duration timeOutTime = const Duration(milliseconds: 50);

  String _status = "";
  var _deviceState = BLEState.disconnected;


  LedBleBloc({
    required this.device,
    required this.customCharacteristic,
  }){
    if(this.device == null) {
      _status = "Not Connected.";
      _deviceState = BLEState.disconnected;
    } else if(this.customCharacteristic == null) {
      if(this.device!.name.length <= 11) {
        _status = this.device!.name + " Connected (no comms).";
        _deviceState = BLEState.connected_no_comms;
      } else {
        _status = this.device!.name.substring(0, 9) + ".. Connected (no comms).";
        _deviceState = BLEState.connected_no_comms;
      }
    }else {
      if(this.device!.name.length <= 11) {
        _status = this.device!.name + " Connected.";
        _deviceState = BLEState.connected;
      }
      else {
        _status = this.device!.name.substring(0, 9) + ".. Connected.";
        _deviceState = BLEState.connected;
      }
    }
  }

  void sendLedColor(HSVColor hsvColor) async{
    if(device == null)
      return; //"No Device Connected";

    String text = toText(_three60To255Scale(hsvColor.hue), _oneTo255Scale(hsvColor.saturation), int, _oneTo255Scale(hsvColor.value));
    List<int> msg = utf8.encode(text);

    if(customCharacteristic != null){
      print("Send Color Called");
     if(_prevMsgSent){
       print("Sending color");
       _prevMsgSent = false;
       try {
         await _writeWithTimeOut(msg);
         _prevMsgSent = true;
       }catch (_) {
         print("Exception Caught");
         _prevMsgSent = true;
         return;
       }
     } // its safe to send next msg
    } // we have a characteristic to write to

  } //sendLedColor

  Future _writeWithTimeOut(List<int> msg) async{
    Future foo =  customCharacteristic!.write(msg, withoutResponse: true);
    return foo.timeout(timeOutTime, onTimeout: (){
      //cancel future ??
      throw ('Timeout');
    });

  }

  void disconnect() async{
    if(device != null) {
      await device!.disconnect();
      _status = "Not Connected.";
      _deviceState = BLEState.disconnected;
    }
  } // disconnect

 int _oneTo255Scale(double f) {
    return (f * 255).round();
 }
int _three60To255Scale(double f) {
    return (f * 0.70833333333).round();
}
 String toText(int h, int s, int, v) {
    return h.toString() + " " + s.toString() + " " + v.toString() + "\n";
 }

  static LedBleBloc emptyCharacteristic(BluetoothDevice d) {
    return LedBleBloc(device: d, customCharacteristic: null);
  }

  static LedBleBloc empty() {
    return LedBleBloc(device: null, customCharacteristic: null);
  }

  String getStatus() {
    return _status;
  }

  BLEState getDeviceState() {
    return _deviceState;
  }
} // LedBleBloc