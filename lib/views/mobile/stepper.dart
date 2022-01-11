import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";

class CustomStepper extends StatefulWidget {
  CustomStepper({
    required this.lowerLimit,
    required this.upperLimit,
    required this.stepValue,
    required this.longPressStepValue,
    required this.iconSize,
    required this.valueOnReRender,
    this.onChanged = ignore,
  });

  final int lowerLimit;
  final int upperLimit;
  final int stepValue;
  final int longPressStepValue;
  final double iconSize;
  final void Function(int) onChanged;
  final int valueOnReRender;

  @override
  _CustomStepperState createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  @override
  Widget build(final BuildContext context) {
    int value = widget.valueOnReRender;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RoundedIconButton(
          icon: Icons.remove,
          iconSize: widget.iconSize,
          onPress: () {
            setState(() {
              value = value == widget.lowerLimit
                  ? widget.lowerLimit
                  : value -= widget.stepValue;
            });
            widget.onChanged(value);
          },
          onLongPress: () {
            setState(() {
              value = value < widget.lowerLimit + widget.longPressStepValue
                  ? widget.lowerLimit
                  : value -= widget.longPressStepValue;
            });
            widget.onChanged(value);
          },
        ),
        Container(
          width: widget.iconSize * 1.5,
          child: Text(
            "${value}",
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
              value = value == widget.upperLimit
                  ? widget.upperLimit
                  : value += widget.stepValue;
            });
            widget.onChanged(value);
          },
          onLongPress: () {
            setState(() {
              value = value > widget.upperLimit - widget.longPressStepValue
                  ? widget.upperLimit
                  : value += widget.longPressStepValue;
            });
            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  RoundedIconButton({
    required this.icon,
    required this.onPress,
    required this.onLongPress,
    required this.iconSize,
  });

  final IconData icon;
  final Function() onPress;
  final Function() onLongPress;

  final double iconSize;

  @override
  Widget build(final BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tightFor(width: iconSize, height: iconSize),
      elevation: 6.0,
      onPressed: onPress,
      onLongPress: onLongPress,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(iconSize * 0.4),
      ),
      fillColor: Colors.amber,
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize * 0.8,
      ),
    );
  }
}
