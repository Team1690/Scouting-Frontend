import 'package:flutter/material.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

class Counter extends StatelessWidget {
  final Text label;
  Counter({
    final this.label,
  });

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SizedBox(
        //   width: 50,
        //   child: Icon(
        //     Icons.animation,
        //     color: Colors.blue,
        //     size: 24,
        //     semanticLabel: 'Text to announce in accessibility modes',
        //   ),
        // ),
        // // Text('data'),
        // Expanded(
        //   child: label,
        // ),
        Expanded(
          child: StepperSwipe(
            initialValue: 0,
            stepperValue: 1,
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
