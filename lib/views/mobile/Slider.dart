import "package:flutter/material.dart";
import 'package:scouting_frontend/views/constants.dart';

class PitViewSlider extends StatefulWidget {
  PitViewSlider(
      {required this.label,
      required this.divisions,
      required this.max,
      required this.min,
      final void Function(double)? onChange,
      final double? value}) {
    this.onChange = onChange ?? ignore;
    this.value = value ?? min;
  }
  final String label;
  final double min;
  final double max;
  final int divisions;
  late double value;
  late final void Function(double) onChange;
  @override
  _PitViewSliderState createState() => _PitViewSliderState();
}

class _PitViewSliderState extends State<PitViewSlider> {
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
          value: widget.value,
          label: widget.value.round().toString(),
          onChanged: (final double newVal) {
            widget.onChange(newVal);
            setState(() => widget.value = newVal);
          },
        )
      ],
    );
  }
}
