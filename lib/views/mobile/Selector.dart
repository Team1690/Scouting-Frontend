import "package:flutter/material.dart";

import "../constants.dart";

class Selector extends StatefulWidget {
  Selector({
    required this.valueOnReRender,
    required this.values,
    required this.initialValue,
    this.onChange = ignore,
  });
  final String valueOnReRender;
  final List<String> values;
  final String initialValue;
  final void Function(String) onChange;
  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(final BuildContext context) {
    String value = widget.valueOnReRender;
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
      elevation: 24,
      style: const TextStyle(color: primaryColor, fontSize: 18),
      underline: Container(
        height: 2,
        color: primaryColor,
      ),
      onChanged: (final String? newValue) {
        setState(() {
          if (widget.values.contains(widget.initialValue) &&
              newValue != widget.initialValue) {
            widget.values.remove(widget.initialValue);
          }
          value = newValue ?? value;
          widget.onChange(value);
        });
      },
      items: widget.values.map<DropdownMenuItem<String>>((final String value) {
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
