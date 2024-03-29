/*
* author: Alec KJ Felix
* Date Created: 12/30/2020
* A wheel Widget that allows for the color Selection
* Consists of:
* - large Circular ring:
*   -> active: has a color gradient or just active color
*   -> de-active: black/grayscale/deactive color
* - Circular handle:
*   -> active: Can be dragged around the ring to select the H value 0-360
*   -> deactive: hidden gets no input
* - inner circle:
*   -> active: painted with final HSV color
*   -> deactive: white
* - child: image within circle (heart with pic of me and Joy)
*  -> Option to be animated (grow/shrink) with given rhythm
*  -> Active: image
*  -> deactive: grayscale image
* TODO Find way of getting instance vars from painters which are used in_onPanDown
 */
import 'dart:math';
import 'package:aloy/widgets/ColorWheel/ColorWheelBase.dart';
import 'package:aloy/widgets/ColorWheel/ColorWheelSelector.dart';
import 'package:aloy/widgets/utility/MathUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/* Global Constants */
enum PointerStatus {
  onHandle, // on the slider handle (Hue handle)
  insideSliderRing, // in the inner circle
  alongSliderRing, // on the outer ring of the color wheel
  onSVHandle, // on the SV Handle
  none // not doing anything
} // flag for where pointer was pressed

class ColorWheel extends StatefulWidget {
  /* Color of Wheel when active or deactive */
  final Color deactiveColor;
  //final Color activeColor;
  final Color handleColor;


  /* if null innerColor defaults to white */
  /* if false outer ring will be activeColor */
  final Color innerColor; // * not used rn
  final bool showInnerColor;
  /* vars for the child widget inscribed in the ColorWheel */
  final Widget? child;
  final bool animateChild;/* if true child widget can be animated */

  /* width and height of canvas for this widget  default: */
  final double height;
  final double width;

  /* whether this ColorWheel is Active or not */
  final bool isActive;

  /*variables needed for ColorWheel functionality */
  final double handlePos;
  final Function(HSVColor)? onSelectionChange;
  final Function(HSVColor)? onSelectionMade;
  final Offset svHandlePos;

  /* drawing vars used in the Painters */
  final double innerBaseStrokeWidth;
  final double outerBaseStrokeWidth;
  final double handleStrokeWidth;
  final double padding;


  ColorWheel({
    @required this.deactiveColor=Colors.grey,
     // @required this.activeColor,
    @required this.innerBaseStrokeWidth=18.0,
    @required this.outerBaseStrokeWidth=21.0,
    @required this.handleStrokeWidth=2.0,
    @required this.handlePos=0.0,
    @required this.onSelectionChange,
    @required this.onSelectionMade,
    @required this.child,
    @required this.isActive=true,
    @required this.handleColor=Colors.white,
    @required this.innerColor=Colors.white,
    @required this.animateChild=false,
    @required this.height=375,
    @required this.width=375,
    @required this.padding=8.0,
    @required this.svHandlePos= const Offset(0.0,0.0),
    @required this.showInnerColor=false,
  }); // constructor


  @override
  State<StatefulWidget> createState() {
    return _ColorWheelState();
  }// createState

}// ColorWheel

/*
 * Class for the mutable state data and Widget building
 */
class _ColorWheelState extends State<ColorWheel> {
  HSVColor _currentHsvColor = HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0); // the currently selected color
  double _handleAngle = 0.0;
  PointerStatus _pointerStatus = PointerStatus.none; // where pointer was initially
  bool _showSvSelector = false;
  Offset _svHandlePos = Offset(0.0,0.0);
  Offset? _oldPointerPos;

  void initState() {
    super.initState();
    _currentHsvColor = HSVColor.fromAHSV(1.0, _angleToHue(widget.handlePos), 1.0, 1.0);
    _handleAngle = widget.handlePos;
    _pointerStatus = PointerStatus.none;
    _showSvSelector = false;
    _svHandlePos = widget.svHandlePos;

    _oldPointerPos = null;
  } // initState

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
          onPanDown: _onPanDown,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
              painter: ColorWheelBase(
                  deactiveColor: widget.deactiveColor,
                  hsvColor: _currentHsvColor,
                  isActive: widget.isActive,
                  padding: widget.padding,
                  innerStrokeWidth: widget.innerBaseStrokeWidth,
                  outerCircleStroke: widget.outerBaseStrokeWidth,
                  innerColor: widget.innerColor,
                  showInnerColor: widget.showInnerColor
              ),
              foregroundPainter: ColorWheelSelector(
                  handleColor: widget.handleColor,
                  handleAngle: _handleAngle,
                  isActive: widget.isActive,
                  handleStokeWidth: widget.handleStrokeWidth,
                  outerStrokeWidth: widget.outerBaseStrokeWidth,
                  innerStrokeWidth: widget.innerBaseStrokeWidth,
                  padding: widget.padding,
                  showSVSelector: _showSvSelector,
                  hsvColor: _currentHsvColor,
                  svHandlePos: _svHandlePos
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(widget.outerBaseStrokeWidth),
                  child: Container(
                    width: widget.width - 3 * (widget.outerBaseStrokeWidth + widget.padding),
                    height: widget.width - 3 * (widget.outerBaseStrokeWidth + widget.padding),
                    child: Image(
                        image: widget.isActive ? AssetImage("assets/Aloy_heart01_color.png") : AssetImage("assets/Aloy_heart01_grayscale.png"),
                      ),
                  ),
                ),
              )
          )
      ),
    );

  } // build

/*
 * _onPanDown(DragDownDetails details)
 * Called when a pointer makes contact with the screen
 * (Gesture Detector onPanDown attribute callback function)
 * Case 1: Pointer on the handles coordinates
 * -> set _isHandleSelected to true so handle can be updated
 * as the pointer is dragged
 * Case 2: Pointer on the inside of the circle
 * -> Display 2D gradient plot to adjust the SV values of the HSV color space
 * -> On next OnPanDown if within bounds of 2D gradient plot set
 * Case 3: Pointer on point along color wheel not on the handle
 * -> handle should jump to that position
 */
  void _onPanDown(DragDownDetails details) {
    if(!widget.isActive)
      return;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset pointerPos = renderBox.globalToLocal(details.globalPosition);
    _oldPointerPos = pointerPos;

    if(pointerPos == null)
      return;

    // perform calc for various measurments of color wheel
    // TODO find way to just get these from the painters since they are used there

    double handleRadius = widget.outerBaseStrokeWidth / 2 + 2;

    //radius from canvasCenter to center of Base Wheel
    double baseRadius = (min(renderBox.size.width, renderBox.size.height) - widget.outerBaseStrokeWidth) / 2 - widget.padding;

    Offset canvasCenter = Offset(renderBox.size.width/2, renderBox.size.height/2);

    Offset handleCenter = MathUtils.angleToCoordinates(baseRadius, canvasCenter, _handleAngle);
    double svSelectorWidth = 2 * (baseRadius - widget.outerBaseStrokeWidth/2) / sqrt2;
    Offset svOrigin = Offset(canvasCenter.dx - svSelectorWidth /2, canvasCenter.dy + svSelectorWidth /2);
    Offset svHandleCenter = MathUtils.otherCoordsToCanvasCoords(_svHandlePos, svOrigin);

    // set isHandleSelected to if the pointer is within the handles circle
    //_isHandleSelected = _isPointerWithinCircle(pointerPos, handleCenter, handleRadius + 4.0);
    //_isInsideWheelPressed = _isPointerWithinCircle(pointerPos, canvasCenter, baseRadius - widget.outerBaseStrokeWidth / 2 - 5.0);
    //print("H: " + _isHandleSelected.toString() + " IW: " + _isInsideWheelPressed.toString());

    //print("Pointer: " + pointerPos.toString() + " svHandle: " + svHandleCenter.toString());
    // check if slider handle was selected
    if(MathUtils.isPointerWithinCircle(pointerPos, handleCenter, handleRadius + 2.0)) {
      _pointerStatus = PointerStatus.onHandle;
      return;
    }
    // check if svHandle was selected
    if(MathUtils.isPointerWithinCircle(pointerPos, svHandleCenter , handleRadius)){
      _pointerStatus = PointerStatus.onSVHandle;
      return;
    }
    // check if inside Color Wheel was selected
    if(MathUtils.isPointerWithinCircle(pointerPos, canvasCenter, baseRadius - widget.outerBaseStrokeWidth / 2 - 0.5)) {
      _pointerStatus = PointerStatus.insideSliderRing;
      return;
    }
    // check if somewhere along Color Wheel was selected
    if(MathUtils.isPointerWithinCircle(pointerPos, canvasCenter, baseRadius + widget.outerBaseStrokeWidth / 2 + 0.5)) {
      _pointerStatus = PointerStatus.alongSliderRing;
      // jump handle to pointer's position
      _updateHandleToPointer(pointerPos, canvasCenter);
      return;
    }

    _pointerStatus = PointerStatus.none;
  } // _onPanDown

  /*
  * _onPanUpdate()
  * (Gesture Detector _onPanUpdate attribute callback function)
  * What to do when finger position updates (called after finger is down)
   */
  void _onPanUpdate(DragUpdateDetails details) {
    //if pointer finger wasn't previously doing something do nothing
    if(_pointerStatus == PointerStatus.none)
      return;

    // calculate new pointer Position and use to update _handleAngle
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset pointerPos = renderBox.globalToLocal(details.globalPosition);
    Offset canvasCenter = Offset(renderBox.size.width/2, renderBox.size.height/2);

    // used to ensure pointerPos has a value. May not be needed?
    if(pointerPos == null)
      return;

    // if pointer was inside the center circle
    //
    if(_pointerStatus == PointerStatus.insideSliderRing){
      // TODO : check that there was a significant move in the finger
      if((pointerPos.dx - _oldPointerPos!.dx).abs() > 3 || (pointerPos.dy - _oldPointerPos!.dy).abs() > 3){
        // jump the SVHandle to the finger position? (possible addition)


        _pointerStatus = PointerStatus.none;
      }
      return;
    } // an on tap functions so if a pan is registered it is not a tap

    // necessary calculations for
    double baseRadius = (min(renderBox.size.width, renderBox.size.height) - widget.outerBaseStrokeWidth) / 2 - widget.padding;
    double svSelectorWidth = 2 * (baseRadius - widget.outerBaseStrokeWidth/2) / sqrt2;
    Offset svOrigin = Offset(canvasCenter.dx - svSelectorWidth /2, canvasCenter.dy + svSelectorWidth /2);

    if(_pointerStatus == PointerStatus.onSVHandle){
      _updateSVHandleToPointer(pointerPos, svOrigin, svSelectorWidth);
      return;
    } // not a tap so update the ColorWheelSelector's svHandlePos

    // jump handle to pointer's position
    _updateHandleToPointer(pointerPos, canvasCenter);

  } // _onPanUpdate

  void _onPanEnd(DragEndDetails details) {
    if(_pointerStatus == PointerStatus.insideSliderRing){
      setState(() {
        _showSvSelector = !_showSvSelector;
      });
    } // we know it was'nt a pan but a tap so now open/close svSelector

    if(_pointerStatus != PointerStatus.none && widget.onSelectionMade != null) {
      widget.onSelectionMade!(_currentHsvColor);
    } // call the callback function onSelectionMade

    _pointerStatus = PointerStatus.none;
  } // _onPanEnd

  void _updateHandleToPointer(Offset pointerPos, Offset canvasCenter){
    setState(() {
      _handleAngle = MathUtils.coordinatesToAngle(pointerPos, canvasCenter);
      _currentHsvColor = _currentHsvColor.withHue(_angleToHue(_handleAngle));
    });

    if( widget.onSelectionChange != null)
      widget.onSelectionChange!(_currentHsvColor); // call callback function and pass current HSVColor
  } // _updateHandleToPointer

  void _updateSVHandleToPointer(Offset pointerPos, Offset svOrigin, double svSelectorWidth){
    Offset pointerInSVCoords = MathUtils.canvasCoordsToOtherCoords(pointerPos, svOrigin);
    Offset tempHandle = Offset(_svHandlePos.dx, _svHandlePos.dy);

    if(pointerInSVCoords.dx <= svSelectorWidth && pointerInSVCoords.dx >= 0){
      tempHandle = Offset(pointerInSVCoords.dx, tempHandle.dy);
    } // only change x coord if within bounds of svSelector box

    if(pointerInSVCoords.dy <= svSelectorWidth && pointerInSVCoords.dy >= 0){
      tempHandle = Offset(tempHandle.dx, pointerInSVCoords.dy);
    }// only change y coord if within bounds of svSelector box

    if(tempHandle == (_svHandlePos))
      return; // if svHandle coords hasn't changed no need to update state

    setState(() {
      _svHandlePos = tempHandle;
      _currentHsvColor = _currentHsvColor.withSaturation(_svHandlePos.dx/svSelectorWidth);
      _currentHsvColor = _currentHsvColor.withValue(_svHandlePos.dy/svSelectorWidth);
    }); // update _svHandle triggers rebuild

    //widget.onSelectionChange!(_currentHsvColor); // call callback function and pass current HSVColor
  } // _updateSVHandleToPointer

  double _angleToHue(double angle){
    return degrees(angle);
  } // _angleToHue
} // _ColorWheelState