import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:scouting_frontend/views/constants.dart";

class MatchTextBox extends StatefulWidget {
  MatchTextBox({
    this.onChange = ignore,
    required this.controller,
    required this.validate,
  }) {}
  final String? Function(String?) validate;
  final void Function(int) onChange;
  final TextEditingController controller;

  @override
  _MatchTextBoxState createState() => _MatchTextBoxState();
}

class _MatchTextBoxState extends State<MatchTextBox> {
  bool _validate = false;

  @override
  Widget build(final BuildContext context) {
    return TextFormField(
      validator: widget.validate,
      controller: widget.controller,
      keyboardType: TextInputType.number,
      onChanged: (final String value) {
        setState(() => _validate = value.isEmpty);
        value.isNotEmpty
            ? widget.onChange(int.parse(value))
            : widget.onChange(100);
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.tag),
        border: OutlineInputBorder(),
        hintText: "Enter Match Number",
        errorText: _validate ? "Value can\'t be empty" : null,
      ),
    );
  }
}
