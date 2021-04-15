import 'package:flutter/material.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

class Counter extends StatelessWidget {
  final String label;
  final IconData icon;
  Counter({
    @required final this.label,
    @required final this.icon,
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
          child: StepperSwipe(
            initialValue: 0,
            stepperValue: 0,
            minValue: 0,
            direction: Axis.horizontal,
            dragButtonColor: Colors.blueAccent,
            iconsColor: Colors.blueAccent,
            withPlusMinus: true,
            withSpring: true,
            onChanged: null,
          ),
        ),
      ],
    );
  }
}