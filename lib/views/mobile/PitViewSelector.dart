import 'package:flutter/material.dart';

import '../constants.dart';

class Selector extends StatefulWidget {
  Selector(
      {Key key,
      this.padding,
      this.value,
      this.values,
      this.initialValue,
      this.onChange})
      : super(key: key);
  EdgeInsetsGeometry padding;
  String value;
  List<String> values;
  String initialValue;
  Function(String) onChange;
  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: DropdownButton<String>(
        isExpanded: true,
        value: widget.value,
        elevation: 24,
        style: const TextStyle(color: primaryColor, fontSize: 18),
        underline: Container(
          height: 2,
          color: primaryColor,
        ),
        onChanged: (String newValue) {
          widget.onChange(newValue);
          setState(() {
            if (widget.values.contains(widget.initialValue) &&
                newValue != widget.initialValue) {
              widget.values.remove(widget.initialValue);
            }
            widget.value = newValue;
          });
        },
        items: widget.values.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }
}