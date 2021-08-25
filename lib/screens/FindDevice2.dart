import 'dart:async';
import 'package:aloy/Data/LedAnimation.dart';
import 'package:aloy/bluetooth/LedBleBloc2.dart';
import 'package:aloy/screens/HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

/*
 * author: Alec KJ Felix
 * Uses LecBleBloc2 which uses flutter_ble_lib for bluetooth instead of flutter_blue
 */

class FindDevice2 extends StatelessWidget {
  LedBleBloc2 _bleBloc = LedBleBloc2.empty(); // obtain instance of bleManager singleton

  @override
  Widget build(BuildContext context) {
    _bleBloc.startBleManager();

    return StreamBuilder<BluetoothState>(
        stream: _bleBloc.getBleManager().observeBluetoothState(),
        initialData: BluetoothState.UNKNOWN,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.POWERED_ON) {
            return FindDevicesScreen2(ledBleBloc: _bleBloc,);
          }
          return BluetoothOffScreen2(state: state);
        } // builder
    );
  } // build
} // FindDevice

class BluetoothOffScreen2 extends StatelessWidget {
  const BluetoothOffScreen2({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(ledBleBloc: LedBleBloc2.empty(), currentAnimation: LedAnimation.empty(),)));
        },
        child:Scaffold(
          backgroundColor: Colors.pink[100]!,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.bluetooth_disabled,
                  size: 200.0,
                  color: Colors.white54,
                ),
                Text(
                  'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .subtitle1
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        )
    );
  } // build
} // BluetoothOffScreen

/*
* class FindDevicesScreen2
* Display a list of Bluetooth devices to connect to
 */
class FindDevicesScreen2 extends StatefulWidget {
  final LedBleBloc2 ledBleBloc;

  FindDevicesScreen2({required this.ledBleBloc});
  @override
  FindDevicesState2 createState() => FindDevicesState2();
} // FindDevicesScreen

class FindDevicesState2 extends State<FindDevicesScreen2> {
  final List<Peripheral> bleDeviceList = <Peripheral>[];

  @override
  void initState() {
    super.initState();

    // add peripherial to bleDeviceList as they are discovered and update the UI
    widget.ledBleBloc.getBleManager().startPeripheralScan().listen((scanResult) {
      setState(() {
        bleDeviceList.add(scanResult.peripheral);
      });
    });
  } // createState

  @override
  void deactivate() {
    super.deactivate();
    widget.ledBleBloc.getBleManager().stopPeripheralScan();
  } // deactivate

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar(
            title: Text('Aloy')
        ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: ListView.builder(
          itemCount: bleDeviceList.length,
            itemBuilder:  (BuildContext context, int index) => _makeElement(index)
        ),
      )
    );
  } // build

  Widget _makeElement(int index) {
    if (index >= bleDeviceList.length)  {
      return ListTile(
        title: Text('Non-null str'),
      );
    }

    return ListTile(
      title: Text(bleDeviceList[index].name != null ?  bleDeviceList[index].name : 'Unknown'),
      subtitle: Text(bleDeviceList[index].identifier != null ? bleDeviceList[index].identifier : 'Unknown'),
      trailing: TextButton(
          child: Text('CONNECT'),
          onPressed: () {
            _connectAndRouteHome(context, bleDeviceList[index], false);
          }
      ),
    );
  } // _makeElement

  /*
   * Connect  to the chose Bluetooth device
   * set the ledBleBloc device, writeCharacteristic
   * Return to HomeScreen and pass ledBleBloc
   */
  void _connectAndRouteHome(BuildContext c, Peripheral d, bool alreadyConnected) async{
    await widget.ledBleBloc.getBleManager().stopPeripheralScan();

    if(!alreadyConnected){
      try {
        await d.connect();
      }catch(_) {
        _showDialog("Couldn't connect to Device!", c);
        return;
      }

      await widget.ledBleBloc.setDevice(d); // set device of ledBloc

      try {
        await widget.ledBleBloc.initCharacteristics(); // get the characteristic
      } catch(_) {
        _showDialog("Error either connecting or getting Characteristic", c);
        return;
      }
      // route page back home
      Navigator.of(c).push(
          MaterialPageRoute(
              builder: (context)  {
                return HomeScreen(ledBleBloc: widget.ledBleBloc, currentAnimation: LedAnimation.empty(),);
              }));
    } // first connect





  } // _connectAndRouteHome


  Future<void> _refresh() async {
    await widget.ledBleBloc.getBleManager().stopPeripheralScan();

  } // _refresh

  Future<void> _showDialog(String msg, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert! Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("sent: " + msg)
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } // _showDialog

} // FindDevicesState2