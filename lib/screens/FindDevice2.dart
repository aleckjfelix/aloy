
import 'dart:async';

import 'package:aloy/bluetooth/Exceotions/CharacteristicNotFoundException.dart';
import 'package:aloy/bluetooth/LedBleBloc.dart';
import 'package:aloy/bluetooth/LedBleBloc2.dart';
import 'package:aloy/screens/HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

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
                  builder: (context) => HomeScreen(ledBleBloc: LedBleBloc2.empty())));
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
                'Not connected'
                ),
              ],
            ),
          ),
        )
    );
  } // build
} // BluetoothOffScreen
/*
Text(
                  'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .subtitle1
                      ?.copyWith(color: Colors.white),
                ),
 */
class FindDevicesScreen2 extends StatefulWidget {
  final LedBleBloc2 ledBleBloc;

  FindDevicesScreen2({required this.ledBleBloc});
  @override
  FindDevicesState2 createState() => FindDevicesState2();
} // FindDevicesScreen

class FindDevicesState2 extends State<FindDevicesScreen2> {
  // get value => null;
  //LedBleBloc2 Widget.ledBleBloc; //= LedBleBloc2(); // get ledBleBloc singleton
  final List<Peripheral> bleDeviceList = <Peripheral>[];

  //StreamController<Peripheral>? streamController;

  @override
  void initState() {
    super.initState();
    //streamController = StreamController.broadcast();

    widget.ledBleBloc.getBleManager().startPeripheralScan().listen((scanResult) {
      setState(() {
        bleDeviceList.add(scanResult.peripheral);
      });
    });
  } // createState

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar(
            title: Text('Bluetooth Devices')
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

    /*

        return ListTile(
      title: Text("A device")
    );

    return FutureBuilder(
      future: bleDeviceList[index].isConnected(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return ListTile(
              trailing: CircularProgressIndicator(),
            );
          } else {
            final bool isconnected = snapshot.data!;

            if(isconnected) {
              return ListTile(
                title: Text(bleDeviceList[index].name),
                subtitle: Text(bleDeviceList[index].identifier),
                trailing: TextButton(
                   child: Text('USE'),
                    onPressed: () {
                      _connectAndRouteHome(context, bleDeviceList[index], true);
                    }
                ),
              );
            } else {
              return ListTile(
                title: Text(bleDeviceList[index].name),
                subtitle: Text(bleDeviceList[index].identifier),
                trailing: TextButton(
                    child: Text('CONNECT'),
                    onPressed: () {
                      _connectAndRouteHome(context, bleDeviceList[index], false);
                    }
                ),
              );
            } // else peripherial not connected
          } // snapshot has data
        } // builder
    );
     */
  } // _makeElement

  void _connectAndRouteHome(BuildContext c, Peripheral d, bool alreadyConnected) async{
    await widget.ledBleBloc.getBleManager().stopPeripheralScan();

    if(!alreadyConnected){
      try {
        await d.connect();
      }catch(_) {
        _showDialog("Couldn't connect to Device!", c);
        return;
      }

      widget.ledBleBloc.device = d; // set device of ledBloc
      await widget.ledBleBloc.deviceState(); // update state
      try {
        //await widget.ledBleBloc.connect(); // connect to device

        await widget.ledBleBloc.initCharacteristics(); // get the characteristic
      } catch(_) {
        _showDialog("Error either connecting or getting Characteristic", c);
        return;
      }
      // route page back home
      Navigator.of(c).push(
          MaterialPageRoute(
              builder: (context)  {
                return HomeScreen(ledBleBloc: widget.ledBleBloc);
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