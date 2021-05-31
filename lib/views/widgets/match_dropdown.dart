import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatchDropdown extends StatefulWidget {
  MatchDropdown({
    Key key,
    @required this.onChange,
  }) : super(key: key);

  Function(int) onChange;

  @override
  _MatchDropdownState createState() => _MatchDropdownState();
}

class _MatchDropdownState extends State<MatchDropdown> {
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
