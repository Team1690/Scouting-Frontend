import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatchDropdown extends StatelessWidget {
  MatchDropdown({
    Key key,
    @required this.onChange,
  }) : super(key: key);

  Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => onChange(int.parse(value)),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.tag),
        border: OutlineInputBorder(),
        hintText: 'Enter Match Number',
      ),
    );
  }
}
