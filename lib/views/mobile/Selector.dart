import 'package:flutter/material.dart';
import '../constants.dart';

class Selector extends StatefulWidget {
  const Selector(this.list, {Key key}) : super(key: key);
  final List<String> list;
  @override
  State<Selector> createState() => _SelectorState(list);
}

class _SelectorState extends State<Selector> {
  String dropDownValue = '';
  _SelectorState(this.list) {
    list.insert(0, 'Choose an option');
    dropDownValue = list.elementAt(0);
  }
  List<String> list;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropDownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: primaryColor),
      underline: Container(
        height: 2,
        color: primaryColor,
      ),
      onChanged: (String newValue) {
        setState(() {
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
