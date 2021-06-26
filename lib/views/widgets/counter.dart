import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/widgets/stepper.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

class Counter extends StatelessWidget {
  final String label;
  final IconData icon;

  int count;
  Function(int) onChange;

  Counter({
    @required final this.label,
    @required final this.icon,
    this.count,
    this.onChange,
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
              value: 0,
              stepValue: 1,
              longPressStepValue: 5,
              onPress: (int count) {
                onChange(count);
              }),
        )
        // child: StepperSwipe(
        //     initialValue: 0,
        //     stepperValue: 0,
        //     minValue: 0,
        //     direction: Axis.horizontal,
        //     dragButtonColor: Colors.blueAccent,
        //     iconsColor: Colors.blueAccent,
        //     withPlusMinus: true,
        //     withSpring: true,
        //     onChanged: (int count) {
        //       onChange(count);
        //     }),
        // ),
      ],
    );
  }
}
