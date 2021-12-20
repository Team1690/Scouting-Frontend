import 'package:flutter/material.dart';

import '../constants.dart';

class PitViewSlider extends StatefulWidget {
  PitViewSlider(
      {Key key,
      @required this.label,
      @required this.value,
      this.onChange,
      this.divisions,
      this.max,
      this.min})
      : super(key: key);
  double value;
  final String label;
  final Function(double) onChange;
  final double min;
  final double max;
  final int divisions;
  @override
  _PitViewSliderState createState() => _PitViewSliderState();
}

class _PitViewSliderState extends State<PitViewSlider> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.label),
        Slider(
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          value: widget.value,
          label: widget.value.round().toString(),
          onChanged: (newVal) {
            widget.onChange(newVal);
            setState(() => widget.value = newVal);
          },
        )
      ],
    );
  }
}
