import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/stepper.dart';

// TODO improve
class Counter extends StatelessWidget {
  final String label;
  final IconData icon;

  final Function(int) onChange;

  final int count;

  Counter({
    @required final this.label,
    @required final this.icon,
    @required final this.count,
    final this.onChange,
  });

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
            lowerLimit: 0,
            upperLimit: 100,
            value: this.count,
            stepValue: 1,
            longPressStepValue: 5,
            onChanged: this.onChange,
          ),
        )
      ],
    );
  }
}
