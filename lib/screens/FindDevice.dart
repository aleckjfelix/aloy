
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
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => HomeScreen(ledBleBloc: null)));
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
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context)  {
                                      try {
                                        return HomeScreen(ledBleBloc: _createDeviceBloc(d));
                                      } catch (CharacteristicNotFoundException) {
                                        return HomeScreen(ledBleBloc: LedBleBloc(device: d, custom_characteristic: null));
                                      }

                                    }
                                    ))
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
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        r.device.connect();
                        try {
                          return HomeScreen(ledBleBloc: _createDeviceBloc(r.device));
                        } catch (CharacteristicNotFoundException) {
                          return HomeScreen(ledBleBloc: LedBleBloc(device: r.device, custom_characteristic: null));
                        }
                      })),
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



  LedBleBloc _createDeviceBloc(BluetoothDevice device) {
    LedBleBloc? myBloc;
    _getCustomCharacteristic(device).then((value) {
      myBloc = LedBleBloc(device: device, custom_characteristic: value);
      return myBloc;
    }).catchError((e) {
      throw CharacteristicNotFoundException();
    });

    throw CharacteristicNotFoundException();
  }

  Future<BluetoothCharacteristic> _getCustomCharacteristic(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();

    return Future.sync(() {
        for(BluetoothService service in services) {
      // do something with service
      // Reads all characteristics
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if(c.uuid.toString().contains("FFE1") || c.uuid.toString().contains("FFE0")) {
          return c;
        } // if
      } // for each characteristic of a service
    } // for each serivce

    throw CharacteristicNotFoundException();
    }); // any error throw in here can be caught in .then catch error

  } // _getCustomCharacteristic
  
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
  }

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
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

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
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

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
  }
}