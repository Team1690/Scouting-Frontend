import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";

class CustomStepper extends StatelessWidget {
  CustomStepper({
    required this.lowerLimit,
    required this.upperLimit,
    required this.stepValue,
    required this.longPressStepValue,
    required this.iconSize,
    required this.value,
    this.onChanged = ignore,
  });

  final int lowerLimit;
  final int upperLimit;
  final int stepValue;
  final int longPressStepValue;
  final double iconSize;
  final void Function(int) onChanged;
  final int value;

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RoundedIconButton(
          icon: Icons.remove,
          iconSize: iconSize,
          onPress: () {
            final int newValue =
                value == lowerLimit ? lowerLimit : value - stepValue;
            onChanged(newValue);
          },
          onLongPress: () {
            final int newValue = value < lowerLimit + longPressStepValue
                ? lowerLimit
                : value - longPressStepValue;
            onChanged(newValue);
          },
        ),
        Container(
          width: iconSize * 1.5,
          child: Text(
            "$value",
            style: TextStyle(
              fontSize: iconSize * 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        RoundedIconButton(
          icon: Icons.add,
          iconSize: iconSize,
          onPress: () {
            final int newValue =
                value == upperLimit ? upperLimit : value + stepValue;
            onChanged(newValue);
          },
          onLongPress: () {
            final int newValue = value > upperLimit - longPressStepValue
                ? upperLimit
                : value + longPressStepValue;
            onChanged(newValue);
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
