import 'package:flutter/material.dart';
import '../constants.dart';

class Selector extends StatefulWidget {
  const Selector(this.hint, this.list, {Key key, this.onChanged})
      : super(key: key);
  final List<String> list;
  final String hint;
  final Function(String) onChanged;
  @override
  State<Selector> createState() => _SelectorState(list, hint);
}

class _SelectorState extends State<Selector> {
  String dropDownValue;
  final String hint;

  _SelectorState(this.list, this.hint) {
    list.insert(0, hint);
    dropDownValue = list.elementAt(0);
  }
  List<String> list;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: dropDownValue,
      elevation: 24,
      style: const TextStyle(color: primaryColor, fontSize: 18),
      underline: Container(
        height: 2,
        color: primaryColor,
      ),
      onChanged: (String newValue) {
        setState(() {
          widget.onChanged(newValue);
          if (list.contains(hint) && newValue != hint) {
            list.remove(hint);
          }
          dropDownValue = newValue;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
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
