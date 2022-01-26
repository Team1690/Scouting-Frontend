import "dart:math";

import "package:flutter/material.dart";

class CustomStepper extends StatelessWidget {
  CustomStepper({
    required this.lowerLimit,
    required this.upperLimit,
    required this.stepValue,
    required this.longPressStepValue,
    required this.iconSize,
    required this.value,
    required this.onChanged,
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
          onPress: () => onChanged(max(lowerLimit, value - stepValue)),
          onLongPress: () =>
              onChanged(max(lowerLimit, value - longPressStepValue)),
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
            onChanged(min(upperLimit, value + stepValue));
          },
          onLongPress: () {
            onChanged(min(upperLimit, value + longPressStepValue));
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
