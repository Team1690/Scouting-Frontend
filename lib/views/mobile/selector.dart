import "package:flutter/material.dart";

import "../constants.dart";

class Selector extends StatelessWidget {
  Selector({
    required this.values,
    required this.initialValue,
    required this.value,
    this.onChange = ignore,
  });
  final List<String> values;
  final String initialValue;
  final void Function(String) onChange;
  final String value;
  @override
  Widget build(final BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
      elevation: 24,
      style: const TextStyle(color: primaryColor, fontSize: 20),
      underline: Container(
        height: 2,
        color: primaryColor,
      ),
      onChanged: (final String? newValue) {
        onChange(newValue!);
      },
      items: values.map<DropdownMenuItem<String>>((final String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}
