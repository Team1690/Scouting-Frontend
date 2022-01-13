import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/stepper.dart";

class Counter extends StatefulWidget {
  Counter({
    required final this.label,
    required final this.icon,
    required final this.count,
    this.onChange = ignore,
    final this.stepValue = 1,
    final this.upperLimit = 100,
    final this.lowerLimit = 0,
    final this.longPressedValue = 5,
  });
  final String label;
  final IconData icon;

  final void Function(int) onChange;

  int count;
  final int stepValue;
  final int upperLimit;
  final int lowerLimit;
  final int longPressedValue;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Icon(
            widget.icon,
            color: Colors.blue,
            size: 30,
            semanticLabel: "Text to announce in accessibility modes",
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            widget.label,
            textScaleFactor: 1.5,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          flex: 4,
          child: CustomStepper(
            iconSize: 30,
            lowerLimit: widget.lowerLimit,
            upperLimit: widget.upperLimit,
            valueOnReRender: widget.count,
            stepValue: widget.stepValue,
            longPressStepValue: widget.longPressedValue,
            onChanged: (final int p0) {
              setState(() {
                widget.count = p0;
              });
              widget.onChange(p0);
            },
          ),
        )
      ],
    );
  }
}
