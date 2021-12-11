import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/stepper.dart';

// TODO improve
class Counter extends StatelessWidget {
  final String label;
  final IconData icon;

  final Function(int) onChange;

  final int count;
  final int stepValue;
  final int upperLimit;
  final int lowerLimit;
  final int longPressedValue;

  Counter(
      {@required final this.label,
      @required final this.icon,
      @required final this.count,
      final this.onChange,
      final this.stepValue = 1,
      final this.upperLimit = 100,
      final this.lowerLimit = 0,
      final this.longPressedValue = 5});

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Icon(
            icon,
            color: Colors.blue,
            size: 30,
            semanticLabel: 'Text to announce in accessibility modes',
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            label,
            textScaleFactor: 1.5,
          ),
        ),
        Expanded(
          flex: 4,
          child: CustomStepper(
            iconSize: 30,
            lowerLimit: this.lowerLimit,
            upperLimit: this.upperLimit,
            value: this.count,
            stepValue: this.stepValue,
            longPressStepValue: this.longPressedValue,
            onChanged: this.onChange,
          ),
        )
      ],
    );
  }
}
