
/*
 * author: Alec KJ Felix
 * email: AlecKjFelix@gmail.com
 * github:
 * ColorGraphAnimator.dart
 *
 * A widget that is a Graph:
 *  -> Hue (0,360) or (0,2pi) and SV (0,1.0) on yAxis
 *  -> Fractions (nT) of a period (T) on xAxis
 *  -> Two ways to create a Graph
 *    1. Trace with finger on graphing Area
 *    2. Pass a mathmatical function
 *  -> 3 series can be plotted Hue, Saturation, and Value
 *  -> Have a gradient of the Hue going along the yAxis to make it easier to know what colors the animation will be
 */
import 'package:aloy/Data/LedAnimation.dart';
import 'package:aloy/widgets/utility/MathUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* Global Constants */
enum PointerStatus {
  withinChartArea,
  none // not doing anything
} // flag for where pointer was pressed

enum SelectedSeries {
  hue,
  saturation,
  value,
  none
}

enum DrawingMode {
  drawing,
  erasing,
  none
}

class ColorGraphAnimator extends StatefulWidget {

  final SelectedSeries selectedSeries;
  final DrawingMode drawingMode;
  final Function? tempCallBack;
  final int periodLength; // length of a period(seconds)
  final int delta = 20; // ms between each point

  ColorGraphAnimator({
    this.drawingMode = DrawingMode.none,
    this.selectedSeries = SelectedSeries.none,
    this.periodLength = 10,
    this.tempCallBack
  }); // constructor

  @override
  State<StatefulWidget> createState() {
    return ColorGraphAnimatorState();
  }// createState

} // ColorGraphAnimator

/*
 * Class for mutable data of ColorGraphAnimator
 */
class ColorGraphAnimatorState extends State<ColorGraphAnimator> {
  LedAnimation currentAnimation = LedAnimation.empty();
//  var hue_coords = <Coord>[];
//  var sat_coords = <Coord>[];
//  var val_coords = <Coord>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: new EdgeInsets.fromLTRB(0,20,0, 120),
        child: Center(
        child: SfCartesianChart(
              // Initialize category axis
              primaryXAxis: NumericAxis(
                  minimum: 0,
                  maximum: widget.periodLength.toDouble(),
                  title: AxisTitle(
                      text: 'Time (sec)'
                  )
              ),
              primaryYAxis: NumericAxis(
                  name: 'hue_axis',
                  minimum: 0,
                  maximum: 360,
                  interval: 60,
                  title: AxisTitle(
                      text: "Hue",
                      textStyle: TextStyle(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto'
                      )
                  )
              ),
              axes: <ChartAxis>[
                NumericAxis(
                    name: 'sv_axis',
                    minimum: 0,
                    maximum: 1,
                    opposedPosition: true,
                    title: AxisTitle(
                        text: "SV",
                        textStyle: TextStyle(
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto'
                        )
                    )
                )
              ],
              series: <LineSeries<Coord, double>>[
                LineSeries<Coord, double>(
                  // Bind data source
                    dataSource:  currentAnimation.hue_coords,
                    xValueMapper: (Coord sales, _) => sales.x,
                    yValueMapper: (Coord sales, _) => sales.y,
                    yAxisName: 'hue_axis'
                ),
                LineSeries<Coord, double>(
                  // Bind data source
                    dataSource:  currentAnimation.sat_coords,
                    xValueMapper: (Coord sales, _) => sales.x,
                    yValueMapper: (Coord sales, _) => sales.y,
                    yAxisName: 'sv_axis'
                ),
                LineSeries<Coord, double>(
                  // Bind data source
                    dataSource:  currentAnimation.val_coords,
                    xValueMapper: (Coord sales, _) => sales.x,
                    yValueMapper: (Coord sales, _) => sales.y,
                    yAxisName: 'sv_axis'
                ),
              ],
              onChartTouchInteractionDown: _onChartTouchDown,
              onChartTouchInteractionMove: _onChartTouchMove,
              onChartTouchInteractionUp: _onChartTouchUp,
            ),
        )
    );
  } // build()

  /*
   * _onChartTouchDown
   * Called when touch on the chart area
   */
  void _onChartTouchDown(ChartTouchInteractionArgs tapArgs) {
    if(widget.selectedSeries == SelectedSeries.none)
      return;

    // get position of finger
   // tapArgs.position.dx
    if(widget.drawingMode == DrawingMode.drawing) {
      // add point at finger position to the correct cord list
      if(widget.selectedSeries == SelectedSeries.hue)
        _addPointToSeries(tapArgs.position, (341.4-50) / widget.periodLength, (571.4-50)/360);
      else {
        _addPointToSeries(tapArgs.position, (341.4-50) / widget.periodLength, (571.4-50));
      }
    }else if(widget.drawingMode == DrawingMode.erasing) {

    }


  } // _onChartTouchDown()
  /*
   * _onChartTouchMove
   * Occurs when touched and moved on the chart area.
   */
  void _onChartTouchMove(ChartTouchInteractionArgs tapArgs) {

  } // _onChartTouchMove

  /*
   * _onChartTouchUp
   * Occurs when tapped on the chart area.
   */
  void _onChartTouchUp(ChartTouchInteractionArgs tapArgs) {

  } // _onChartTouchUp


  void _addPointToSeries(Offset tapPos, double xScaleFactor, yScaleFactor) {
    print("tapPos:" + tapPos.dx.toString() + ", " + tapPos.dy.toString());
    Offset coords = MathUtils.canvasCoordsToOtherCoords(tapPos, Offset(52.5,571.4-50));
    Offset scaledCoords = Offset(coords.dx / xScaleFactor, coords.dy / yScaleFactor);
    print("tapPos:" + scaledCoords.dx.toString() + ", " + scaledCoords.dy.toString());


    setState(() {
      if(widget.selectedSeries == SelectedSeries.hue){
        currentAnimation.hue_coords.add(Coord(scaledCoords.dx, scaledCoords.dy));
      }else if(widget.selectedSeries == SelectedSeries.saturation){
        currentAnimation.sat_coords.add(Coord(scaledCoords.dx, scaledCoords.dy));
      }else {
        currentAnimation.val_coords.add(Coord(scaledCoords.dx, scaledCoords.dy));
      } // selected series is SelectedSeries.value

      if(widget.tempCallBack != null)
        widget.tempCallBack!(currentAnimation);
    });
  } // _addPointToSeries

} // _ColorWheelState