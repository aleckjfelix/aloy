import 'package:aloy/Data/LedAnimation.dart';
import 'package:aloy/bluetooth/LedBleBloc2.dart';
import 'package:aloy/widgets/ColorGraphAnimator/ColorGraphAnimator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'HomeScreen.dart';

/*
 * author: Alec kj Felix
 * AnimatorScreen.dart
 * A screen within Aloy application which allows:
 *  -> Create animation by tracing out a function on a graph
 *  -> Create animation by writing a mathematical function
 *  -> Save the animation (X saves allowed)
 *  -> Edit a saved animation
 *  -> Set an animation as Active animation and run it
 *
 * TODO: Create my own Graph widget so I don't have to use syncfusion_flutter_charts which requires
 *  a license for comercial apps
 *
 */
class AnimatorScreen extends StatefulWidget {
  final double tabBarHeight = 70.0;
  final LedBleBloc2 ledBleBloc;
  LedAnimation currentAnimation = LedAnimation.empty();

  AnimatorScreen({
    required this.ledBleBloc
  });

  @override
  State<StatefulWidget> createState() {
    return AnimatorScreenState();
  } // createState

} // AnimatorScreen


class AnimatorScreenState extends State<AnimatorScreen> {
  double _divisionsSliderValue = 4; // handle the 'zoom' of the graph
  double _periodSliderValue = 10; // time in seconds for a single period
  DrawingMode _drawingMode = DrawingMode.none;
  SelectedSeries _selectedSeries = SelectedSeries.none;

  //LedAnimation _currentAnimation = LedAnimation.empty();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  } // initState


  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

        return Scaffold (
          appBar: AppBar(
            title: Text('Aloy'),
            centerTitle: true,
            actions: <Widget> [
              IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    _showSaveDialog(context);
                  }
              )],
          ),
          body: SlidingUpPanel(
            minHeight: widget.tabBarHeight,
            maxHeight: 250.0,
            renderPanelSheet: false,
            panelBuilder: (scrollController) => buildSlidingPanel(
                scrollController: scrollController
            ),
            //panel: _floatingPanel(),
            //collapsed: _floatingCollapsed(),
            body: Center(
                child: ColorGraphAnimator(
                  drawingMode: _drawingMode,
                  selectedSeries: _selectedSeries,
                  tempCallBack: (animation) {
                    widget.currentAnimation = animation;
                  },
                )
            ),
          ),
        );

  } // build

  Widget buildSlidingPanel({required ScrollController scrollController}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ]
      ),
      margin: const EdgeInsets.all(24.0),
      child: Center(
        child: DefaultTabController(
          length: 2,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(widget.tabBarHeight - 8),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  title: Icon(Icons.drag_handle),
                  centerTitle: true,
                bottom: TabBar(
                  tabs: [
                    Tab(child: Text('Toolbox')),
                    Tab(child: Text('Equations'))
                  ],
                ),
              ),
              ),
              body: TabBarView(
                children: <Widget> [
                  ListView(
                    controller: scrollController,
                    children: <Widget> [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                          OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  if(_selectedSeries != SelectedSeries.hue){
                                    _selectedSeries = SelectedSeries.hue;
                                    _drawingMode = DrawingMode.drawing;
                                  } else {
                                    if(_drawingMode == DrawingMode.drawing){
                                      _drawingMode = DrawingMode.erasing;
                                    }else if(_drawingMode == DrawingMode.erasing){
                                      _selectedSeries = SelectedSeries.none;
                                      _drawingMode = DrawingMode.none;
                                    }
                                  }
                                });
                              },
                              child: Text('Hue'),
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(selectHSVBorderStyle(SelectedSeries.hue)),
                              ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                if(_selectedSeries != SelectedSeries.saturation){
                                  _selectedSeries = SelectedSeries.saturation;
                                  _drawingMode = DrawingMode.drawing;
                                } else {
                                  if(_drawingMode == DrawingMode.drawing){
                                    _drawingMode = DrawingMode.erasing;
                                  }else if(_drawingMode == DrawingMode.erasing){
                                    _selectedSeries = SelectedSeries.none;
                                    _drawingMode = DrawingMode.none;
                                  }
                                }
                              });
                            },
                            child: Text('Sat'),
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(selectHSVBorderStyle(SelectedSeries.saturation)),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                if(_selectedSeries != SelectedSeries.value){
                                  _selectedSeries = SelectedSeries.value;
                                  _drawingMode = DrawingMode.drawing;
                                } else {
                                  if(_drawingMode == DrawingMode.drawing){
                                    _drawingMode = DrawingMode.erasing;
                                  }else if(_drawingMode == DrawingMode.erasing){
                                    _selectedSeries = SelectedSeries.none;
                                    _drawingMode = DrawingMode.none;
                                  }
                                }
                              });
                            },
                            child: Text('Val'),
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(selectHSVBorderStyle(SelectedSeries.value)),
                            ),
                          )
                        ],
                      ),
                      Slider(
                          value: _divisionsSliderValue.round().toDouble(),
                          min: 1,
                          max: 360,
                          divisions: 360,
                          label: _divisionsSliderValue.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _divisionsSliderValue = value;
                            });
                          }
                      ),
                      Slider(
                        value: _periodSliderValue.round().toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 60,
                        label: _periodSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _periodSliderValue = value;
                          });
                        },
                      )
                    ],
                  ),
                  ListView(
                    controller: scrollController,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Hue'
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Sat'
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Val'
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
        ),
      ),
    );
  }

  BorderSide selectHSVBorderStyle(SelectedSeries seriesNeeded) {
    if(seriesNeeded != _selectedSeries) {
      return BorderSide(
          color: Colors.transparent
      );
    }

    if(_drawingMode == DrawingMode.drawing) {
      return BorderSide(
          color: Colors.pink[100]!
      );
    } else if(_drawingMode == DrawingMode.erasing) {
      return BorderSide(
          color: Colors.red
      );
    }

    return BorderSide(
        color: Colors.transparent
    );

  } // selectHSVBorderStyle


  Future<void> _showSaveDialog(BuildContext c) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Animations'),
          content: ListView(
            children: <Widget> [
              ExpansionTile(
                leading: Icon(Icons.save),
                title: Text('Save As'),
                children: <Widget> [
                  TextFormField(
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Name'
                    ),
                    onChanged: (val) {
                      widget.currentAnimation.animationName = val;
                    },
                  ),
                  TextButton(
                    child: Text('save'),
                    onPressed: () {
                      // route to HomePage and pass Animation obj
                      // route page back home
                      Navigator.of(c).push(
                      MaterialPageRoute(
                      builder: (context)  {
                      return HomeScreen(ledBleBloc: widget.ledBleBloc, currentAnimation: widget.currentAnimation ,);
                      }));
                    },
                  )
                ],
              ),
              ExpansionTile(
                  title: Text('Saved Files'),
                leading: Icon(Icons.folder),
                children: [

                ],
              )
            ],
          )
        );
      },
    );
  } // _showDialog



  Widget _floatingCollapsed(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(20.0)),
      ),
      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      child: Center(
        child: Text(
          "Toolbox",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  } // _floatingCollapsed
} // AnimatorScreen

