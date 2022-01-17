import "package:flutter/material.dart";

class SectionDivider extends StatelessWidget {
  SectionDivider({required final this.label});

  final String label;

  Expanded get line => horizontalLine();
  @override
  Widget build(final BuildContext context) {
    return Row(
      children: <Widget>[
        line,
        Text(label),
        line,
      ],
    );
  }

  Expanded horizontalLine() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 15.0, right: 10.0),
        child: Divider(
          thickness: 2,
          color: Colors.black.withOpacity(0.4),
          height: 50,
        ),
      ),
    );
  }
}
