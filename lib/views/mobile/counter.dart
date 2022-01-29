import "package:flutter/material.dart";
import "package:scouting_frontend/views/mobile/stepper.dart";

class Counter extends StatelessWidget {
  Counter({
    required final this.label,
    required final this.icon,
    required this.onChange,
    final this.stepValue = 1,
    final this.upperLimit = 100,
    final this.lowerLimit = 0,
    final this.longPressedValue = 2,
    required final this.count,
  });
  final String label;
  final IconData icon;

  final void Function(int) onChange;

  final int stepValue;
  final int upperLimit;
  final int lowerLimit;
  final int longPressedValue;

  final int count;
  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Icon(
            icon,
            color: Colors.blue,
            size: 30,
            semanticLabel: "Text to announce in accessibility modes",
          ),
        ),
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              label,
              maxLines: 1,
              textScaleFactor: 1.5,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: CustomStepper(
            iconSize: 30,
            lowerLimit: lowerLimit,
            upperLimit: upperLimit,
            value: count,
            stepValue: stepValue,
            longPressStepValue: longPressedValue,
            onChanged: onChange,
          ),
        )
      ],
    );
  }
}
