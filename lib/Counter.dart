import 'package:flutter/material.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

class Counter extends StatelessWidget {
  final Text label;
  final IconData icon;
  Counter({final this.label, final this.icon});

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 50,
          child: Icon(
            icon,
            color: Colors.blue,
            size: 30,
            semanticLabel: 'Text to announce in accessibility modes',
          ),
        ),
        Expanded(
          child: label,
        ),
        Expanded(
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
