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
import 'dart:math';

//import 'package:aloy/bluetooth/LedBleBloc.dart';
import 'package:aloy/Data/LedAnimation.dart';
import 'package:aloy/bluetooth/LedBleBloc2.dart';
import 'package:aloy/widgets/ColorWheel/ColorWheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AnimatorScreen.dart';
//import 'FindDevice.dart';
import 'FindDevice2.dart';

/*
 * HomePage
 * States: off, on, Music, Lightshow;
 * Nav to: Menu
 */
class HomeScreen extends StatefulWidget {
 // final BluetoothDevice? device;
  final LedBleBloc2 ledBleBloc; //= LedBleBloc2(); // get the singleton for ledBleBloc
  final LedAnimation currentAnimation;

  HomeScreen({Key? key, required this.ledBleBloc, required this.currentAnimation}) : super(key: key);

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
  Color deactiveColor = Colors.grey[400]!;
  Color currentColor = Colors.grey[400]!;
  Color primaryColor = Colors.pink[100]!;
  bool ledsOn = false;
  // message to debug ble comms
  HSVColor colorToSend = HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0);
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
                  deactiveColor:  Colors.grey[400]!,
                  // activeColor: activeColor,
                  isActive: ledsOn,
                  handleColor: Colors.white,
                  // innerColor: null,
                  // innerColor: null,
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
                  onSelectionMade: (HSVColor ledColor) {
                    //only be called when the finger has been taken off the colorwheel
                    widget.ledBleBloc.sendLedColor(ledColor);
                    //print("Executing code after");
                  },
                ),
          ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: primaryColor
                ),
                child: Text(
                  'Aloy - Main Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24
                  )
                )
              ),
              ExpansionTile(
                leading: Icon(Icons.music_note),
                title: Text('Music Mode')
              ),
              ExpansionTile(
                  leading: Icon(Icons.timeline),
                  title: Text('Animator Mode'),
                  children: <Widget>[
                    Text("Active Animation: " + widget.currentAnimation.animationName),
                    const SizedBox(height: 2),
                    TextButton(
                      child: Text("Start"),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50,20),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: () {
                        widget.currentAnimation.run(widget.ledBleBloc);
                        Navigator.pop(context); // close drawer
                      },
                    ),
                    const SizedBox(height: 2),
                    TextButton(
                      child: Text("Open"),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50,20),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: () {
                        Navigator.pop(context); // close drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AnimatorScreen(ledBleBloc: widget.ledBleBloc,))
                        //Navigator.pushReplacementNamed(context, "/AnimatorScreen");
                        );
                      },
                    ),

              ]
              ),
              ListTile(
                  leading: Icon(Icons.schedule_outlined),
                  title: Text('Scheduler')
              ),
              ExpansionTile(
                  leading: Icon(Icons.bluetooth),
                  title: Text('Devices'),
                  children: <Widget>[
                    Text('Status: ' + widget.ledBleBloc.getStatus()),
                    const SizedBox(height: 2),
                    (widget.ledBleBloc.getDeviceState() == BLEState.connected || widget.ledBleBloc.getDeviceState() == BLEState.connected_no_comms) ? TextButton(
                        child: Text('Disconnect',
                        style: TextStyle(color: Colors.red)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(50,20),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      onPressed: () {
                          setState(() {
                            widget.ledBleBloc.disconnect();
                            Navigator.pop(context); // close drawer

                          });
                      },
                    ):  Text(''),
                    TextButton(
                      child: Text('Find Device'),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50,20),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FindDevice2())
                        );
                      } ,
                      // onPressed
                    )
                  ]
              ),
              ListTile(
                  leading: Icon(Icons.info_outlined),
                  title: Text('About')
              ),
              ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings')
              ),
            ]
          )
      ),
    );
  }//build

  @override
  void initState(){
    super.initState();
    print("initState");
    currentColor = activeColor;
    ledsOn = true;

  }//initState

  @override
  void dispose() {
    super.dispose();
    widget.ledBleBloc.stopBleManager(); // free up resources
  }

  Future<void> _showMyDialog(String msg) async {
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


} // _HomeScreenLedState
