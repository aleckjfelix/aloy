/*
* author: Alec KJ Felix
* Date project began: Unknown
* -> Technically was supposed to be a birthday gift for Joy's 21st birthday (07/03/2019), but
* I procrastinated and didn't get it completed. I got some basic functionality done with Java
* (ie. could turn an LED on/off). But did'nt have much of an App nor the LED sign wired up
* -> I restarted progress at the beginning of the Fall semester (2020-2021 academic year) this time
* using Flutter since my gf has an iPhone. But was bogged down with school and didn't make much progress
* beyond testing the BLutooth works and I could use CodeMagic to get the app on my phone.
* -> 12/24/2020 I am getting serious about completing NOT for Xmas, but either for sometime in January before
* school starts or possibly even Valentine's day. I am leaning towards before spring semester so she can enjoy
* the gift before the pressures of school come back.
* project Completion Date: --
*
* main.dart
* A BLE LED Remote controller app for my girlfriend Joy.
* The main features this app MUST have:
*  - LED On/Off button
*  - Bluetooth devices list + connect/disconnect
*  - Color wheel: Select color for LED's
*  - Intensity slider: Adjust light's intensity  0% <-> 100%
*  - Music Mode:
*     -> Three Options
*         1. Somehow be able to analyze music being played from another app on the phone
*     and have the lights 'follow' the music. Might only work for a few music apps?
*         2. Use DSP techniques to sample music being played from any source in the same
*     room as the phone and use this data to 'follow' the music (sounds fun since I'll be
*     applying EE322 knowledge to do so!!)
*         3. Have hardware connected to LED (arduino sound module) do its thing to follow
*     the music. Most coding would then be done on the Arduino. The remote would just tell
*     the Arduino to go into music mode.
*     -> So far: I vote Option 2
*  - Led Animator:
*     -> Preset Animations (pulse, flash, glow etc..)
*     -> Ability to create custom animations (sky's the limit)
*  - LED Schedule:
*     -> Complimentary to the animator
*     -> Set time periods (schedules) for different colors, animations, modes, that the LED's
*     should be in (based on day and time)
*   - Settings:
*     -> Change UI / Remote Theme/ Color scheme
*     -> Misc
*   - About:
*     -> Info about the App/Why created/Who it's for, ect..
*
 */
import 'package:aloy/widgets/ColorWheel/ColorWheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

/*
 * main method
 */
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
  BluetoothDevice connectedDevice;
  List<BluetoothService> services;
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenLedState();
  }//build
}//HomePage

/*
 * HomeScreenLedOnState
 * What HomeScreen looks like with LED ON
 */
class _HomeScreenLedState extends State<HomeScreen> {
  // mutable data
  Color activeColor = Colors.black; // would like to set these in the settings
  Color deactiveColor = Colors.grey[400];
  Color currentColor = Colors.grey[400];
  bool ledsOn = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]); // hide system UI (fullscreen)
    //print("leds on = " + ledsOn.toString() + " | current color = " + currentColor.toString());
    return Scaffold(
      appBar: AppBar(
          title: Text('Aloy', style:  TextStyle(color: currentColor)),
          leading: Builder(
              builder: (context) =>  IconButton(
                  icon: Icon(Icons.menu, color: currentColor),
                  onPressed: () => Scaffold.of(context).openDrawer()

              )
          ),
          actions: <Widget>[IconButton(
              icon: Icon(Icons.power_settings_new, color: currentColor),
              onPressed: () {
                setState(() {
                  ledsOn = !ledsOn;
                  if(ledsOn){
                    currentColor = activeColor;
                  }else {
                    currentColor = deactiveColor;
                  }
                });
              }
          )],
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0
      ),
      body:
          Center(
            child: ColorWheel(
              deactiveColor:  Colors.grey[400],
              activeColor: activeColor,
              isActive: ledsOn,
              handleColor: Colors.white,
              innerColor: null,
              animateChild: false,
              width: 375,
              height: 375,
              outerBaseStrokeWidth: 21.0,
              innerBaseStrokeWidth: 18.0,
              handleStrokeWidth: 2.0,
              padding: 8.0,
              handlePos: 0.0,
              svHandlePos: Offset(0.0,0.0),
              showInnerColor: false,
              onSelectionChange: (HSVColor ledColor) {

              },

            ),
          ),
      bottomNavigationBar: BottomAppBar(
        color: currentColor,
        elevation: 0,
        child: Container(
          margin: const EdgeInsets.all(2),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle
                    ),
                    child: IconButton(
                        icon: Icon(Icons.music_note),
                        onPressed: null
                    ),
                  ),
                ),
                SizedBox(width: 0.2),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle
                    ),
                    child: IconButton(
                        icon: Icon(Icons.timeline),
                        onPressed: null
                    ),
                  ),
                ),
                SizedBox(width: 0.2),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle
                    ),
                    child: IconButton(
                        icon: Icon(Icons.schedule_outlined),
                        onPressed: null
                    ),
                  ),
                ),
                SizedBox(width: 0.2),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle
                    ),
                    child: IconButton(
                        icon: Icon(Icons.info_outlined),
                        onPressed: null
                    ),
                  ),
                ),
                SizedBox(width: 0.2),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle
                    ),
                    child: IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: null
                    ),
                  ),
                ),
              ]
          ),
        ),
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
    print("initState");
    currentColor = activeColor;
    ledsOn = true;
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
            height: 100,
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
                    onPressed: () {
                      setState(() async{
                        widget.flutterBlue.stopScan();
                        try{
                          await device.connect();
                        }catch(e) {
                          if(e.code != 'already_connected')
                            throw e;
                        }finally {
                          widget.services = await device.discoverServices();
                        }
                        widget.connectedDevice = device;
                      });
                    }
                ),
              ],
            )
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

}//_HomeScreenLedOnState
