import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';


/*
 * author: Alec KJ Felix
 * LedBLEBloc2.dart
 * A class that handles the managing of bluetooth communication for the LED remote
 * Uses flutter_ble_lib v2.3.2 -> This has not migrated to null safety therefore must add "--no-sound-null-safety" to
 * run/build arguments
 * TODO either use singleton design pattern or Bloc pattern ect..
 */

enum BLEState {disconnected, connected, connected_no_comms, no_device}

class LedBleBloc2 {

   Peripheral? device;
   Characteristic? writeCharacteristic;

   String _status = ""; // Connection status message
   var _deviceState = BLEState.no_device; // device state
   BleManager _bleManager = BleManager();

   // constructor
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

   /*
   * sendLedColor(HSVColor hsvColor)
   * send color to Leds
    */
  void sendLedColor(HSVColor hsvColor) async{
    if(device == null || writeCharacteristic == null)
      return; // if no device or writeCharacteristic do nothing

    if(_deviceState != BLEState.connected)
      return; // do nothing if not connected

    String text = toText(_three60To255Scale(hsvColor.hue), _oneTo255Scale(hsvColor.saturation), _oneTo255Scale(hsvColor.value));
    List<int> msg = utf8.encode(text);

    // write with withResponse = false
    writeCharacteristic!.write(Uint8List.fromList(msg), false);

  } //sendLedColor

   /*
   * _oneTo255Scale(double f)
   * Convert a decimal in range 0-1 to int in range 0 to 255
   * Used for Saturation/value
    */
  int _oneTo255Scale(double f) {
    return (f * 255).round();
  } // _oneTo255Scale

   /*
   * _three60To255Scale(double f)
   * Convert a decimal in range 0-360 to int in range 0 to 255
   * Used for Hue
    */
  int _three60To255Scale(double f) {
    return (f * 0.70833333333).round();
  } // _three60To255Scale

   /*
   * toText(int h, int s, int v)
   * Convert 3 int values 0-255 to a text "VAL1 VAL2 VAL3\n"
   * which can then be sent to the Arduino Led device which will process the string
   * and change the color of the leds
    */
  String toText(int h, int s, int v) {
    return h.toString() + " " + s.toString() + " " + v.toString() + "\n";
  } // toText

  String getStatus() {
    return _status;
  } // getStatus

  BLEState getDeviceState() {
    //await deviceState();
    return _deviceState;
  } // getDeviceState

  BleManager getBleManager() {
    return _bleManager;
  } // getBleManager

   /*
   * initCharacteristics()
   * Gets the HM-10 custom write Characteristic
    */
  Future<void> initCharacteristics() async{
    if(device == null)
      return; // if no device do nothing

    if(!await device!.isConnected())
      await connect(); // connect if disconnected

    // discover devices services and characteristics
    await device!.discoverAllServicesAndCharacteristics();

    // get list of services
    List<Service> services = await device!.services(); //getting all services

    // get a list of characteristics of the HM-10 custom service uuid="ffe0"
    List<Characteristic> characteristics1 = await device!.characteristics("0000ffe0-0000-1000-8000-00805f9b34fb"); // get list of characteristics

    // loop through each characteristic and get the HM-10 custom write characteristic uuid="ffe1"
    for(Characteristic characteristic in characteristics1) {
      if(characteristic.uuid.toString().toLowerCase() == "0000ffe1-0000-1000-8000-00805f9b34fb".toLowerCase()) {
        writeCharacteristic = characteristic; // set writeCharacteristic
        deviceState(); // update device state/status
        return;
      }

    } // get writeCharacteristic (HM-10)

    //_deviceState = BLEState.connected_no_comms;
    deviceState(); // update device state/status
  } // initCharacteristics

   /*
   * connect()
   * Connect to bluetooth device then update state/status
    */
  Future<void> connect() async {
    if(device == null || await device!.isConnected()) {
      return;
    } // do nothing if no device or already connected

    await device!.connect(); // connect to device

    await deviceState(); // update device state/status
  } // connect

   /*
    * disconnect()
    * disconnects from current device if connected otherwise does nothing
    */
  Future<void> disconnect() async {

    if(device == null || !await device!.isConnected())
      return; // do nothing if no device or already already disconnected

      await device?.disconnectOrCancelConnection(); //disconnect device

      await deviceState(); // update device state/status
  } // disconnect

   /*
   * setDevice(Peripherial newDevice)
   * in: Peripheral newDevice
   * sets this.device to newDevice. Disconnects from old device
    */
  Future<void> setDevice(Peripheral newDevice) async {

    if(device != null && await device!.isConnected())
      disconnect(); // disconnect from current device if connected

    // set the device to given device
    device = newDevice;
    await deviceState(); // update device state/status
  } // setDevice

   /*
    * startBleManager()
    * Must call before using any other bluetooth functions
    * Reservers native client bluetooth resources
    */
  void startBleManager() async {
    // initialize native client
    // must be called before using any BLE functions
    await _bleManager.createClient();
  } // _startBleManager

   /*
    * stopBleManager()
    * frees up native client resources
    */
  void stopBleManager() async {
    _bleManager.destroyClient();
  } // _stopBleManager

   /*
   * deviceState()
   * Updates the _state and _status variables
    */
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

   /*
   * emptyCharacteristic(Peripheral d)
   * Returns an LedBleBloc2() with device = d and writeCharacteristic = null
    */
  static LedBleBloc2 emptyCharacteristic(Peripheral d) {
    return LedBleBloc2(device: d, writeCharacteristic: null);
  } // emptyCharacteristic

   /*
   * empty()
   * Returns a LedBleBloc2() with device = null and writeCharacteristic = null
    */
  static LedBleBloc2 empty() {
    return LedBleBloc2(device: null, writeCharacteristic: null);
  } // empty
} // LedBleBloc