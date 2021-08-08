import 'package:aloy/bluetooth/Exceotions/CharacteristicNotFoundException.dart';
import 'package:aloy/bluetooth/LedBleBloc.dart';
import 'package:aloy/screens/HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FindDevice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return FindDevicesScreen();
          }
          return BluetoothOffScreen(state: state);
        } // builder
    );
  } // build
} // FindDevice

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          /* NEEDED
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => HomeScreen()));
           */
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

class FindDevicesScreen extends StatelessWidget {
  // get value => null;


  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar(
            title: Text('Bluetooth Devices')
        ),
        body: RefreshIndicator(
            onRefresh: () => FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
            child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    StreamBuilder<List<BluetoothDevice>>(
                      stream: Stream.periodic(Duration(seconds: 2))
                          .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                      initialData: [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map((d) => ListTile(
                          title: Text(d.name),
                          subtitle: Text(d.id.toString()),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: d.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (c, snapshot) {
                              if (snapshot.data == BluetoothDeviceState.connected) {
                                return TextButton(
                                  child: Text('USE'),
                                  onPressed: () {
                                    _connectAndRouteHome(context, d, false);
                                  },
                                );
                              }
                              return Text(snapshot.data.toString());
                            },
                          ),
                        ))
                            .toList(),

                      ),
                    ),
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBlue.instance.scanResults,
                      initialData: [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map(
                              (r) => ScanResultTile(
                            result: r,
                            onTap: () {
                              _connectAndRouteHome(context, r.device, false);
                            },
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                )
            )
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBlue.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => FlutterBlue.instance.stopScan(),
                backgroundColor: Colors.red[300]!,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () => FlutterBlue.instance
                      .startScan(timeout: Duration(seconds: 4)),
                  backgroundColor: Colors.pink[100]!);
            }
          },
        )
    );
  } // build

  void _connectAndRouteHome(BuildContext buildContext, BluetoothDevice device, bool alreadyConnected ) async{

    if (!alreadyConnected) {
      try {
        await device.connect();
      } catch(_) {
        // show a dialog message that we could'nt connect
        _showDialog("Couldn't connect to Device!", buildContext);
        return;
      }
    } // if not connect to device

    LedBleBloc myBloc;

    try {
      BluetoothCharacteristic hm10Char = await _getCustomCharacteristic(device);
      myBloc = LedBleBloc(device: device, customCharacteristic: hm10Char);
    } catch(CharacteristicNotFoundException){
      // show a dialog that we couldn't find the Hm-10 custom characteristic
      await device.disconnect();
      myBloc = LedBleBloc.empty();
      _showDialog("Couldn't find HM-10 ffe1 characteristic!", buildContext);
      return;
    }

    // myBloc successfully created navigate back to HomeScreen
/* NEEDED
    Navigator.of(buildContext).push(
        MaterialPageRoute(
            builder: (context)  {
             // return HomeScreen(ledBleBloc: myBloc,);
            }));
 */
  }

  Future<BluetoothCharacteristic> _getCustomCharacteristic(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();

    return Future.sync(() {
      for(BluetoothService service in services) {
        // do something with service
        // Reads all characteristics
        var characteristics = service.characteristics;
        for(BluetoothCharacteristic c in characteristics) {
          print(c.uuid.toString());
          if(c.uuid.toString().contains("ffe1")) {
            //print("Found the custom characteristic");
            return c;
          } // if
        } // for each characteristic of a service
      } // for each service

      throw CharacteristicNotFoundException();
    }); // any error throw in here can be caught in .then catch error

  } // _getCustomCharacteristic

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

} // FindDevicesScreen


/*
 * Widget which displays the a given bluetooth device's info as an ExpansionTile
 */
class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  } // _buildTitle

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  } // _buildAdvRow

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  } // getNiceHexArray

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  } // getNiceManufacturerData

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  } // getNiceServiceData

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: TextButton(
        child: Text('CONNECT'),
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),
      children: <Widget>[
        _buildAdvRow(
            context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(context, 'Manufacturer Data',
            getNiceManufacturerData(result.advertisementData.manufacturerData)),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(result.advertisementData.serviceData)),
      ],
    );
  } // build function

} // ScanResultTile