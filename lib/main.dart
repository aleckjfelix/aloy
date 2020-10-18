
/*
 * main method
 */
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}//main method

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }//build

}//MyApp

/*
 * HomePage
 * States: off, on, Music, Lightshow;
 * Nav to: Menu
 */
class HomeScreen extends StatefulWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devices = new List<BluetoothDevice>();

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenLedOnState();
  }//build
}//HomePage

/*
 * HomeScreenLedOnState
 * What HomeScreen looks like with LED ON
 */
class _HomeScreenLedOnState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
              title: const Text('Aloy'),
              leading: Builder(
                builder: (context) =>  IconButton(
                    icon: Icon(Icons.menu, color:Colors.black),
                    onPressed: () => Scaffold.of(context).openDrawer()
                )
              ),
              actions: <Widget>[IconButton(
                  icon: Icon(Icons.power_settings_new),
                  onPressed: null
              )],
              centerTitle: true,
              backgroundColor: Colors.white
          ),
          body:
              Column(
                children: <Widget>[

                ],
              ),
          bottomNavigationBar: BottomAppBar(
              color: Colors.grey,
              elevation: 0,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.music_note),
                        onPressed: null
                    ),
                    IconButton(
                        icon: Icon(Icons.wb_incandescent_outlined),
                        onPressed: null
                    )
                  ]
              )
          ),
          drawer: Drawer(
            child: _buildListViewOfDevices()
          ),
      );
  }//build

  _addDeviceToList(final BluetoothDevice device){
    if(!widget.devices.contains(device)){
      setState(() {
        widget.devices.add(device);
      });
    }//list does'nt contain device
  }//_addDeviceToList

  @override
  void initState(){
    super.initState();
    widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
      for(BluetoothDevice device in devices)
        _addDeviceToList(device);
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results){
      for(ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }//initState

  ListView _buildListViewOfDevices() {
    List<Widget> containers = new List<Widget>();
    containers.add(DrawerHeader(
      child: Text('Devices'),
      decoration: BoxDecoration(
        color: Colors.white
      )
    ));
    for (BluetoothDevice device in widget.devices) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ...containers,
      ],
    );
  }

}//_HomeScreenLedOffState

/*
 * HomeScreenLedOnState
 * What HomeScreen looks like with LED OFF
 */
class _HomeScreenLedOffState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }//build

}//_HomeScreenLedOffState


/*
 * Devices Page
 * View a list of available devices
 * Connect to a BLE device
 * Disconnect from BLE device
 */
class DevicesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}//DevicesPage
