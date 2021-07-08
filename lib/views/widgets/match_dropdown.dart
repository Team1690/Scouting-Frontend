import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatchTextBox extends StatefulWidget {
  MatchTextBox({Key key, @required this.onChange, @required this.controller})
      : super(key: key);

  Function(int) onChange;
  TextEditingController controller;

  @override
  _MatchTextBoxState createState() => _MatchTextBoxState();
}

class _MatchTextBoxState extends State<MatchTextBox> {
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      onChanged: (value) => {
        setState(() => _validate = value.isEmpty),
        value.isNotEmpty
            ? widget.onChange(int.parse(value))
            : widget.onChange(100),
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.tag),
        border: OutlineInputBorder(),
        hintText: 'Enter Match Number',
        errorText: _validate ? 'Value can\'t be empty' : null,
      ),
    );
  }
}
