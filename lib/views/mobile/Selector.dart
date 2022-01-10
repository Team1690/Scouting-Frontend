// ignore_for_file: must_be_immutable

import "package:flutter/material.dart";

import "../constants.dart";

class Selector extends StatefulWidget {
  Selector({
    required this.value,
    required this.values,
    required this.initialValue,
    final void Function(String)? onChange,
  }) {
    this.onChange = onChange ?? ignore;
  }
  String value;
  final List<String> values;
  final String initialValue;
  late final void Function(String) onChange;
  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(final BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: widget.value,
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
          widget.value = newValue ?? widget.value;
          widget.onChange(widget.value);
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
