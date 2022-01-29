import "package:flutter/material.dart";

class PitViewSlider extends StatelessWidget {
  PitViewSlider({
    required final String label,
    required final int divisions,
    required final double max,
    required final double min,
    required final void Function(double) onChange,
    required final double value,
  }) : this.inner(
          value: value,
          label: label,
          divisions: divisions,
          max: max,
          min: min,
          onChange: onChange,
        );

  PitViewSlider.inner({
    required this.value,
    required this.label,
    required this.divisions,
    required this.max,
    required this.min,
    required this.onChange,
  });
  final String label;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final void Function(double) onChange;
  @override
  Widget build(final BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Row(
        children: <Widget>[
          Text(
            label,
          ),
          Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value,
            label: value.round().toString(),
            onChanged: onChange,
          )
        ],
      ),
    );
  }
}
