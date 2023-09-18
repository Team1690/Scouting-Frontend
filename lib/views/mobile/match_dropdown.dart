import "package:flutter/material.dart";
import "package:flutter/services.dart";

class MatchTextBox extends StatefulWidget {
  MatchTextBox({
    required this.onChange,
    required this.controller,
    required this.validate,
  });
  final String? Function(String?) validate;
  final void Function(int) onChange;
  final TextEditingController controller;

  @override
  State<MatchTextBox> createState() => _MatchTextBoxState();
}

class _MatchTextBoxState extends State<MatchTextBox> {
  bool _validate = false;

  @override
  Widget build(final BuildContext context) => TextFormField(
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
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.tag),
          border: const OutlineInputBorder(),
          hintText: "Enter Match Number",
          errorText: _validate ? "Value can't be empty" : null,
        ),
      );
}
