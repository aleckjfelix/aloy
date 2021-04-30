import 'dart:ui';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

class LedBleBloc {
  static final FlutterBlue flutterBlue = FlutterBlue.instance;
  static List<BluetoothDevice> devices = <BluetoothDevice>[];
  static BluetoothDevice? connectedDevice;
  static List<BluetoothService>? services;
  static List<BluetoothCharacteristic>? characteristics;

  static BluetoothService? hm10_service;
  static final Guid HM10_CUSTOM_UUID = Guid("0000FFE0-0000-1000-8000-00805F9B34FB");
  static BluetoothCharacteristic? hm10_characteristic;


  static startScanForBluetoothDevices(){
    flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
      for(BluetoothDevice device in devices)
        _addDeviceToList(device);
    });
    flutterBlue.scanResults.listen((List<ScanResult> results){
      for(ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    flutterBlue.startScan();
  }

  _stopScanForBluetoothDevices() {
    flutterBlue.stopScan();
  }


  static void _addDeviceToList(final BluetoothDevice device) {
    if(!devices.contains(device)){
        devices.add(device);
    }//list does'nt contain device
  }//_addDeviceToList

  static void connectToDevice(BluetoothDevice device ) async {
    flutterBlue.stopScan();
    try{
      await device.connect();
      connectedDevice = device;

      services = await device.discoverServices();
      _discoverServices();
    }catch(e) {
      if(e.toString() != 'already_connected')
        throw e;
    }
  } // _connectToDevice

  static bool sendLedColor(Color rgbColor) {
   // if(hm10_characteristic == null)
     // return false;
    hm10_characteristic!.write([rgbColor.red, rgbColor.blue, rgbColor.green]);
    return true;
  } //sendLedColor

  /*
   *  return true if found HM-10 custom service
   */
  static bool _discoverServices() {
    for(BluetoothService service in services!) {
      if(service.uuid == HM10_CUSTOM_UUID) {
        hm10_service = service;
        characteristics = service.characteristics;
        _discoverCharacteristic();
        return true;
      }
    }
    return false;
  }

  static void _discoverCharacteristic() {
    hm10_characteristic = hm10_service!.characteristics.first;
  }



} // LedBleBloc