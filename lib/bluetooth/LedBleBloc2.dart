import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

enum BLEState {disconnected, connected, connected_no_comms, no_device}

/*
 Class that uses the

 */
class LedBleBloc2 {

   Peripheral? device;
   Characteristic? writeCharacteristic;


  //bool _prevMsgSent = true;

   String _status = "";
   var _deviceState = BLEState.no_device;
   BleManager _bleManager = BleManager();

   LedBleBloc2({
     required this.device,
     required this.writeCharacteristic,
   }){
     deviceState(); // update device state & status
   } // constructor

   /*
  // for singleton pattern
  LedBleBloc2._privateConstructor();
  static final LedBleBloc2 _instance = LedBleBloc2._privateConstructor();
  // to instatiate singleton: LedBleBloc2 bleBloc =  LedBleBloc2();
  factory LedBleBloc2() {
    return _instance;
  } // LedBleBloc2
    */

  void sendLedColor(HSVColor hsvColor) async{
    if(device == null || writeCharacteristic == null)
      return;

    if(_deviceState != BLEState.connected)
      return;

    String text = toText(_three60To255Scale(hsvColor.hue), _oneTo255Scale(hsvColor.saturation), int, _oneTo255Scale(hsvColor.value));
    List<int> msg = utf8.encode(text);

    writeCharacteristic!.write(Uint8List.fromList(msg), false);

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

  String getStatus() {
    return _status;
  }

  BLEState getDeviceState() {
    //await deviceState();
    return _deviceState;
  }

  BleManager getBleManager() {
    return _bleManager;
  }

  Future<void> initCharacteristics() async{
    print("initCharacteristics");
    if(device == null) {
      print("initCharacteristics: No device");
      return;
    }

    if(_deviceState == BLEState.disconnected)
      await connect();
    // either connected (with comms), disconnected, or no device
    await device?.discoverAllServicesAndCharacteristics();
    print("initCharacteristics: discovered services & chars");
    List<Service> services = await device!.services(); //getting all services
    print("initCharacteristics: services " + services.length.toString());
    List<Characteristic> characteristics1 = await device!.characteristics("0000ffe0-0000-1000-8000-00805f9b34fb"); // get list of characteristics
    print("initCharacteristics: characteristics " + characteristics1.length.toString());

    for(Characteristic characteristic in characteristics1) {
      print("initCharacteristics: loopings chars");
      print("\n" + characteristic.uuid.toString());
      if(characteristic.uuid.toString().toLowerCase() == "0000ffe1-0000-1000-8000-00805f9b34fb".toLowerCase()) {
        print("Characteristic found");
        writeCharacteristic = characteristic;
        _deviceState = BLEState.connected;
        return;
      }
    } // get writeCharacteristic (HM-10)

    _deviceState = BLEState.connected_no_comms;
    print("initCharacteristics: Could NOT CONNECT");

  } // initCharacteristics


  Future<void> connect() async {
    if(device == null || await device!.isConnected()) {
      return;
    }
   await device!.connect();

    await deviceState();
  } // connect

  void disconnect() async {
    if(device == null || !await device!.isConnected())
      return;

      await device?.disconnectOrCancelConnection();


    await deviceState();
  } // disconnect

  void setDevice(Peripheral newDevice) async {
    if(device == null)
      return;

    disconnect(); // disconnect from current device

    device = newDevice;
    await deviceState();
  } // setDevice

  void startBleManager() async {
    // initialize native client
    // must be called before using any BLE functions
    await _bleManager.createClient();
  } // _startBleManager

  void stopBleManager() async {
    _bleManager.destroyClient();
  } // _stopBleManager

Future<void> deviceState() async{
    if(device == null) {
      _deviceState = BLEState.no_device;
      _status = "No Device.";
    }else if(!await device!.isConnected()) {
      _deviceState = BLEState.disconnected;
      _status = "Not Connected.";
    } else if(writeCharacteristic == null) {
      _deviceState = BLEState.connected_no_comms;
      if(this.device!.name.length <= 11) {
        _status = this.device!.name + " Connected (no comms).";
      } else {
        _status = this.device!.name.substring(0, 9) + ".. Connected (no comms).";
      }
    } else {
      _deviceState = BLEState.connected;
      if(this.device!.name.length <= 11) {
        _status = this.device!.name + " Connected.";
      }
      else {
        _status = this.device!.name.substring(0, 9) + ".. Connected.";
      }
    }
} // deviceState

static LedBleBloc2 emptyCharacteristic(Peripheral d) {
    return LedBleBloc2(device: d, writeCharacteristic: null);
}

static LedBleBloc2 empty() {
    return LedBleBloc2(device: null, writeCharacteristic: null);
  }


  /*
  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      var locGranted = await Permission.location.isGranted;
      if (locGranted == false) {
        locGranted = (await Permission.location.request()).isGranted;
      }
      if (locGranted == false) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }
  */
} // LedBleBloc