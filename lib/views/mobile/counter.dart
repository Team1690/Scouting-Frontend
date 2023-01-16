import "dart:math";

import "package:flutter/material.dart";

class Counter extends StatelessWidget {
  Counter({
    required this.label,
    required this.icon,
    required this.onChange,
    this.color,
    this.stepValue = 1,
    this.upperLimit = 100,
    this.lowerLimit = 0,
    this.longPressedValue = 2,
    required this.count,
  });
  final String label;
  final IconData icon;
  final Color? color;
  final void Function(int) onChange;
  final int stepValue;
  final int upperLimit;
  final int lowerLimit;
  final int longPressedValue;

  final int count;
  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Spacer(),
            Expanded(
              child: Icon(
                icon,
                color: Colors.blue,
                size: 30,
                semanticLabel: "Text to announce in accessibility modes",
              ),
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  label,
                  maxLines: 1,
                  textScaleFactor: 1.5,
                ),
              ),
            ),
            Spacer(
              flex: 2,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Spacer(),
              Expanded(
                flex: 6,
                child: RoundedIconButton(
                  color: color ?? Colors.red,
                  icon: Icons.remove,
                  onPress: () => onChange(max(lowerLimit, count - stepValue)),
                  onLongPress: () =>
                      onChange(max(lowerLimit, count - longPressedValue)),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "$count",
                  style: TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 6,
                child: RoundedIconButton(
                  color: color ?? Colors.green,
                  icon: Icons.add,
                  onPress: () {
                    onChange(min(upperLimit, count + stepValue));
                  },
                  onLongPress: () {
                    onChange(min(upperLimit, count + longPressedValue));
                  },
                ),
              ),
              Spacer(),
            ],
          ),
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
    final Color? color,
  }) : color = color ?? Colors.amber;

  final IconData icon;
  final void Function() onPress;
  final void Function() onLongPress;
  final Color color;

  @override
  Widget build(final BuildContext context) {
    return RawMaterialButton(
      elevation: 6.0,
      onPressed: onPress,
      onLongPress: onLongPress,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      fillColor: color,
      child: Icon(
        icon,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
