import 'package:flutter/material.dart';

class CustomStepper extends StatefulWidget {
  CustomStepper({
    @required this.lowerLimit,
    @required this.upperLimit,
    @required this.stepValue,
    @required this.longPressStepValue,
    @required this.iconSize,
    @required this.value,
    @required this.onPress,
  });

  final int lowerLimit;
  final int upperLimit;
  final int stepValue;
  final int longPressStepValue;
  final double iconSize;
  int value;
  final Function onPress;

  @override
  _CustomStepperState createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedIconButton(
          icon: Icons.remove,
          iconSize: widget.iconSize,
          onPress: () {
            setState(() {
              widget.value = widget.value == widget.lowerLimit
                  ? widget.lowerLimit
                  : widget.value -= widget.stepValue;
            });
          },
          onLongPress: () {
            setState(() {
              widget.value =
                  widget.value < widget.lowerLimit + widget.longPressStepValue
                      ? widget.lowerLimit
                      : widget.value -= widget.longPressStepValue;
            });
          },
        ),
        Container(
          width: widget.iconSize,
          child: Text(
            '${widget.value}',
            style: TextStyle(
              fontSize: widget.iconSize * 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        RoundedIconButton(
          icon: Icons.add,
          iconSize: widget.iconSize,
          onPress: () {
            setState(() {
              widget.value = widget.value == widget.upperLimit
                  ? widget.upperLimit
                  : widget.value += widget.stepValue;
            });
          },
          onLongPress: () {
            setState(() {
              widget.value =
                  widget.value > widget.upperLimit - widget.longPressStepValue
                      ? widget.upperLimit
                      : widget.value += widget.longPressStepValue;
            });
          },
        ),
      ],
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  RoundedIconButton(
      {@required this.icon,
      @required this.onPress,
      @required this.onLongPress,
      @required this.iconSize});

  final IconData icon;
  final Function onPress;
  final Function onLongPress;

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tightFor(width: iconSize, height: iconSize),
      elevation: 6.0,
      onPressed: onPress,
      onLongPress: onLongPress,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(iconSize * 0.4)),
      fillColor: Colors.amber,
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize * 0.8,
      ),
    );
  }
}
