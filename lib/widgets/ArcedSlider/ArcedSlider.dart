import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'ArcedSliderBasePainter.dart';

class ArcedSlider extends StatefulWidget {
  final int sliderPos;
  final int intervals;
  final Function onSelectionChange;
  final Color baseColor;
  final Color selectionColor;

  /*
  * constructor
   */
  ArcedSlider(
      {@required this.intervals,
        @required this.sliderPos,
        @required this.onSelectionChange,
        @required this.baseColor,
        @required this.selectionColor});

  @override
  State<StatefulWidget> createState() {
    return _ArcedSliderState();
  }// createState

}// ArcedSlider
class _ArcedSliderState extends State<ArcedSlider>{
  bool _isHandleSelected;
  double startPos;

  /*
  * called when state first created
   */
  void initState() {
    super.initState();
    _calculateSliderData();
  }// initState

  // we need to update this widget both with gesture detector but
  // also when the parent widget rebuilds itself
  @override
  void didUpdateWidget(ArcedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sliderPos != widget.sliderPos) {
      _calculateSliderData();
    }
  }

  @override
  Widget build(BuildContext context) {
     return CustomPaint(
       painter: ArcedSliderBasePainter(
         baseColor: widget.baseColor
       ),
     );
  }// build

  /*
  * _calculateSliderData
  * Calc current sliderBar precentage
  * create base paint and slider paint
   */
  void _calculateSliderData() {
    double slider_pos = 0;
  }// calculatePaintData

}// _ArcedSliderState