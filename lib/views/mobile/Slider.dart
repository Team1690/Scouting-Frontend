import "package:flutter/material.dart";
import 'package:scouting_frontend/views/constants.dart';

class PitViewSlider extends StatefulWidget {
  PitViewSlider({
    final Key? key,
    required this.label,
    required this.divisions,
    required this.max,
    required this.min,
    final void Function(double)? onChange,
  }) : super(key: key) {
    this.onChange = onChange ?? ignore;
  }
  final String label;
  final double min;
  final double max;
  final int divisions;
  late final void Function(double) onChange;
  @override
  _PitViewSliderState createState() => _PitViewSliderState();
}

class _PitViewSliderState extends State<PitViewSlider> {
  late double value = widget.min;
  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(widget.label),
        Slider(
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          value: value,
          label: value.round().toString(),
          onChanged: (final double newVal) {
            widget.onChange(newVal);
            setState(() => value = newVal);
          },
        )
      ],
    );
  }
}
