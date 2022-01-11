import "package:flutter/material.dart";
import 'package:scouting_frontend/views/constants.dart';

class PitViewSlider extends StatefulWidget {
  PitViewSlider.inner({
    required this.label,
    required this.divisions,
    required this.max,
    required this.min,
    required this.onChange,
    required this.value,
  }) {}

  PitViewSlider({
    required final String label,
    required final int divisions,
    required final double max,
    required final double min,
    final void Function(double) onChange = ignore,
    final double? value,
  }) : this.inner(
          label: label,
          divisions: divisions,
          max: max,
          min: min,
          onChange: onChange,
          value: value ?? min,
        );
  final String label;
  final double min;
  final double max;
  final int divisions;
  double value;
  final void Function(double) onChange;
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
