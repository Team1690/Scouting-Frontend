import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String label;

  SectionDivider({@required final this.label});

  @override
  Widget build(BuildContext context) {
    final line = horizontalLine();

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
          color: Colors.black,
          height: 50,
        ),
      ),
    );
  }
}
